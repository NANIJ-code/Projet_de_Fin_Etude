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
from core.serializers import *
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader
from rest_framework.exceptions import NotFound
from rest_framework import status
from core.permission import IsFournisseurPermission

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
            return Response({"message": "Desole Produit inexistant!"})
        serializer = self.get_serializer(lot, many=True,context={'request': request})
        return Response(serializer.data)


class UniteProduitViewSet(viewsets.ModelViewSet):
    queryset = UniteProduit.objects.all()
    serializer_class = UniteProduitSerializer
    # permission_classes =  [permissions.IsAuthenticated]
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
        """"
            lecture du Scanne d'un produit en utilisant le code QR.
        """
        produit_errone = ("Attention Produit Suspect ! \n\n Ce produit n'est pas reconnu, "
                "cela peut être dû à une erreur lors du scan. "
                "Assurez vous que le QR code soit bien en face du lecteur. "
                "Si le problème persiste lancez une alerte.")
        
        produit_vendu = ("Attention Produit déjà vendu ! \n\n Ce produit a déjà été vendu par. "
                "Il ne peut pas être scanné à nouveau. "
                "Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support.")
        code = request.query_params.get('code')
        if not code:
            return Response({"message": "Code QR manquant"}, status=status.HTTP_400_BAD_REQUEST)
        
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
                nom = emetteur
                ville = getattr(derniere_b2c.transaction.emetteur.ville, 'ville', 'Ville inconnue')
                date = derniere_b2c.transaction.date_creation.strftime('%d-%m-%Y %H:%M')
                produit_vendu = (
                    f"Attention Produit déjà vendu !\n\n"
                    f"Ce produit a été vendu par {nom} à {ville} le {date}.\n"
                    "Il ne peut pas être scanné à nouveau.\n"
                    "Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support."
                )
            return Response({produit_vendu})
        serializer = self.get_serializer(unite, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], url_path='alerte')
    def lancer_alerte(self, request, pk=None):
        unite = self.get_object()
        message = request.data.get('message')
        utilisateur = request.user
        destinataire = utilisateur.parent  # ou autre logique selon ton modèle

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

    @action(detail=True, methods=['get'], url_path='historique')
    def historique(self, request, pk=None):
        """
        Affiche l'historique des transactions d'une unité (du plus récent au plus ancien).
        """
        try:
            unite = self.get_object()
        except UniteProduit.DoesNotExist:
            return Response({"detail": "Unité non trouvée."}, status=404)

        historique = []
        # Ajout de l'événement d'enregistrement
        fournisseur = unite.lot.produit.fournisseur
        historique.append({
            "evenement": f"Produit Enregistré le {unite.lot.date_enregistrement.strftime('%d-%m-%Y')} par {fournisseur.username} à {fournisseur.ville}",
            "date": unite.lot.date_enregistrement.strftime('%d-%m-%Y'),
            "etat_mouvement": "Enregistré",
            "emetteur": fournisseur.username,
            "destinataire": "",
        })

        # Transactions du plus récent au plus ancien
        lignes = (
            ligne_transaction.objects
            .filter(lots=unite.lot)
            .select_related('transaction')
            .order_by('-transaction__date_creation')
        )
        for ligne in lignes:
            transaction = ligne.transaction
            if transaction.type_transaction == 'B2B':
                etat = "En cours de transaction" if unite.position == "En cours de transaction" else "Transféré"
            elif transaction.type_transaction == 'B2C':
                etat = "Vendu"
            else:
                etat = "Inconnu"
            historique.append({
                "evenement": "",
                "date": transaction.date_creation.strftime('%d-%m-%Y %H:%M'),
                "etat_mouvement": etat,
                "emetteur": transaction.emetteur,
                "destinataire": transaction.destinataire,
            })

        return Response({
            "unite": str(unite.uuid_produit),
            "lot": unite.lot.numero_lot,
            "actuelle_position": unite.position,
            "est_active": unite.is_active,
            "historique": historique
        })

    @action(detail=True, methods=['post'], url_path='maj-position')
    def maj_position(self, request, pk=None):
        """
        Met à jour la position de l'unité si elle est 'En cours de transaction'.
        """
        unite = self.get_object()
        utilisateur = request.user 
        if unite.position != "En cours de transaction":
            return Response({"detail": "La position ne peut être mise à jour que si l'unité est en cours de transaction."}, status=400)
        unite.position = utilisateur.username
        unite.save()
        return Response({"detail": "Position mise à jour avec succès."})


class HistoriqueUniteAPIView(APIView):
    """
    API pour consulter l'historique de mouvement d'une unité de produit à partir de son UUID.
    """

    def get(self, request):
        code = request.query_params.get('code')
        if not code:
            return Response({"detail": "UUID de l’unité requis."}, status=400)

        try:
            unite = UniteProduit.objects.get(uuid_produit=code)
        except UniteProduit.DoesNotExist:
            return Response({"detail": "Unité non trouvée."}, status=404)

        historique = []

        # On récupère toutes les lignes de transaction liées au lot de cette unité
        lignes = ligne_transaction.objects.filter(lots=unite.lot).order_by('transaction__date_creation')

        for ligne in lignes:
            transaction = ligne.transaction
            historique.append({
                "produit": ligne.produit.nom,
                "numero_lot": unite.lot.numero_lot,
                "quantite_transferee": ligne.quantite_totale,
                "type_transaction": transaction.type_transaction,
                "emetteur": transaction.emetteur,
                "destinataire": transaction.destinataire,
                "date": transaction.date_creation.strftime('%d-%m-%Y %H:%M'),
            })

        return Response({
            "unite": str(unite.uuid_produit),
            "lot": unite.lot.numero_lot,
            "actuelle_position": unite.position,
            "est_active": unite.is_active,
            "historique": historique
        }, status=200)
class QRcodeViewSet(viewsets.ModelViewSet):
    queryset = QRcode.objects.all()
    serializer_class = QRcodeSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context


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

    