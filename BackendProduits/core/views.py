# Ce fichier définit les vues API pour le modèle Produit.
# Il expose les opérations CRUD (création, lecture, mise à jour, suppression) via un ViewSet,
# permettant ainsi à notre client externe Flutter d'interagir avec les produits
# à travers des requêtes HTTP (GET, POST, PUT, DELETE).
# Le ViewSet relie le modèle Produit et le serializer ProduitSerializer,
# centralisant la logique d'accès aux données produits pour l'API REST.



from django.shortcuts import render
from rest_framework import viewsets
from core.models import Produit, QRcode
from rest_framework.decorators import action
from rest_framework.response import Response
from core.serializers import QRcodeSerializer
from .serializers import ProduitSerializer
from users.models import Utilisateur
from users.serializers import UtilisateurSerializer

class ProduitViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour le modèle Produit.
    """
    queryset = Produit.objects.all()
    serializer_class = ProduitSerializer


    @action(detail=False, methods=['get'], url_path='rechercher')
    def rechercher(self, request):
        """
        Recherche de produits par mot clé dans le nom ou l'UUID.
        """
        mot_cle = request.query_params.get('q', '')
        produits = Produit.rechercherProduit(mot_cle)
        if not produits.exists():
            return Response({"message": "Desole Produit inexistant!"}, status=404)
        serializer = self.get_serializer(produits, many=True,context={'request': request})
        return Response(serializer.data)
    

class QRcodeViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour le modèle QRcode.
    """
    queryset = QRcode.objects.all()
    serializer_class = QRcodeSerializer

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
