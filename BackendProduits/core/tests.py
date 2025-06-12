from django.test import TestCase
from rest_framework.test import APIClient
from users.models import Compte, Utilisateur
from core.models import Produit

class ProduitPermissionTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.compte_fournisseur = Compte.objects.create_user(username='f1', password='pass')
        self.utilisateur_fournisseur = Utilisateur.objects.create(compte=self.compte_fournisseur, role='fournisseur')
        self.compte_distributeur = Compte.objects.create_user(username='d1', password='pass')
        self.utilisateur_distributeur = Utilisateur.objects.create(compte=self.compte_distributeur, role='distributeur')

    def test_fournisseur_peut_creer_produit(self):
        self.client.force_authenticate(user=self.compte_fournisseur)
        response = self.client.post('/api_produits/produits/', {'nom': 'Test', 'prix': 10})
        self.assertNotEqual(response.status_code, 403)

    def test_distributeur_ne_peut_pas_creer_produit(self):
        self.client.force_authenticate(user=self.compte_distributeur)
        response = self.client.post('/api_produits/produits/', {'nom': 'Test', 'prix': 10})
        self.assertEqual(response.status_code, 403)