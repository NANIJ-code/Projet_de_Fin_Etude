from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import *
# from .views import ExportQRCodesPDF
from core.views import QRcodeViewSet

router = DefaultRouter()
# Enregistrement de tous les ViewSets dans le routeur
router.register(r'produits' , ProduitViewSet)
router.register(r'lot_produit', LotProduitViewSet)
router.register(r'unite_produit', UniteProduitViewSet, basename='unite_produit')
router.register(r'qrcodes', QRcodeViewSet)
router.register(r'transaction', TransactionViewSet)
router.register(r'ligne_transaction', LigneTransactionViewSet)
router.register(r'alertes', AlerteViewSet)



urlpatterns = [
    # path('export/', ExportQRCodesPDF.as_view(), name='export_qr_codes'),
    path('', include(router.urls)),
]