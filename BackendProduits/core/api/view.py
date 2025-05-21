# Ce fichier définit les vues API pour le modèle Produit.
# Il expose les opérations CRUD (création, lecture, mise à jour, suppression) via un ViewSet,
# permettant ainsi à notre client externe Flutter d'interagir avec les produits
# à travers des requêtes HTTP (GET, POST, PUT, DELETE).
# Le ViewSet relie le modèle Produit et le serializer ProduitSerializer,
# centralisant la logique d'accès aux données produits pour l'API REST.


from rest_framework import viewsets
from core.models import Produit
from core.api.serializers import ProduitSerializer

class ProduitViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour le modèle Produit.
    """
    queryset = Produit.objects.all()
    serializer_class = ProduitSerializer