from django.contrib import admin
from .models import *

# Register your models here.
admin.site.register(Produit)
admin.site.register(LotProduit)
admin.site.register(UniteProduit)
admin.site.register(QRcode)
admin.site.register(Alerte)
admin.site.register(Transaction)
admin.site.register(ligne_transaction)
