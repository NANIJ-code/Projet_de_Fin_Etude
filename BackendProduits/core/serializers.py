from rest_framework import serializers
from .models import Produit, QRcode, Utilisateur, Alerte, Transaction
from datetime import date

class ProduitSerializer(serializers.ModelSerializer):
    qr_code_url = serializers.SerializerMethodField()
    class Meta:
        model = Produit
        fields = ['id', 'nom', 'prix', 'quantite', 'date_expiration', 'qr_code_url']

    
    def create(self, validated_data):
        fournisseur = validated_data['fournisseur']
        return super().create(validated_data)
    
    def validate_date_expiration(self, value):
        if value < date.today():
            raise serializers.ValidationError("La date de péremption ne peut pas être dans le passé.")
        return value
    def get_qr_code_url(self, obj):
        if hasattr(obj, 'qrcodes') and obj.qrcodes:
            request = self.context.get('request')
            url = obj.qrcodes.image.url

            if request is not None:
                # Assure que l'URL est absolue
                return request.build_absolute_uri(url)
            # Assure que l'objet a un attribut 'qrcodes' et qu'il n'est pas vide
            return request.build_absolute_uri(url)
        return None
class ProduitDetailSerializer(serializers.ModelSerializer):
    qr_code_url = serializers.SerializerMethodField()
    class Meta:
        model = Produit
        fields = [
            'id', 
            'nom', 
            'fournisseur', 
            'prix', 
            'quantite', 
            'date_enregistrement', 
            'date_expiration', 
            'position', 
            'description', 
            'qr_code_url'
        ]
    
    def get_qr_code_url(self, obj):
        if hasattr(obj, 'qrcodes') and obj.qrcodes:
            request = self.context.get('request')
            url = obj.qrcodes.image.url

            if request is not None:
                # Assure que l'URL est absolue
                return request.build_absolute_uri(url)
            # Assure que l'objet a un attribut 'qrcodes' et qu'il n'est pas vide
            return request.build_absolute_uri(url)
        return None
    
    
class QRcodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = QRcode
        fields = ['id', 'produit', 'image']

class TransactionSerializer(serializers.Serializer):
    """
    Serializer pour les traces de produits.
    """
    class Meta:
        model = Transaction
        fields = '__all__'

    def create(self, validated_data):
        transaction = super().create(validated_data)
        produit = transaction.produit

        if transaction.type_transaction == 'B2B':
            produit.position = "En cours de transaction"
        elif transaction.type_transaction == 'B2C':
            produit.position = "Vendu"
            produit.is_active = False

        produit.save()
        return transaction

class ligneTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = ['id', 'transaction', 'produit', 'quantite']
    
    def create(self, validated_data):
        ligne_transaction = super().create(validated_data)
        produit = ligne_transaction.produit
        produit.quantite -= ligne_transaction.quantite  # Met à jour la quantité du produit
        produit.save()
        return ligne_transaction

class AlerteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alerte
        fields = ['id', 'produit', 'message', 'date_alerte']
    
    def create(self, validated_data):
        alerte = super().create(validated_data)
        produit = alerte.produit
        produit.is_active = False  # Désactive le produit en cas d'alerte
        produit.save()
        return alerte
