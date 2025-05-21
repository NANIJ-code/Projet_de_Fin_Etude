from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.api.view import ProduitViewSet
# from core.api.view import QRcodeViewSet

router = DefaultRouter()
router.register(r'produits', ProduitViewSet, basename='produit')
# router.register(r'qrcodes', QRcodeViewSet, basename='qrcode')


urlpatterns = [
    path('', include(router.urls)),
]