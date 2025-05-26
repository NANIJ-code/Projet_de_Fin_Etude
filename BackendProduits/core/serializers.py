from rest_framework import serializers
from core.models import Produit

class ProduitSerializer(serializers.ModelSerializer):

    class Meta:
        model = Produit
        # Champs à saisir lors de la création
        fields = ['id', 'nom', 'fournisseur', 'prix', 'quantite', 'date_expiration']
        # Champs à afficher lors de la consultation   