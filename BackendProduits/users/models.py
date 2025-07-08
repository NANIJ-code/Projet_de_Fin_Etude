from django.db import models
from django.db.models import Q
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
from datetime import timedelta


    
# dans la classe 'Utilisateur' nous initions le role de chaque utilisateurs
# le champ 'role' pour indiquer le rôle de l'utilisateur
# le champ 'compte' est une relation OneToOne avec la classe Compte

class Utilisateur(AbstractUser):
    """
    Modèle représentant les informations personnelles et le rôle d'un utilisateur.
    Hérite de AbstractUser pour inclure les champs de base tels que username, password, email, etc.
    Champs supplémentaires : parent, téléphone, pays, ville, adresse, rôle (fournisseur, distributeur, gérant).
    - le champ 'parent' permet de garder une trace sur qui a cree qui, cela permettra de filtrer les destinateurs
       d'une transaction en fonction de l'utilisateur connecté.
    """

    role_user = [
        ('fournisseur', 'Fournisseur'),
        ('distributeur', 'Distributeur'),
        ('gerant', 'Gerant_Pharmacie'),
        ('client', 'consomateur'),
    ]
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='filleuls')
    telephone = models.CharField(max_length=20)
    pays = models.CharField(max_length=100)
    ville = models.CharField(max_length=100)
    adresse = models.CharField(max_length=255) 
    role = models.CharField(max_length=20, choices=role_user)


    def __str__(self):
        return self.username

    def set_password(self, raw_password):
        # Utilise un hash sécurisé en pratique
        self.password = make_password(raw_password)
        self.save()

    def is_profile_complete(self):
        """
        Vérifie si le profil de l'utilisateur est complet.
        Un profil est considéré complet s'il a un téléphone, un pays, une ville et une adresse.
        """
        return all([
            self.first_name,
            self.telephone,
            self.pays,
            self.ville,
            self.adresse
        ])

class OTP(models.Model):

    """
    Modèle pour stocker les codes OTP (One Time Password) utilisés pour la réinitialisation de mot de passe.
    Champs : compte lié, code OTP, date de création, statut d'utilisation.
    """
     
    utilisateur = models.ForeignKey('Utilisateur', on_delete=models.CASCADE)
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