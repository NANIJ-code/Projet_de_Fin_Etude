from users.models import Utilisateur
from rest_framework import serializers
from django.core.mail import send_mail
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string


class UtilisateurinitialSerializer(serializers.ModelSerializer):
    """
     serializer pour la creation du profil d'un utilisateur
     Avec des validateurs pour s'assurer que le nom d'utilisateur n'est pas vide et que le rôle est valide.
     Note: La valeur du champ 'role' est dynamique et dépend du rôle de l'utilisateur connecté.
    """
    # role = serializers.ChoiceField(choices=[], required=True)
    class Meta:
        model = Utilisateur
        fields = ['id', 'username', 'email', 'password','role']
        extra_kwargs = {'password': {'write_only': True}}

    def __init__(self, *args, **kwargs):

        """
        La surchage du constructeur __init__ permet de personnaliser les choix du champ 'role' 
        en fonction du rôle de l'utilisateur connecté.
        """
        super(UtilisateurinitialSerializer, self).__init__(*args, **kwargs)
        # Dynamically set the choices for the role field based on the user's role
        utilisateur = self.context['request'].user

        if utilisateur.role == 'fournisseur':
            self.fields['role'].choices = [('distributeur', 'Distributeur'), ('gerant', 'Gerant_Pharmacie')]
        elif utilisateur.role == 'distributeur':
            self.fields['role'].choices = [('gerant', 'Gerant_Pharmacie')]
        else:
            raise serializers.ValidationError("Vous n'avez pas le droit de créer un utilisateur.")
    def validate_role(self, value):
        utilisateur = self.context['request'].user
        if utilisateur.role == 'distributeur' and value != 'gerant':
            raise serializers.ValidationError("Un distributeur ne peut creer que des gerants")
        return value
    

    def validate_username(self, value):
        if not value or value.strip() == "":
            raise serializers.ValidationError("Le nom d'utilisateur ne peut pas être vide.")
        return value
    

    def create(self, validated_data):
        """
            Crée un utilisateur avec un compte associé.
        """
        
        if 'role' not in validated_data or not validated_data['role']:
            raise serializers.ValidationError({"role": "Ce champ est obligatoire."})
    
        utilisateur_connecte = self.context['request'].user
        validated_data['parent'] = utilisateur_connecte  # Associe l'utilisateur connecté comme parent
        
        utilisateur = Utilisateur.objects.create_user(**validated_data)
        utilisateur.is_active = True
        utilisateur.save()

        # Génération d'un token JWT pour l'utilisateur créé
        refresh = RefreshToken.for_user(utilisateur)
        access_token = str(refresh.access_token)
        # Envoi de l'email après création
        login_url = "https://monappflutter.com/auto-login?token={access_token}"  # À adapter selon ton frontend
        # message = (
        #     f"Bienvenue sur notre plateforme **MediScan** !\n\n"
        #     f"Voici vos identifiants de connexion :\n"
        #     f"Nom d'utilisateur : {utilisateur.username}\n"
        #     f"Email : {utilisateur.email}\n"
        #     f"Mot de passe : {validated_data['password']}\n\n"
        #     f" !!!!! Veuillez vous connectez et mettez à jour vos informations avant toute activité !!!!!\n\n"
        #     # En production, il vaut mieux éviter cela et préférer un lien d’activation ou de réinitialisation.
        #     f"Connectez-vous ici : {login_url}"
        # )

        # send_mail(
        #     subject="Création de votre compte",
        #     message=message,
        #     from_email=settings.DEFAULT_FROM_EMAIL,
        #     recipient_list=[utilisateur.email],
        #     fail_silently=True,
        # )

        html_content = render_to_string('emails/creation_compte.html', {
            'username': utilisateur.username,
            'email': utilisateur.email,
            'password': validated_data['password'],
            'login_url': login_url,
        })
        email = EmailMultiAlternatives(
            subject="Création de votre compte MediScan",
            body=".",  # texte fallback
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[utilisateur.email],
        )
        email.attach_alternative(html_content, "text/html")
        email.send()

        return utilisateur


class UtilisateurSerializer(serializers.ModelSerializer):
    """"
    Permet de mettre à jour les informations personnelles de l'utilisateur sans modifier le rôle et le username
    """
    class Meta:
        model = Utilisateur
        fields = ['username', 'first_name' ,'telephone', 'pays', 'ville', 'adresse', 'role']
        read_only_fields = ['role','username']  # Empêche la modification du rôle lors de la mise à jour

    def update(self, instance, validated_data):

        # On retire 'role' des données pour empêcher sa modification
        validated_data.pop('role', None)

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
