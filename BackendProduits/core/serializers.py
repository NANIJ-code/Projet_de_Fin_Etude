from rest_framework import serializers
from django.conf import settings
from .models import *
from datetime import date
from django.core.mail import send_mail

class ProduitSerializer(serializers.ModelSerializer):
    """
    Sérialiseur pour enregistrer un nouveau produit dans la base de donnees.
    Le fournisseur est assigné dynamiquement à partir de l’utilisateur connecté.
    """

    fournisseur = serializers.SerializerMethodField()

    class Meta:
        model = Produit
        fields = ['id', 'nom', 'fournisseur', 'prix', 'description']

    def get_fournisseur(self, obj):
        """
        Retourne le nom du fournisseur associé au produit.
        """
        return obj.fournisseur.username 
    
    def create(self, validated_data):
        utilisateur = self.context['request'].user 
        # 
        if utilisateur.role != 'fournisseur':
            raise serializers.ValidationError("Seuls les fournisseurs peuvent enregistrer un produit.")
        if Produit.objects.filter(nom=validated_data['nom'], fournisseur=utilisateur).exists():
            raise serializers.ValidationError(f"Le produit {validated_data['nom']}  a déjà été enregistré") 
        validated_data['fournisseur'] = utilisateur
        return super().create(validated_data)  

class LotProduitSerializer(serializers.ModelSerializer):
    """
    Sérialiseur pour creer un lot de produit  avec vérification de la date d'expiration.
    Le champ 'numero_lot' est généré automatiquement.
    Le champ 'produit' est un champ de lecture seule qui retourne le nom du produit associé.
    """

    # produit = ProduitSerializer()
    produit_nom = serializers.CharField(source='produit.nom', read_only=True)
    qr_code = serializers.SerializerMethodField()
    class Meta:
        model = LotProduit
        fields = ['numero_lot', 'produit','produit_nom', 'quantite', 'date_enregistrement','date_expiration','qr_code']
        # extra_kwargs = {
        #     'numero_lot': {'read_only': True},
        #     'qr_code': {'read_only': True}
        #     }

    
    
    def get_qr_code(self, obj):
        """
         Fonction permettant de retourner l'url du code qr associe au produit
        """
        if obj.qr_code:
            request = self.context.get('request')
            request = self.context.get('request')
            return request.build_absolute_uri(obj.qr_code.url) if request else obj.qr_code.url
        return None
    
    def validate_date_expiration(self, value):
        if value < date.today():
            raise serializers.ValidationError("La date d'expiration ne peut pas être dans le passé.")
        return value    
        
class UniteProduitSerializer(serializers.ModelSerializer):
    qr_code_url = serializers.SerializerMethodField()
    lot = serializers.SerializerMethodField()

    class Meta:
        model = UniteProduit
        fields = [
            'id',
            'lot', 
            'position', 
            'qr_code_url'
        ]
    
    def get_lot(self, obj):
        """
        Fonction permettant de retourner le nom du produit associé à l'unité de produit.
        """
        return {
            'nom': obj.lot.produit.nom,
            'numero_lot':obj.lot.numero_lot,
            'prix': obj.lot.produit.prix,
            'date_expiration': obj.lot.date_expiration,
            'description': obj.lot.produit.description,
            
        }
    
    def get_qr_code_url(self, obj):
        """
         Fonction permettant de retourner l'url du code qr associe au produit
        """
        if obj.qr_code:
            request = self.context.get('request')
            return request.build_absolute_uri(obj.qr_code.image.url) if request else obj.qr_code.image.url
        return None
    
    
class QRcodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = QRcode
        fields = [ 'unite_produit', 'image']


class LigneTransactionSerializer(serializers.ModelSerializer):
    
    lots = serializers.PrimaryKeyRelatedField(queryset=LotProduit.objects.all(), many=True)
    quantite_totale = serializers.IntegerField(read_only=True)
    class Meta:
        model = ligne_transaction
        fields = ['produit', 'lots','quantite_totale']

    
    def get_quantite_totale(self, obj):
        # Affiche la quantité totale des unités de produit dans la ligne de transaction
        return obj.quantite_totale
    def create(self, validated_data):
        lots_data = validated_data.pop('lots')
        instance = super().create(validated_data)
        instance.lots.set(lots_data)
        return instance
