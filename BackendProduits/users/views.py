from django.shortcuts import render
from .models import Utilisateur, OTP
from rest_framework.response import Response
from .serializers import UtilisateurSerializer, UtilisateurinitialSerializer
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
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string


#########################################################
                #FONCTIONS#
#########################################################

# def check_profile_complete(self, request):
#     utilisateur= request.user
#     if not utilisateur.is_profile_complete():
#         raise PermissionDenied(
#             "Votre profil n'est pas complet. Veuillez le compléter avant de continuer."
#         )


#########################################################
                #Classes#
#########################################################
class UtilisateurViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour le modèle Utilisateur.
    """
    queryset = Utilisateur.objects.all()
    serializer_class = UtilisateurSerializer
    # permission_classes = [UtilisateurPermission]  # Assurez-vous que l'utilisateur est authentifié

    def get_serializer_class(self):
        if self.action == 'create':
            return UtilisateurinitialSerializer
        return UtilisateurSerializer
    def get_queryset(self):
        """
        Filtre les utilisateurs pour ne retourner que ceux dont le parent est l'utilisateur connecté.
        """
        utilisateur = self.request.user
        return self.queryset.filter(parent = utilisateur) 
    
    def rechercher(self, request):
        """
        Recherche d'utilisateurs par mot clé dans le nom ou nom d'utiliateur.
        """
        mot_cle = request.query_params.get('q', '')
        utilisateurs = self.queryset.filter(username__icontains=mot_cle)
        
        if not utilisateurs.exists():
            return Response({"message": "Aucun utilisateur trouvé!"}, status=404)
        
        serializer = self.get_serializer(utilisateurs, many=True)
        return Response(serializer.data)

    # Dans une vue ou ViewSet
    def update(self, request, *args, **kwargs):
        utilisateur = request.user
        utilisateur.first_name = request.data.get('first_name', utilisateur.first_name)
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
            utilisateur = Utilisateur.objects.get(username=username)
        except Utilisateur.DoesNotExist:
            return Response({"detail": "Identifiants invalides"}, status=status.HTTP_401_UNAUTHORIZED)
        if not utilisateur.is_active:
            return Response({"detail": "Utilisateur inactif"}, status=status.HTTP_401_UNAUTHORIZED)
        if not check_password(password, utilisateur.password):
            return Response({"detail": "Identifiants invalides"}, status=status.HTTP_401_UNAUTHORIZED)
        # Générer le token JWT
        refresh = RefreshToken.for_user(utilisateur)
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
            utilisateur = Utilisateur.objects.get(email=email)
        except Utilisateur.DoesNotExist:
            return Response({"detail": "Aucun utilisateur avec cet email."}, status=404)
        code = f"{random.randint(100000, 999999)}"
        OTP.objects.create(utilisateur=utilisateur, code=code)
        # send_mail(
        #     subject="Votre code OTP PharmaTrack",
        #     message=f"Votre code OTP est : {code}\nIl expire dans 10 minutes.",
        #     from_email=settings.DEFAULT_FROM_EMAIL,
        #     recipient_list=[email],
        #     fail_silently=False,
        # )
        html_content = render_to_string('emails/otp_email.html', {
            'otp_code': code,
        })
        email = EmailMultiAlternatives(
            subject = "Votre code OTP MediScan",
            body = f"Votre code OTP est : {code}\nIl expire dans 10 minutes.",
            from_email = settings.DEFAULT_FROM_EMAIL,
            to = [email],
        )
        email.attach_alternative(html_content, "text/html")
        email.send()

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
            utilisateur = Utilisateur.objects.get(email=email)
            otp_obj = OTP.objects.filter(utilisateur=utilisateur, code=otp, is_used=False).latest('created_at')
        except (Utilisateur.DoesNotExist, OTP.DoesNotExist):
            return Response({"detail": "OTP ou email invalide."}, status=400)
        if not otp_obj.is_valid():
            return Response({"detail": "OTP expiré ou déjà utilisé."}, status=400)
        utilisateur.set_password(new_password)
        utilisateur.save()
        # Marque l'OTP comme utilisé
        otp_obj.is_used = True
        otp_obj.save()
        return Response({'detail': 'Mot de passe réinitialisé avec succès.'})