from django.shortcuts import render
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