class TransactionSerializer(serializers.ModelSerializer):
    lignes = LigneTransactionSerializer(many=True, write_only=True)
    emetteur = serializers.SerializerMethodField(read_only=True)
    destinataire = serializers.PrimaryKeyRelatedField(queryset=Utilisateur.objects.all(), write_only=True)

    class Meta:
        model = Transaction
        fields = ['id', 'emetteur','destinataire', 'type_transaction', 'lignes']

    def get_emetteur(self, obj):
        return {
            "username": obj.emetteur.username,
            "ville": obj.emetteur.ville,
        }

    def get_destinataire(self, obj):
        return {
            "username": obj.destinataire.username,
        }
    
    def create(self, validated_data):
        utilisateur = self.context['request'].user 
        lignes_data = validated_data.pop('lignes')
        destinataire = validated_data.pop('destinataire')
        transaction = Transaction.objects.create(
            emetteur = utilisateur, 
            destinataire=destinataire,
            **validated_data)
        for ligne_data in lignes_data:
            lots = ligne_data['lots']
            produit = ligne_data['produit']
            quantite = sum(lot.quantite for lot in lots)
            ligne = ligne_transaction.objects.create(
                transaction=transaction,
                produit=produit,
                quantite_totale=quantite
        )
        ligne.lots.set(lots)

        for lot in lots:
            unites = UniteProduit.objects.filter(lot=lot, is_active=True)[:quantite]
            for unite in unites:
                if transaction.type_transaction == 'B2B':
                    unite.position = "En cours de transaction"
                elif transaction.type_transaction == 'B2C':
                    unite.position = "Vendu"
                    unite.is_active = False
                unite.save()
        # Envoi d'un email de confirmation
        if destinataire and destinataire.email:
            message = f"Bonjour {destinataire.username},\n\n"
            message += f"Une nouvelle transaction a été enregistrée par {utilisateur.username}.\n"
            message += f"Type de transaction: {transaction.type_transaction}\n"
            message += "Détails des lignes de transaction:\n\n"
            for ligne in lignes_data:
                lots_str = ", ".join([lot.numero_lot for lot in ligne['lots']])
                quantite = sum(lot.quantite for lot in ligne['lots'])
                message += f"- Produit: {ligne['produit'].nom}\n - Lots: {lots_str}\n - Quantité d'unités: {quantite}\n\n"
            message += f"\nPour plus d'informations, veuillez contacter l'émetteur de la transaction: {utilisateur.username} ({utilisateur.email})."
            send_mail(
                subject="Nouvelle Transaction",
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[destinataire.email],
                fail_silently=True,
            )
        return transaction    


   
class AlerteSerializer(serializers.ModelSerializer):

    # lot = serializers.SerializerMethodField()

    class Meta:
        model = Alerte
        fields = ['lot', 'unite', 'message', 'date_alerte']
    
    def get_lot(self, obj):
        return {
            "Produit": obj.lot.produit.nom,
            "Numero de Lot": obj.lot.numero_lot,
        }
    def create(self, validated_data):

        emetteur = self.context['emetteur']
        destinataire = self.context['destinataire']
        unite = validated_data['unite']
        lot = validated_data['lot']
        message = validated_data['message']

        alerte = Alerte.objects.create(
            lot=lot,
            unite=unite,
            emetteur=emetteur,
            destinataire=destinataire,
            message=message
        )

        
        # Envoi du mail
        if destinataire and destinataire.email:
            message  += f"\n\n \t\t\t\t Détails de l'alerte:\nProduit: {lot.produit.nom}\nNuméro de lot: {lot.numero_lot}\n Unité Produit Concerné: N° {unite:id}"
            message += f"\n\nPour plus d'informations, veuillez contacter l'émetteur de l'alerte: {emetteur.username} ({emetteur.email})"
            
            send_mail(
                subject="Alerte sur un produit",
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[destinataire.email],
                fail_silently=True,
            )
        for unite in lot.unites.all():
            # Désactive le produit en cas d'alerte
            unite.is_active = False
            unite.save()  
        return alerte
