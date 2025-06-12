from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ProduitViewSet,AlerteViewSet
from core.views import QRcodeViewSet

router = DefaultRouter()
# Enregistrement de tous les ViewSets dans le routeur
router.register(r'produits' , ProduitViewSet)
# router.register(r'qrcodes', QRcodeViewSet)
# router.register(r'transaction', TransactionViewSet)
router.register(r'alertes', AlerteViewSet)


urlpatterns = [
    path('', include(router.urls)),
]