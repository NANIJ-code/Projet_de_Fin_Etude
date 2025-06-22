from django.shortcuts import render
<<<<<<< HEAD
from rest_framework import viewsets
from .models import Utilisateur, Compte
from .serializers import UtilisateurSerializer, CompteSerializer
from django.db.models import Q
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import RegisterSerializer

# Create your views here.

class UtilisateurViewSet(viewsets.ModelViewSet):
    queryset = Utilisateur.objects.all()
    serializer_class = UtilisateurSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(nom__icontains=search) |
                Q(pays__icontains=search) |
                Q(ville__icontains=search) |
                Q(role__icontains=search)
            )
        return queryset
class CompteViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Compte.objects.all()
    serializer_class = CompteSerializer
    
class FournisseurViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = UtilisateurSerializer

    def get_queryset(self):
        return Utilisateur.objects.filter(role='fournisseur')
    
class RoleListAPIView(APIView):
    def get(self, request):
        roles = [r[0] for r in Utilisateur.role_user]
        labels = [r[1] for r in Utilisateur.role_user]
        return Response([{'value': v, 'label': l} for v, l in zip(roles, labels)])

class RegisterAPIView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Compte créé avec succès'}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
=======
from .models import Utilisateur, Compte, OTP
from rest_framework.response import Response
from .serializers import UtilisateurSerializer, CompteSerializer, UtilisateurinitialSerializer
from .serializers import OTPRequestSerializer, OTPVerifySerializer, PasswordResetSerializer
import random
from django.core.cache import cache
from rest_framework import viewsets
from users.permission import UtilisateurPermission
from django.contrib.auth.hashers import check_password
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.views import APIView
from rest_framework import status
from django.core.mail import send_mail
from django.conf import settings


class CompteViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour le modèle Compte.
    """
    queryset = Compte.objects.all()
    serializer_class = CompteSerializer
    # permission_classes = [IsAuthenticated]  # Assurez-vous que l'utilisateur est authentifié

    def get_queryset(self):
        return self.queryset.filter(is_active=True)  # Filtrer les comptes actifs
    
    def supprimer_compte(self, request, pk=None):
        """
        Supprimer un compte par son ID.
        """
        compte = self.get_object()
        compte.delete()
        return Response({"message": "Compte supprimé avec succès!"}, status=204)
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class UtilisateurViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour le modèle Utilisateur.
    """
    queryset = Utilisateur.objects.all()
    serializer_class = UtilisateurSerializer
    initial_serializer_class = UtilisateurSerializer  # Serializer pour la création initiale
    permission_classes = [UtilisateurPermission]  # Assurez-vous que l'utilisateur est authentifié

    def get_serializer_class(self):
        if self.action == 'create':
            return UtilisateurinitialSerializer
        return UtilisateurSerializer
    def get_queryset(self):
        return self.queryset.filter(compte__is_active=True)  # Filtrer les utilisateurs actifs
    
    def rechercher(self, request):
        """
        Recherche d'utilisateurs par mot clé dans le nom ou nom d'utiliateur.
        """
        mot_cle = request.query_params.get('q', '')
        utilisateurs = self.queryset.filter(nom__icontains=mot_cle)
        
        if not utilisateurs.exists():
            return Response({"message": "Aucun utilisateur trouvé!"}, status=404)
        
        serializer = self.get_serializer(utilisateurs, many=True)
        return Response(serializer.data)

    # Dans une vue ou ViewSet
    def update(self, request, *args, **kwargs):
        utilisateur = request.user.user
        utilisateur.nom = request.data.get('nom', utilisateur.nom)
        utilisateur.telephone = request.data.get('telephone', utilisateur.telephone)
        utilisateur.pays = request.data.get('pays', utilisateur.pays)
        utilisateur.ville = request.data.get('ville', utilisateur.ville)
        utilisateur.adresse = request.data.get('adresse', utilisateur.adresse)
        utilisateur.save()
        return Response({"message": "Profil mis à jour"})



class CustomLoginView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        try:
            compte = Compte.objects.get(username=username)
        except Compte.DoesNotExist:
            return Response({"detail": "Identifiants invalides"}, status=status.HTTP_401_UNAUTHORIZED)
        if not compte.is_active:
            return Response({"detail": "Compte inactif"}, status=status.HTTP_401_UNAUTHORIZED)
        if not check_password(password, compte.password):
            return Response({"detail": "Identifiants invalides"}, status=status.HTTP_401_UNAUTHORIZED)
        # Générer le token JWT
        refresh = RefreshToken.for_user(compte)
        return Response({
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        })
    

class OTPRequestView(APIView):

    """
        Vue API pour demander un code OTP par email.

        POST:
            - Reçoit un email via le serializer.
            - Vérifie l'existence du compte associé à l'email.
            - Génère un code OTP à 6 chiffres.
            - Enregistre le code OTP et l'envoie par email à l'utilisateur.
            - Retourne une réponse de succès ou d'erreur si l'email n'existe pas.
    """
     
    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        try:
            compte = Compte.objects.get(email=email)
        except Compte.DoesNotExist:
            return Response({"detail": "Aucun compte avec cet email."}, status=404)
        code = f"{random.randint(100000, 999999)}"
        OTP.objects.create(compte=compte, code=code)
        send_mail(
            subject="Votre code OTP PharmaTrack",
            message=f"Votre code OTP est : {code}\nIl expire dans 10 minutes.",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
            fail_silently=False,
        )
        return Response({'detail': 'OTP envoyé à votre email.'})


class PasswordResetView(APIView):

    """
    Vue API pour réinitialiser le mot de passe via OTP.

    POST:
        - Reçoit un email, un code OTP et un nouveau mot de passe via le serializer.
        - Vérifie l'existence du compte et du code OTP utilisé.
        - Vérifie la validité du code OTP.
        - Met à jour le mot de passe du compte si tout est valide.
        - Retourne une réponse de succès ou d'erreur selon la validité.
    """
    def post(self, request):
        serializer = PasswordResetSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        otp = serializer.validated_data['otp']
        new_password = serializer.validated_data['new_password']
        try:
            compte = Compte.objects.get(email=email)
            otp_obj = OTP.objects.filter(compte=compte, code=otp, is_used=False).latest('created_at')
        except (Compte.DoesNotExist, OTP.DoesNotExist):
            return Response({"detail": "OTP ou email invalide."}, status=400)
        if not otp_obj.is_valid():
            return Response({"detail": "OTP expiré ou déjà utilisé."}, status=400)
        compte.set_password(new_password)
        compte.save()
        # Marque l'OTP comme utilisé
        otp_obj.is_used = True
        otp_obj.save()
        return Response({'detail': 'Mot de passe réinitialisé avec succès.'})
>>>>>>> c30bdadf5507b66cdb49b7bca5ddf2553c8b0e49
