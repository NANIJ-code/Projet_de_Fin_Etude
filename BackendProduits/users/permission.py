from rest_framework.permissions import BasePermission, SAFE_METHODS

class UtilisateurPermission(BasePermission):
    """
    - Fournisseur : peut gérer (créer/modifier/supprimer) tout utilisateur sauf les fournisseurs.
    - Distributeur : peut gérer uniquement les utilisateurs de rôle 'gerant'.
    """
    def has_permission(self, request, view):
        # Lecture autorisée à tous les authentifiés
        if request.method in SAFE_METHODS:
            return request.user.is_authenticated

        utilisateur = getattr(request.user, 'user', None)
        if not (request.user.is_authenticated and utilisateur):
            return False

        if utilisateur.role == 'fournisseur':
            return True  # Fournisseur peut créer n'importe quel utilisateur
        if utilisateur.role == 'distributeur':
            # Distributeur peut créer seulement des 'gerant'
            data = request.data
            return data.get('role') == 'gerant'
        return False

    def has_object_permission(self, request, view, obj):
        utilisateur = getattr(request.user, 'user', None)
        if not (request.user.is_authenticated and utilisateur):
            return False

        if utilisateur.role == 'fournisseur':
            # Fournisseur ne peut pas modifier/supprimer un autre fournisseur
            return obj.role != 'fournisseur'
        if utilisateur.role == 'distributeur':
            # Distributeur ne peut modifier/supprimer que les 'gerant'
            return obj.role == 'gerant'
        return False