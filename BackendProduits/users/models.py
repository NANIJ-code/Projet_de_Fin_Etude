from django.db import models
from django.db.models import Q
from django.contrib.auth.hashers import make_password

# Create your models here.




class Compte(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True, default="default@exemple.com")  # Ajout du champ email
    password = models.CharField(max_length=128)  # Utiliser un champ sécurisé pour le mot de passe
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.username
    
    def supprimerCompte(self):
        self.delete() 

    def modifierCompte(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)
        self.save()
    
    def set_password(self, raw_password):
        # Utilise un hash sécurisé en pratique
        self.password = make_password(raw_password)
        self.save()


    
# dans la classe 'Utilisateur' nous initions le role de chaque utilisateurs
# le champ 'role' pour indiquer le rôle de l'utilisateur
# le champ 'compte' est une relation OneToOne avec la classe Compte

class Utilisateur(models.Model):

    role_user = [
        ('fournisseur', 'Fournisseur'),
        ('distributeur', 'Distributeur'),
        ('gerant', 'Gerant_Pharmacie'),
    ]
    compte = models.OneToOneField(Compte, on_delete=models.CASCADE, related_name='user')
    nom = models.CharField(max_length=100)
    telephone = models.CharField(max_length=20, unique=True)
    email = models.EmailField(unique=True)
    pays = models.CharField(max_length=100)
    ville = models.CharField(max_length=100)
    adresse = models.CharField(max_length=255) 
    role = models.CharField(max_length=20, choices=role_user)


    def __str__(self):
        return self.nom

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