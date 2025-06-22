from django.contrib import admin
from .models import *

# Register your models here.
for model in [Produit, QRcode, Alerte, Transaction]:  # Ajoute ici tous les modèles de core/models.py
    admin.site.register(model)
