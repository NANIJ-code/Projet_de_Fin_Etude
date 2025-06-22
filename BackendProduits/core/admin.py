from django.contrib import admin
from .models import *

# Register your models here.
<<<<<<< HEAD
for model in [Produit, QRcode, Alerte, Transaction]:  # Ajoute ici tous les modèles de core/models.py
    admin.site.register(model)
=======
admin.site.register(Produit)
admin.site.register(QRcode)
admin.site.register(Alerte)
admin.site.register(Transaction)
admin.site.register(ligne_transaction)
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49
