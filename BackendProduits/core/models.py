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
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from users.models import Utilisateur
import uuid
import qrcode
from PIL import Image, ImageDraw, ImageFont
from io import BytesIO
from django.core.files import File
from django.db.models import Q

#########################################################
                #FONCTIONS#
#########################################################
def generer_prefixe(nom):
    """
    Génère un préfixe en 4 lettres majuscules à partir du nom du produit.
    Supprime les espaces et prend les 4 premières lettres.
    """
    return nom.upper().replace(" ", "")[:4]

def generer_qr_code(data, texte_sous_qr, nom_fichier):
    """
    Génère un QR code avec un texte positionné comme dans le code commenté.
    """
    # Génération du QR code avec les paramètres du code commenté
    qr = qrcode.QRCode(
        version=2,
        box_size=10,
        border=2,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
    )
    qr.add_data(data)
    qr.make(fit=True)
    qr_img = qr.make_image(fill_color="black", back_color="white").convert("RGB")

    # Dessiner le texte sur l'image du QR code (sans redimensionnement)
    draw = ImageDraw.Draw(qr_img)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except:
        font = ImageFont.load_default()

    # Position fixe du texte (comme dans le code commenté)
    text_x = 125
    text_y = qr_img.size[1] - 17
    draw.text((text_x, text_y), texte_sous_qr, fill="black", font=font)

    # Sauvegarder l'image
    buffer = BytesIO()
    qr_img.save(buffer, format='PNG')
    buffer.seek(0)
    return File(buffer, name=nom_fichier)

#########################################################
                #CLASSE#
#########################################################
class Produit(models.Model):
    nom = models.CharField(max_length=255)
    fournisseur = models.ForeignKey(Utilisateur, on_delete=models.CASCADE, related_name='produits')
    prix = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.CharField(max_length=255, default="")

    def __str__(self):
        return self.nom
class LotProduit(models.Model):
    """
    Représente un produit enregistré par un fournisseur.

    - Le champ `numero_lot` est une clé primaire générée automatiquement à partir du nom.
    - Lors de la création, des unités sont générées selon la quantité, chacune avec un QR code unique.
    """
    numero_lot = models.CharField(primary_key=True, max_length=50, unique=True, editable=False)
    produit = models.ForeignKey(Produit, on_delete=models.CASCADE, related_name='lots')
    quantite = models.PositiveIntegerField(default=1)
    date_enregistrement = models.DateField(auto_now_add=True)
    date_expiration = models.DateField()
    qr_code = models.ImageField(upload_to='lots/', blank=True, null=True)


    def save(self, *args, **kwargs):
        """
        Génère automatiquement un numéro de lot unique basé sur le nom du produit
        s'il n'est pas encore défini.
        """
        if not self.numero_lot:
            prefixe = generer_prefixe(self.produit.nom)
            dernier = LotProduit.objects.filter(numero_lot__startswith=prefixe).order_by('-numero_lot').first()
            if dernier:
                dernier_num = int(dernier.numero_lot.split('-')[-1])
                nouveau_num = dernier_num + 1
            else:
                nouveau_num = 1
            self.numero_lot = f"{prefixe}-{str(nouveau_num).zfill(4)}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.produit.nom} ({self.numero_lot})"
    
    @classmethod
    def rechercherLot(cls, mot_cle):
        return cls.objects.filter(
            Q(produit__nom__icontains=mot_cle) |
            Q(numero_lot__icontains=mot_cle)
        )

class UniteProduit(models.Model):
    """
    Représente une unité individuelle d’un produit (par exemple, une boîte de médicament).

    - Chaque unité a un UUID unique.
    - Elle est liée à un `Produit` via une clé étrangère.
    - Un QR code est généré automatiquement à la création.
    """
    uuid_produit = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    lot = models.ForeignKey(LotProduit, on_delete=models.CASCADE, related_name='unites')
    position = models.CharField(max_length=255, default="")
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"Unité {str(self.uuid_produit)[-8:]} - Lot {self.lot.numero_lot}"

    @classmethod
    def rechercher(cls, code):
        try:
            return cls.objects.get(uuid_produit=code)
        except cls.DoesNotExist:
            # Si l'unité n'existe pas, on peut lever une exception ou retourner None
            return None
        
        

class QRcode(models.Model):
    """
    Stocke le QR code généré pour une unité de produit.

    - Chaque `UniteProduit` a un seul QR code (relation OneToOne).
    - L’image est stockée dans le dossier `media/qrcodes/`.
    """
    unite_produit = models.OneToOneField(UniteProduit, on_delete=models.CASCADE, related_name='qr_code')
    image = models.ImageField(upload_to='qrcodes/')

    def __str__(self):
        return f"QR - {self.unite_produit.uuid_produit}"


