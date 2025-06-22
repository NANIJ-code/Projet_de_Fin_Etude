# Ce fichier définit les vues API pour le modèle Produit.
# Il expose les opérations CRUD (création, lecture, mise à jour, suppression) via un ViewSet,
# permettant ainsi à notre client externe Flutter d'interagir avec les produits
# à travers des requêtes HTTP (GET, POST, PUT, DELETE).
# Le ViewSet relie le modèle Produit et le serializer ProduitSerializer,
# centralisant la logique d'accès aux données produits pour l'API REST.

from django.shortcuts import render
from rest_framework import viewsets
from core.models import Produit, QRcode, Alerte, Transaction
from rest_framework.decorators import action
from rest_framework.response import Response
<<<<<<< HEAD
from core.serializers import QRcodeSerializer
from .serializers import ProduitSerializer
from users.models import Utilisateur
from users.serializers import UtilisateurSerializer
=======
from core.serializers import *
from rest_framework.exceptions import NotFound
from rest_framework import status
from core.permission import IsFournisseurPermission

>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49

class ProduitViewSet(viewsets.ModelViewSet):
    queryset = Produit.objects.all()
    serializer_class = ProduitSerializer
    permission_classes = [IsFournisseurPermission]  # Assurez-vous que l'utilisateur est authentifié et a le rôle de fournisseur

    def get_serializer_class(self):
        if self.action in ['retrieve', 'scan']:
            return ProduitDetailSerializer
        return ProduitSerializer
    
    @action(detail=False, methods=['get'], url_path='rechercher')
    def rechercher(self, request):
        """
        Recherche de produits par mot clé dans le nom ou l'UUID.
        """
        mot_cle = request.query_params.get('mot_cle')
        produits = Produit.rechercherProduit(mot_cle)
        if not produits.exists():
            return Response({"message": "Desole Produit inexistant!"}, status=404)
        serializer = self.get_serializer(produits, many=True,context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], url_path='scan')
    def scan(self, request):
        """"
            lecture du Scanne d'un produit en utilisant le code QR.
        """
        message = ("Attention Produit Suspect ! Ce produit n'est pas reconnu, "
                "cela peut être dû à une erreur lors du scan. "
                "Assurez vous que le QR code soit bien en face du lecteur. "
                "Vous pouvez opter pour une recherche avec son identifiant tout juste en dessous du QR code. "
                "Si le problème persiste lancez une alerte.")
        
        code = request.query_params.get('code')
        if not code:
            return Response({"message": "Code QR manquant"}, status=status.HTTP_400_BAD_REQUEST)
        produit = Produit.objects.filter(uuid_produit__endswith=code).first()
        if not produit:
            produit = Produit.objects.filter(uuid_produit=code).first()
        if not produit:
            produit = Produit.objects.filter(nom=code).first()
        if not produit:
            return Response({message}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(produit, context={'request': request})
        return Response(serializer.data)
class QRcodeViewSet(viewsets.ModelViewSet):
    queryset = QRcode.objects.all()
    serializer_class = QRcodeSerializer

<<<<<<< HEAD
    def get_queryset(self):
        return self.queryset.filter(qrcodes__isnull=False)
        #Retourne uniquement les produits qui ont un QR code associé

class FournisseurViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet pour le modèle Utilisateur, filtrant par le rôle 'fournisseur'.
    """
    serializer_class = UtilisateurSerializer

    def get_queryset(self):
        return Utilisateur.objects.filter(role='fournisseur')
=======
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
class AlerteViewSet(viewsets.ModelViewSet):
    queryset = Alerte.objects.all()
    serializer_class = AlerteSerializer

    
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49
