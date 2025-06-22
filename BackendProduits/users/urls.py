# users/urls.py
from rest_framework.routers import DefaultRouter
from django.urls import path
from .views import CompteViewSet, UtilisateurViewSet, FournisseurViewSet, RoleListAPIView, RegisterAPIView

router = DefaultRouter()
router.register(r'comptes', CompteViewSet, basename='compte')
router.register(r'utilisateurs', UtilisateurViewSet, basename='utilisateur')
router.register(r'fournisseurs', FournisseurViewSet, basename='fournisseur')

urlpatterns = router.urls

urlpatterns += [
    path('roles/', RoleListAPIView.as_view(), name='roles-list'),
    path('register/', RegisterAPIView.as_view(), name='register'),
]