class Alerte(models.Model):
    lot = models.ForeignKey(LotProduit, on_delete=models.CASCADE, null=True, blank=True)
    message = models.TextField()
    unite = models.ForeignKey(UniteProduit, on_delete=models.CASCADE, null=True, blank=True)
    emetteur = models.ForeignKey('users.Utilisateur', on_delete=models.CASCADE, related_name='alertes_emises')
    destinataire = models.ForeignKey('users.Utilisateur', on_delete=models.CASCADE, related_name='alertes_recues')
    message = models.TextField()
    date_alerte = models.DateTimeField(auto_now_add=True)
    

    def __str__(self):
        if self.lot:
            return f"Alerte pour {self.lot.produit.nom} - {self.message}"
        return f"Alerte - {self.message}"
class Transaction(models.Model):
    """
        Modèle pour enregistrer les transactions de produits.
        Nous avons deux types de transaction:
        - Transaction B2B: Business To Business, transaction entre 
            deux acteurs de la chaine de distribution
            (par exemple, un fournisseur et un distributeur).
        - Transaction B2C: Business To Customer, transaction entre 
            un acteur de la chaine de distribution et le client final.
    """
    emetteur = models.ForeignKey('users.Utilisateur', on_delete=models.CASCADE, related_name='transactions_emises')
    destinataire = models.ForeignKey('users.Utilisateur', on_delete=models.CASCADE, related_name='transactions_recues')
    date_creation = models.DateTimeField(auto_now_add=True)
    TYPE_CHOICES = [
        ('B2B', 'Transaction B2B'),
        ('B2C', 'Transaction B2C'),
    ]
    type_transaction = models.CharField(max_length=50, choices=TYPE_CHOICES) 

    def __str__(self):
        return f"Transaction éffectuée avec Succès"
    

class ligne_transaction(models.Model):
    """
        Modèle pour enregistrer les lignes de transaction.
        Chaque ligne de transaction est liée à une transaction spécifique
        et contient des informations sur le produit, la quantité et le prix unitaire.
    """
    transaction = models.ForeignKey(Transaction, on_delete=models.CASCADE, related_name='lignes')
    produit = models.ForeignKey(Produit, on_delete=models.CASCADE, related_name="transactionsProduit")
    lots = models.ManyToManyField(LotProduit, related_name='transactionsLots')
    quantite_totale = models.PositiveIntegerField()
   
    def  __str__(self):
        return (
            f"Transaction {self.transaction.type_transaction} de {self.quantite_totale} unités de "
            f"{self.produit.nom} de {self.transaction.emetteur} vers {self.transaction.destinataire} "
            f"le {self.transaction.date_creation.strftime('%d-%m-%Y %H:%M')}"
        )
    
    def save(self, *args, **kwargs):
        """
        Vérifie que tous les lots associés au produit sont du même produit avant de sauvegarder.
        """
        
        super().save(*args, **kwargs)




    
#########################################################
                #SIGNAUX#
#########################################################
@receiver(post_save, sender=LotProduit)
def creer_unites_et_qr_lot(sender, instance, created, **kwargs):
    if created:
        # Générer QR du lot avec le numéro de lot sous le QR code
        qr_file = generer_qr_code(
            data=f"LOT-{instance.numero_lot}",
            texte_sous_qr=instance.numero_lot,
            nom_fichier=f"lot_{instance.numero_lot}.png"
        )
        instance.qr_code.save(qr_file.name, qr_file)
        instance.save()   # sauvegarde du champ mise a jour


        # Créer les unités de produit
        for _ in range(instance.quantite):
            unite = UniteProduit.objects.create(
                lot=instance,
                position=instance.produit.fournisseur.username  # Position initiale
            )


@receiver(post_save, sender=UniteProduit)
def creer_unites__qr(sender, instance, created, **kwargs):
    """
    Signal exécuté après la création d’une unite de produit.
    
    - Génère automatiquement Pour chaque unité, un QR code est créé et lié à l’unité.
    """
    if created:
        uuid_str = str(instance.uuid_produit)
        suffixe = uuid_str[-8:]
        qr_file = generer_qr_code(
            data=uuid_str,
            texte_sous_qr=suffixe,
            nom_fichier=f"qr_{instance.lot.numero_lot}_{suffixe}.png"
        )
        qr_code = QRcode(unite_produit=instance)
        qr_code.image.save(qr_file.name, qr_file)
        qr_code.save()


@receiver(post_delete, sender=QRcode)
def supprimer_fichier_qr_unite(sender, instance, **kwargs):
    if instance.image:
        instance.image.delete(False)

@receiver(post_delete, sender=LotProduit)
def supprimer_fichier_qr_lot(sender, instance, **kwargs):
    if instance.qr_code:
        instance.qr_code.delete(False)



















