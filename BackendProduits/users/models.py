from django.db import models
from django.db.models import Q
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
from datetime import timedelta




<<<<<<< HEAD
class Compte(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True, default="default@exemple.com")  # Ajout du champ email
    password = models.CharField(max_length=128)  # Utiliser un champ sécurisé pour le mot de passe
    is_active = models.BooleanField(default=True)
=======
class Compte(AbstractUser):
    """
    Modèle utilisateur principal héritant de AbstractUser.
    Représente un compte de connexion à la plateforme PharmaTrack.
    Les champs standards Django sont utilisés (username, email, password, etc.).
    """
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49

    def __str__(self):
        """
        Retourne le nom de l'utilisateur pour l'affichage.
        """
        return self.username
    
    def set_password(self, raw_password):
        # Utilise un hash sécurisé en pratique
        self.password = make_password(raw_password)
        self.save()


    
# dans la classe 'Utilisateur' nous initions le role de chaque utilisateurs
# le champ 'role' pour indiquer le rôle de l'utilisateur
# le champ 'compte' est une relation OneToOne avec la classe Compte

class Utilisateur(models.Model):
    """
    Modèle représentant les informations personnelles et le rôle d'un utilisateur.
    Lié en OneToOne à un Compte.
    Champs : nom, téléphone, pays, ville, adresse, rôle (fournisseur, distributeur, gérant).
    """

    role_user = [
        ('fournisseur', 'Fournisseur'),
        ('distributeur', 'Distributeur'),
        ('gerant', 'Gerant_Pharmacie'),
    ]
    compte = models.OneToOneField(Compte, on_delete=models.CASCADE, related_name='user')
    nom = models.CharField(max_length=100)
    telephone = models.CharField(max_length=20)
    pays = models.CharField(max_length=100)
    ville = models.CharField(max_length=100)
    adresse = models.CharField(max_length=255) 
    role = models.CharField(max_length=20, choices=role_user)


    def __str__(self):
        return self.nom

<<<<<<< HEAD
    def supprimerUtilisateur(self):
        self.delete()
    
    def modifierUtilisateur(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)
        self.save()

    def to_json(self):
        return {
            'compte': self.compte.id,  # doit être l'ID (int)
            'nom': self.nom,
            'telephone': self.telephone,
            'email': self.email,
            'pays': self.pays,
            'ville': self.ville,
            'adresse': self.adresse,
            'role': self.role,
        }
=======


class OTP(models.Model):

    """
    Modèle pour stocker les codes OTP (One Time Password) utilisés pour la réinitialisation de mot de passe.
    Champs : compte lié, code OTP, date de création, statut d'utilisation.
    """
     
    compte = models.ForeignKey('Compte', on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)

    def is_valid(self):
        """
        Vérifie si le code OTP est valide.
        Un code OTP est valide s'il n'a pas été utilisé et a été créé il y a moins de 10 minutes.
        """
        return (
            not self.is_used and
            (timezone.now() - self.created_at) < timedelta(minutes=10)
        )
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49
