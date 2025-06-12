from users.models import Utilisateur
from users.models import Compte
from rest_framework import serializers
from django.core.mail import send_mail
from django.conf import settings

class CompteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Compte
        fields = ['id', 'username', 'email', 'password', 'is_active']
        extra_kwargs = {'password': {'write_only': True}}
        # ici le password est en lecture seule pour des raisons de sécurité
        # et ne sera pas renvoyé dans les réponses API
        
    def create(self, validated_data):
        compte = Compte(**validated_data)
        compte.set_password(validated_data['password'])
        compte.save()

        # Envoi de l'email après création
        login_url = "https://monappflutter.com/login"  # À adapter selon ton frontend
        message = (
            f"Bienvenue sur notre plateforme **PharmaTrack** !\n\n"
            f"Voici vos identifiants de connexion :\n"
            f"Nom d'utilisateur : {compte.username}\n"
            f"Email : {compte.email}\n"
            f"Mot de passe : {validated_data['password']}\n\n"
            # En production, il vaut mieux éviter cela et préférer un lien d’activation ou de réinitialisation.
            f"Connectez-vous ici : {login_url}"
        )
        send_mail(
            subject="Création de votre compte",
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[compte.email],
            fail_silently=False,
        )
        return compte

class UtilisateurinitialSerializer(serializers.ModelSerializer):
    compte = CompteSerializer()
    class Meta:
        model = Utilisateur
        fields = ['compte','role']
    def create(self, validated_data):
        """
            Crée un utilisateur avec un compte associé.
        """
        compte_data = validated_data.pop('compte')
        compte = CompteSerializer.create(CompteSerializer(), validated_data=compte_data)
        utilisateur = Utilisateur.objects.create(compte=compte, **validated_data)
        return utilisateur


class UtilisateurSerializer(serializers.ModelSerializer):
    compte = CompteSerializer()

    class Meta:
        model = Utilisateur
        fields = ['id', 'compte', 'nom', 'telephone', 'pays', 'ville', 'adresse', 'role']
        read_only_fields = ['role']  # Empêche la modification du rôle lors de la mise à jour

    def update(self, instance, validated_data):

        # On retire 'role' des données pour empêcher sa modification
        validated_data.pop('role', None)
        compte_data = validated_data.pop('compte', None)
        if compte_data:
            compte_serializer = CompteSerializer(instance.compte, data=compte_data, partial=True)
            if compte_serializer.is_valid():
                compte_serializer.save()

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class OTPRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

class OTPVerifySerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)

class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)
    new_password = serializers.CharField()
