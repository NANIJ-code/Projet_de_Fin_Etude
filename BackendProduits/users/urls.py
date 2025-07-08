from django.urls import path, include
from rest_framework.routers import DefaultRouter
from users.views import UtilisateurViewSet
from users.views import CustomLoginView
from users.views import OTPRequestView,  PasswordResetView



router = DefaultRouter()
# Création d'un routeur pour enregistrer les ViewSets
router.register(r'utilisateurs', UtilisateurViewSet, basename='utilisateur')


urlpatterns = [
    path('', include(router.urls)),
    path('login/', CustomLoginView.as_view(), name='custom_login'),
    path('password-reset/request/', OTPRequestView.as_view(), name='password_reset_request'),
    path('password-reset/confirm/', PasswordResetView.as_view(), name='password_reset_confirm'),
]