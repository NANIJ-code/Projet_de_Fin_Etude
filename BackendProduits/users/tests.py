from django.test import TestCase
from rest_framework.test import APIClient
from users.models import Compte, Utilisateur
from django.contrib.auth.hashers import make_password

"""
    Tests pour les permissions des utilisateurs dans l'API
    Ces tests vérifient que les fournisseurs et distributeurs peuvent créer des utilisateurs avec les rôles appropriés.
"""
class UtilisateurPermissionTest(TestCase):
    def setUp(self):
        """
        Configuration initiale pour les tests.
        Création de comptes et utilisateurs pour les rôles fournisseur et distributeur.
        """
        self.client = APIClient()
        self.compte_fournisseur = Compte.objects.create(username='stagexTech', email='tadonkencoretta@gmail.com', password=make_password('tadonkencoretta'))
        self.utilisateur_fournisseur = Utilisateur.objects.create(compte=self.compte_fournisseur, role='fournisseur')
        self.compte_distributeur = Compte.objects.create(username='d1', email='tadonkencoretta11@gmail.com', password=make_password('stagexTech'))
        self.utilisateur_distributeur = Utilisateur.objects.create(compte=self.compte_distributeur, role='distributeur')

    def test_fournisseur_peut_creer_distributeur(self):
        self.client.force_authenticate(user=self.compte_fournisseur)
        data = {
            "compte": {"username": "d2", "email": "d2@mail.com", "password": "pass"},
            "role": "distributeur"
        }
        response = self.client.post('/api_user/utilisateurs/', data, format='json')
        self.assertNotEqual(response.status_code, 403)

    def test_fournisseur_ne_peut_pas_creer_fournisseur(self):
        self.client.force_authenticate(user=self.compte_fournisseur)
        data = {
            "compte": {"username": "f2", "email": "f2@mail.com", "password": "pass"},
            "role": "fournisseur"
        }
        response = self.client.post('/api_user/utilisateurs/', data, format='json')
        self.assertEqual(response.status_code, 403)

    def test_distributeur_peut_creer_gerant(self):
        self.client.force_authenticate(user=self.compte_distributeur)
        data = {
            "compte": {"username": "g1", "email": "g1@mail.com", "password": "pass"},
            "role": "gerant"
        }
        response = self.client.post('/api_user/utilisateurs/', data, format='json')
        self.assertNotEqual(response.status_code, 403)

    def test_distributeur_ne_peut_pas_creer_distributeur(self):
        self.client.force_authenticate(user=self.compte_distributeur)
        data = {
            "compte": {"username": "d3", "email": "d3@mail.com", "password": "pass"},
            "role": "distributeur"
        }
        response = self.client.post('/api_user/utilisateurs/', data, format='json')
        self.assertEqual(response.status_code, 403)