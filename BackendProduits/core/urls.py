from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ProduitViewSet,AlerteViewSet
from core.views import QRcodeViewSet
from .views import FournisseurViewSet

router = DefaultRouter()
# Enregistrement de tous les ViewSets dans le routeur
<<<<<<< HEAD
router.register(r'produits', ProduitViewSet)
router.register(r'qrcodes', QRcodeViewSet)
router.register(r'fournisseurs', FournisseurViewSet, basename='fournisseur')
=======
router.register(r'produits' , ProduitViewSet)
# router.register(r'qrcodes', QRcodeViewSet)
# router.register(r'transaction', TransactionViewSet)
router.register(r'alertes', AlerteViewSet)
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49


urlpatterns = [
    path('', include(router.urls)),
]