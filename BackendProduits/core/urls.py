from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ProduitViewSet
from core.views import QRcodeViewSet

router = DefaultRouter()
# Enregistrement de tous les ViewSets dans le routeur
router.register(r'produits', ProduitViewSet)
router.register(r'qrcodes', QRcodeViewSet)


urlpatterns = [
    path('', include(router.urls)),
]