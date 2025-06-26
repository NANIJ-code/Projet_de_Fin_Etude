# Ce fichier définit les vues API pour le modèle Produit.
# Il expose les opérations CRUD (création, lecture, mise à jour, suppression) via un ViewSet,
# permettant ainsi à notre client externe Flutter d'interagir avec les produits
# à travers des requêtes HTTP (GET, POST, PUT, DELETE).
# Le ViewSet relie le modèle Produit et le serializer ProduitSerializer,
# centralisant la logique d'accès aux données produits pour l'API REST.

from django.shortcuts import render
from django.http import HttpResponse
from rest_framework import viewsets
from rest_framework.views import APIView
from core.models import Produit, QRcode, Alerte, Transaction
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import permissions
from core.serializers import *
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader
from io import BytesIO
from django.http import FileResponse, Http404
from rest_framework.exceptions import NotFound
from rest_framework import status
from core.permission import IsFournisseurPermission
import uuid as uuid_lib


class ProduitViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les opérations CRUD sur les produits.
    Permet aux fournisseurs de créer, lire, mettre à jour et supprimer des produits.
    """
    queryset = Produit.objects.all()
    serializer_class = ProduitSerializer
    # permission_classes = [IsFournisseurPermission]  #Assurez-vous que l'utilisateur est authentifié et a le rôle de fournisseur

    @action(detail=False, methods=['get'], url_path='rechercher')
    def rechercher(self, request):
        """
        Recherche de produits par mot clé dans le nom ou l'UUID.
        """
        mot_cle = request.query_params.get('mot_cle')
        produits = Produit.rechercherProduit(mot_cle)
        if not produits.exists():
            return Response({"message": "Desole Produit inexistant!"}, status=404)
        serializer = self.get_serializer(produits, many=True, context={'request': request})
        return Response(serializer.data)
    
class LotProduitViewSet(viewsets.ModelViewSet):
    queryset = LotProduit.objects.all()
    serializer_class = LotProduitSerializer
    # permission_classes = [IsFournisseurPermission]  # Assurez-vous que l'utilisateur est authentifié et a le rôle de fournisseur


    def get_queryset(self):
        user = self.request.user
        return LotProduit.objects.filter(unites__position=user.username).distinct()

    @action(detail=False, methods=['get'], url_path='rechercher')
    def rechercher(self, request):
        """
        Recherche de produits par nom ou par numero de lot.
        """
        mot_cle = request.query_params.get('mot_cle')
        lot = LotProduit.rechercherLot(mot_cle)
        if not lot.exists():
            message = "Desole Lot inexistant!"
            return Response({message})
        serializer = self.get_serializer(lot, many=True,context={'request': request})
        return Response(serializer.data)


class UniteProduitViewSet(viewsets.ModelViewSet):
    queryset = UniteProduit.objects.all()
    serializer_class = UniteProduitSerializer
    permission_classes =  [permissions.IsAuthenticated]
    
    # def get_serializer_class(self):
    #     if self.action in ['retrieve', 'scan']:
    #         return UniteProduitSerializer
    #     return ProduitSerializer
    
    # def get_queryset(self):
    #     if self.action == 'maj_position':
    #         return UniteProduit.objects.all()
    #     user = self.request.user
    #     return UniteProduit.objects.filter(position=user.username)
    
    
    
    @action(detail=False, methods=['get'], url_path='scanner')
    def scan(self, request):
        """
        ----------------------------------------------------------------------
        Lecture du QR code d'une unité de produit.
        Retourne les détails de l'unité si elle existe et est valide.
        Fournit l'UUID pour permettre d'autres actions (alerte, maj-position, historique).
        ----------------------------------------------------------------------
        Paramètres :
            - code (query param) : UUID du QR code scanné.
        Retour :
            - Détails de l'unité ou message d'erreur.
        ----------------------------------------------------------------------
        """

        produit_errone = ("Attention Produit Suspect ! \n\n Ce produit n'est pas reconnu, "
                "cela peut être dû à une erreur lors du scan. "
                "Assurez vous que le QR code soit bien en face du lecteur. "
                "Si le problème persiste lancez une alerte.")
        
        # produit_vendu = ("Attention Produit déjà vendu ! \n\n Ce produit a déjà été vendu par. "
        #         "Il ne peut pas être scanné à nouveau. "
        #         "Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support.")
        qr_manquant = f"Code QR manquant"
        code = request.query_params.get('code')
        if not code:
            return Response({qr_manquant}, status=status.HTTP_400_BAD_REQUEST)
        
        unite = UniteProduit.rechercher(code)
        if not unite:
            return Response({produit_errone})
        if not unite.is_active:
            derniere_b2c = (
                ligne_transaction.objects
                .filter(lots=unite.lot, transaction__type_transaction='B2C')
                .select_related('transaction__emetteur')
                .order_by('-transaction__date_creation')
                .first()
            )
            if derniere_b2c:
                emetteur = derniere_b2c.transaction.emetteur
                ville = derniere_b2c.transaction.emetteur.ville
                nom = emetteur
                date = derniere_b2c.transaction.date_creation.strftime('%d-%m-%Y %H:%M')
                produit_vendu = (
                    f"Attention Produit déjà vendu !\n\n"
                    f"Ce produit a été vendu par **{nom}** à **{ville}** le **{date}**.\n"
                    "Il ne peut pas être scanné à nouveau.\n"
                    "Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support."
                )
            else:
                produit_vendu = (
                    "Attention Produit suspect !\n\n"
                    "Ce produit n'est plus actif dans la chaine et ne peut faire l'objet d'operation.\n"
                    "Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support."
                )
            return Response({produit_vendu})
        serializer = self.get_serializer(unite, context={'request': request})
        data = serializer.data
        data['uuid_produit'] = str(unite.uuid_produit)
        # Ici on fournit en sortie du scan l'uuid du produit qui sera recupere coté frontend et servira de paramètre 
        # pour les actions suivantes (alerte, mise à jour de position, historique.)
        return Response(data)
    
    @action(detail=False, methods=['post'], url_path='alerte')
    def lancer_alerte(self, request, pk=None):
        """
        ----------------------------------------------------------------------
        Permet à un utilisateur de lancer une alerte sur une unité de produit.
        L'alerte est liée à l'unité et à son lot, et notifie le supérieur hiérarchique.
        ----------------------------------------------------------------------
        Paramètres :
            - uuid (query param) : UUID de l'unité concernée.
            - message (body) : Message d'alerte.
        Retour :
            - Message de succès ou d'erreur.
        ----------------------------------------------------------------------
        """

        uuid = request.query_params.get('uuid')
        code_scanned = request.data.get('code_scanned')
        message = request.data.get('message')
        utilisateur = request.user
        destinataire = utilisateur.parent
        # uuid_requis = f"UUID du produit requis pour lancer une alerte!"
        # unite_pas_trouve = f"Unité non trouvée pour l'UUID fourni!"

        if uuid:
            try:
                uuid_obj = uuid_lib.UUID(uuid)
                unite = UniteProduit.objects.get(uuid_produit=uuid_obj)
            except (ValueError, UniteProduit.DoesNotExist):
                # UUID invalide OU unité non trouvée => produit inconnu
                serializer = AlerteInconnueSerializer(
                    data={
                        "code_scanned": uuid,
                        "message": message or "QR code inconnu scanné."
                    },
                    context={
                        "request": request,
                        "emetteur": utilisateur,
                        "destinataire": destinataire,
                    }
                )
                serializer.is_valid(raise_exception=True)
                serializer.save()
                return Response({"detail": "Alerte envoyée pour produit inconnu."})
            # Produit trouvé, cas normal
            serializer = AlerteSerializer(
                data={
                    "lot": unite.lot.pk,
                    "unite": unite.pk,
                    "message": message,
                },
                context={
                    "request": request,
                    "emetteur": utilisateur,
                    "destinataire": destinataire,
                }
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response({"detail": "Alerte envoyée avec succès."})
        else:
            # Cas 2 : Produit inconnu (pas d'UUID fourni)
            serializer = AlerteInconnueSerializer(
                data={
                    "code_scanned": code_scanned or "QR inconnu",
                    "message": message or "QR code inconnu scanné."
                },
                context={
                    "request": request,
                    "emetteur": utilisateur,
                    "destinataire": destinataire,
                }
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response({"detail": "Alerte envoyée pour produit inconnu."})

    

    @action(detail=False, methods=['post'], url_path='maj-position')
    def maj_position(self, request, pk=None):
        """
        ----------------------------------------------------------------------
        Met à jour la position de toutes les unités d'un lot après scan d'une unité.
        Vérifie que l'unité est en cours de transaction et que l'utilisateur est bien le destinataire.
        ----------------------------------------------------------------------
        Paramètres :
            - uuid (query param) : UUID de l'unité scannée.
        Retour :
            - Message de succès avec le nombre d'unités mises à jour, ou message d'erreur.
        ----------------------------------------------------------------------
        """

        uuid = request.query_params.get('uuid')

        if not uuid:
            return Response({"detail": "UUID requis."}, status=400)
        try:
            unite_trouve = UniteProduit.objects.get(uuid_produit=uuid)
            
        except UniteProduit.DoesNotExist:
            return Response({"detail": "Unité non trouvée."}, status=404)
        
        lot =  unite_trouve.lot
        utilisateur = request.user 
        unites = UniteProduit.objects.filter(lot = lot)
        updated = 0
        lignes  = ligne_transaction.objects.filter(lots=lot).order_by('-transaction__date_creation').first()
        if not lignes:
            transaction_none = "Aucune transaction trouvée pour ce lot."    
            return Response({transaction_none }, status=404)
        transaction = lignes.transaction

        if transaction.destinataire.username != utilisateur.username:
            destinataire_errone = "Ces Produits ne vous sont pas destinés. Alertez Votre Superieur"
            return Response({ destinataire_errone}, status=400)
            
      
        if unite_trouve.position != "En cours de transaction":
            position_errone = "La position ne peut être mise à jour que si l'unité est en cours de transaction."
            return Response({position_errone}, status=400)
        else :
            for unite in unites:
                unite.position = utilisateur.username
                unite.save()
                updated += 1

            message = f"Position mise à jour pour {updated} unité(s) du lot {lot.numero_lot}."
            return Response({message}, status=200)


    @action(detail=False, methods=['get'], url_path='historique')
    def historique(self, request, pk=None):
        """
        ----------------------------------------------------------------------
        Retourne l'historique des mouvements (transactions) d'une unité de produit.
        Affiche l'enregistrement initial et toutes les transactions du lot.
        ----------------------------------------------------------------------
        Paramètres :
            - uuid (query param) : UUID de l'unité concernée.
        Retour :
            - Liste formatée des mouvements de l'unité.
        ----------------------------------------------------------------------
        """
         
        uuid = request.query_params.get('uuid')
        if not uuid:
            return Response({"detail": "UUID requis."}, status=400)
        try:
            unite = UniteProduit.objects.get(uuid_produit=uuid)
        except UniteProduit.DoesNotExist:
            return Response({"detail": "Unité non trouvée."}, status=404)
        # unite = self.get_object()
        lot = unite.lot
        fournisseur = lot.produit.fournisseur

        historique = []

        # Enregistrement initial
        historique.append({
            "date": lot.date_enregistrement.strftime('%d/%m/%Y - %H:%M'),
            "titre": "🔵Enregistrement initial",
            "details": [
                f"Ajout du lot par : {fournisseur.username} ({fournisseur.role})",
                f"→ Quantité enregistrée : {lot.quantite} unités",
                "→ QR codes générés automatiquement."
            ]
        })

        # Transactions du plus récent au plus ancien
        lignes = (
            ligne_transaction.objects
            .filter(lots=lot)
            .select_related('transaction', 'transaction__emetteur', 'transaction__destinataire')
            .order_by('-transaction__date_creation')
        )

        for ligne in lignes:
            transaction = ligne.transaction
            emetteur = transaction.emetteur
            destinataire = transaction.destinataire
            type_tr = transaction.type_transaction

            if type_tr == 'B2B':
                titre = "🟡Transaction B2B"
                etat = "→ Produit en stock chez le destinataire."
            elif type_tr == 'B2C':
                titre = "🟢Transaction B2C"
                etat = "→ Produit marqué comme VENDU."
            else:
                titre = "⚪Transaction"
                etat = ""

            historique.append({
                "date": transaction.date_creation.strftime('%d/%m/%Y - %H:%M'),
                "titre": titre,
                "details": [
                    f"De : {emetteur.username} ({emetteur.role})",
                    f"Vers : {destinataire.username if destinataire else 'Client final'}"
                    f" ({destinataire.role if destinataire else ''})",
                    f"Quantité transférée : {ligne.quantite_totale} unités",
                    etat 
                ]
            })

        return Response(historique, status=200)

class QRcodeViewSet(viewsets.ModelViewSet):
    queryset = QRcode.objects.all()
    serializer_class = QRcodeSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context


class ExportQRCodesPDF(APIView):
    """
    ----------------------------------------------------------------------
    API permettant de générer et télécharger un fichier PDF contenant
    le QR code du lot ainsi que les QR codes de toutes les unités associées.
    L'utilisateur doit être authentifié et avoir le rôle de fournisseur.
    ----------------------------------------------------------------------
    GET /api_produits/export_qr_pdf/<numero_lot>/
    ----------------------------------------------------------------------
    """

    permission_classes = [IsFournisseurPermission]

    def get(self, request, numero_lot):
        """
        Génère un PDF avec le QR code du lot et ceux de ses unités, puis le retourne en téléchargement.
        :param request: Requête HTTP
        :param numero_lot: Numéro du lot à exporter
        :return: Fichier PDF en téléchargement
        """

        try:
            lot = LotProduit.objects.get(numero_lot=numero_lot)
        except LotProduit.DoesNotExist:
            raise Http404("Lot non trouvé")

        buffer = BytesIO()
        p = canvas.Canvas(buffer, pagesize=A4)
        width, height = A4
        qr_size = 100
        margin_x = 50
        margin_y = 50
        qr_per_row = 4
        x = margin_x
        y = height - 100

        # 1. QR code du lot
        if lot.qr_code:
            p.drawString(margin_x, y, f"Code QR  du lot {lot.numero_lot} de {lot.quantite} d'unités du produit {lot.produit.nom}")
            y -= 20
            p.drawImage(ImageReader(lot.qr_code.path), margin_x, y-qr_size, width=qr_size, height=qr_size)
            y -= qr_size + 40 # espace après le QR du lot

        # 2. QR codes des unités
        unites = lot.unites.all()
        col = 0
        for unite in unites:
            if unite.qr_code and unite.qr_code.image:
                p.drawImage(
                    ImageReader(unite.qr_code.image.path),
                    x, y-qr_size,
                    width=qr_size, height=qr_size
                )
                p.drawString(x, y-qr_size-15, f"Unité {str(unite.uuid_produit)[-8:]}")
                col += 1
                x += qr_size + 30  # espace horizontal
                if col >= qr_per_row:
                    col = 0
                    x = margin_x
                    y -= qr_size + 50  # espace vertical
                    if y < qr_size + margin_y:
                        p.showPage()
                        y = height - 100

        p.save()
        buffer.seek(0)
        return FileResponse(buffer, as_attachment=True, filename=f"qrcodes_{lot.numero_lot}.pdf")

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer

class LigneTransactionViewSet(viewsets.ModelViewSet):
    queryset = ligne_transaction.objects.all()
    serializer_class = LigneTransactionSerializer

class AlerteViewSet(viewsets.ModelViewSet):
    queryset = Alerte.objects.all()
    serializer_class = AlerteSerializer
    def get_queryset(self):
        user = self.request.user
        return Alerte.objects.filter(
            Q(emetteur=user) | Q(destinataire=user)).order_by('-date_alerte')

    