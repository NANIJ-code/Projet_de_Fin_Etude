"""
Ce fichier définit les modèles de données pour la gestion des produits et la génération automatique de QR codes dans l'application BackendProduits.

- Le modèle Produit représente un produit avec ses informations principales (nom, fournisseur, prix, quantité, date d'expiration, etc.).
- Le modèle QRcode est lié en OneToOne à chaque Produit et stocke l'image du QR code générée.
- Lorsqu'un produit est créé, un signal post_save déclenche la génération d'un QR code contenant l'UUID du produit. 
  Ce QR code est personnalisé avec les 8 derniers caractères de l'UUID affichés sous le code, puis sauvegardé dans le modèle QRcode.
- La génération du QR code utilise la bibliothèque qrcode et Pillow pour le traitement d'image, et les fichiers sont stockés dans le dossier media/qrcodes/.
- Ce système permet d'assurer une traçabilité et une identification unique de chaque produit via son QR code.

Assurez-vous que la police "arial.ttf" est disponible sur le serveur pour l'ajout du texte sur l'image QR code.
"""


from django.db import models
from users.models import Utilisateur

import uuid
from django.db.models.signals import post_save
from django.dispatch import receiver
import qrcode
from PIL import Image, ImageDraw, ImageFont
from django.core.files import File 
from datetime import date
#import File pour la gestion des fichiers
from io import BytesIO 
#importe io pour la gestion des flux de données
from django.db.models import Q
#importe la classe Q pour les requêtes complexes

class Produit(models.Model):
    uuid_produit= models.UUIDField(default=uuid.uuid4, unique= True, editable=False)
    nom = models.CharField(max_length=255)
    fournisseur = models.ForeignKey(Utilisateur, on_delete=models.CASCADE, related_name='produits')
    prix = models.DecimalField(max_digits=10, decimal_places=2)
    quantite = models.PositiveIntegerField(default=1)
    date_enregistrement = models.DateField(auto_now_add=True)
    date_expiration = models.DateField()
    is_active = models.BooleanField(default=True)
    # 
    def __str__(self):
        return self.nom #

    # Recherche de produit par mot clé
    # La recherche se fait sur le nom et l'UUID du produit
    @classmethod
    def rechercherProduit(cls, mot_cle):
        return cls.objects.filter(
            Q(nom__icontains=mot_cle) |
            Q(uuid_produit__icontains=mot_cle)
        )
    
    def consulterProduit(self):
        return {
            "nom": self.nom,
            "prix": self.prix,
            "quantite": self.quantite,
            "fournisseur": self.fournisseur,
            "date_expiration": self.date_expiration,
    }
    
    def modifierProduit(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)
        self.save()

    def supprimerProduit(self):
        self.delete()

   

class QRcode(models.Model):
    produit = models.OneToOneField(Produit, on_delete=models.CASCADE, related_name='qrcodes')
    image = models.ImageField(upload_to='qrcodes/')

# declare le signal post_save pour generer le qr code automatiquement
# lorsque le produit est créé
@receiver(post_save, sender=Produit)
def generate_qr_code(sender, instance, created, **kwargs):
    if created:
        uuid_str = str(instance.uuid_produit)
        #recuperation des 8 derniers acracteres du uuid du produit
        serie_produit = str(instance.uuid_produit)[-8:]

        #creation du qr code
        qr = qrcode.QRCode(
            version=1,
            box_size=10,
            border=2,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
        )
        qr.add_data(uuid_str)
        qr.make(fit=True)

        # Création de l'image QR code
        qr_img = qr.make_image(fill_color="black", back_color="white")
        
        # Ajouter la série de chiffres en bas de l'image
        draw = ImageDraw.Draw(qr_img)
        font = ImageFont.truetype("arial.ttf", 16)

        # Coordonnées pour placer le texte en bas
        text_x = 130
        text_y = qr_img.size[1] - 17

        # Ajout du texte à l'image
        draw.text((text_x, text_y), serie_produit, fill="black", font=font)

        # Enregistrement de l'image QR code dans un fichier
        buffer = BytesIO()
        qr_img.save(buffer, format='PNG')
        buffer.seek(0)

        # Enregistrement de l'image dans le champ ImageField
        qr_code = QRcode(produit=instance)
        qr_code.image.save(f"qr_code_{instance.nom}-{instance.id}.png", File(buffer))


class Alerte(models.Model):
    produit = models.ForeignKey(Produit, on_delete=models.CASCADE)
    message = models.TextField()
    date_alerte = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Alerte pour {self.produit.nom} - {self.message}"
    
class Transaction(models.Model):
    produit = models.ForeignKey(Produit, on_delete=models.CASCADE)
    emetteur = models.CharField(max_length=255)
    destinataire = models.CharField(max_length=255)
    date_transaction = models.DateTimeField(auto_now_add=True)
    TYPE_CHOICES = [
        ('B2B', 'Transaction B2B'),
        ('B2C', 'Transaction B2C'),
    ]
    type_transaction = models.CharField(max_length=50, choices=TYPE_CHOICES)  # 'ajout' ou 'retrait'
    quantite = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.type_transaction} de {self.quantite} unités de {self.produit.nom} le {self.date_transaction}"