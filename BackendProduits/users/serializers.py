from rest_framework import serializers
from .models import Utilisateur, Compte
from django.contrib.auth.hashers import make_password

class CompteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Compte
        fields = ['id', 'username', 'is_active']

class UtilisateurSerializer(serializers.ModelSerializer):
    compte = serializers.PrimaryKeyRelatedField(queryset=Compte.objects.all())
    class Meta:
        model = Utilisateur
        fields = ['id', 'compte', 'nom', 'telephone', 'email', 'pays', 'ville', 'adresse', 'role']

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = Compte
        fields = ['username', 'email', 'password']

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)