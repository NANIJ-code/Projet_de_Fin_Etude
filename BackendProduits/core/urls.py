from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ProduitViewSet
# from core.api.view import QRcodeViewSet

router = DefaultRouter()
router.register(r'produits', ProduitViewSet)
# router.register(r'qrcodes', QRcodeViewSet, basename='qrcode')


urlpatterns = [
    path('', include(router.urls)),
]