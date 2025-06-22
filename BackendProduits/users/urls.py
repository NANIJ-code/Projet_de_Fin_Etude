<<<<<<< HEAD
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
=======
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from users.views import UtilisateurViewSet, CompteViewSet
from users.views import CustomLoginView
from users.views import OTPRequestView,  PasswordResetView



router = DefaultRouter()
# Création d'un routeur pour enregistrer les ViewSets
router.register(r'comptes', CompteViewSet, basename='compte')
router.register(r'utilisateurs', UtilisateurViewSet, basename='utilisateur')
# router.register(r'comptes', CompteViewSet, basename='compte')


urlpatterns = [
    path('', include(router.urls)),
    path('login/', CustomLoginView.as_view(), name='custom_login'),
    path('password-reset/request/', OTPRequestView.as_view(), name='password_reset_request'),
    path('password-reset/confirm/', PasswordResetView.as_view(), name='password_reset_confirm'),
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49
]