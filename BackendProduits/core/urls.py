from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ProduitViewSet
from core.views import QRcodeViewSet
from .views import FournisseurViewSet

router = DefaultRouter()
# Enregistrement de tous les ViewSets dans le routeur
router.register(r'produits', ProduitViewSet)
router.register(r'qrcodes', QRcodeViewSet)
router.register(r'fournisseurs', FournisseurViewSet, basename='fournisseur')


urlpatterns = [
    path('', include(router.urls)),
]