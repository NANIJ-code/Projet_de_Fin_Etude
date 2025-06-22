from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsFournisseurPermission(BasePermission):
    """
    Seuls les fournisseurs authentifiés peuvent créer, modifier ou supprimer un produit.
    Les autres peuvent seulement lire.
    """
    def has_permission(self, request, view):
        # Lecture autorisée à tous
        if request.method in SAFE_METHODS:
            return True
        # Création/modification/suppression réservées aux fournisseurs authentifiés
        utilisateur = getattr(request.user, 'user', None)
        return (
            request.user.is_authenticated and
            utilisateur is not None and
            getattr(utilisateur, 'role', None) == 'fournisseur'
        )