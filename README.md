# Projet_de_Fin_D-Etude


## Résumé du projet

**Application de détection de médicaments contrefaits**

Ce projet vise à lutter contre la circulation de médicaments contrefaits au Cameroun, en proposant une application mobile et web permettant aux utilisateurs de vérifier l’authenticité et la traçabilité des médicaments grâce à des QR codes sécurisés. Le système couvre l’ensemble de la chaîne de distribution, du fournisseur au consommateur final, en assurant le suivi des transactions à chaque étape.

L’application repose sur une interface web développée avec Flutter et une API backend Django connectée à une base de données PostgreSQL. Chaque médicament est enregistré par le fournisseur, qui génère un QR code unique. À chaque étape (fournisseur, dépôt, pharmacie), le médicament est scanné et son mouvement enregistré. Le consommateur peut consulter, via le scan, toutes les informations essentielles : fournisseur, date d’expiration, origine, historique de distribution.

Le système détecte efficacement les anomalies (scans suspects, doublons de QR code, transferts non validés) et permet le signalement d’alertes. Cette solution renforce la confiance dans la chaîne pharmaceutique et constitue un outil concret de lutte contre la contrefaçon.

## Installation

1. **Prérequis**  
   - [Flutter](https://flutter.dev/docs/get-started/install) (pour l’interface mobile/web)
   - [Python 3.13.3](https://www.python.org/downloads/) et [Django](https://www.djangoproject.com/)
   - [PostgreSQL 15](https://www.postgresql.org/download/)

2. **Installation du Backend**
   ```bash
   cd backend
   python -m venv excellent   # création d'un environnement virtuel
   source venv/bin/activate   # Activation de l'environnement
   pip install django         # Installation de Django
   django-admin startproject BackendProduits  # Création du projet Django
   python mmanage.py startapp core   # Création d'une application du projet
   pip install -r requirements.txt   # Installation des modules et dépendances python nécessaies pour le projet
   python manage.py makemigrations   # Mise place des migrations issues des modifications
   python manage.py migrate          # Migrations 
   python manage.py runserver        # Démarrage du serveur Django

3. **Installation du Frontend**
   ```bash
   cd frontend
   flutter pub get
   flutter run -d chrome  # Pour le web
   flutter run            # Pour le mobile (choisir le device)

5. **Configuration**
   Renseigner les paramètres de connexion à la base de données dans le backend.
Adapter l’URL de l’API dans la configuration Flutter.

## Utilisation
- Fournisseur : Enregistre les médicaments et génère les QR codes.
- Dépôt/Pharmacie : Scanne les médicaments à chaque transfert.
- Consommateur : Scanne le QR code pour vérifier l’authenticité et consulter l’historique.
  
## Exemple de parcours utilisateur
+ Le fournisseur crée un médicament → QR code généré et apposé.
+ À chaque étape de la chaîne, le médicament est scanné → historique mis à jour.
+ Le consommateur scanne le QR code avec l’application → affiche les détails et l’historique.

## Fonctionnalités principales
- Génération et gestion de QR codes uniques pour chaque unité de médicament
- Suivi complet du médicament à chaque étape de la chaîne
- Interface web et mobile conviviale (Flutter)
- Détection automatique des anomalies (scans, doublons, transferts)
- Signalement d’alertes et traçabilité renforcée

## Organisation du projet
- BackendProduits/ : Backend Django (API REST, connexion PostgreSQL)
- FrontendProduits/ : Application Flutter (mobile et web)
- docs/ : Documentation technique et fonctionnelle
- README.md : Présentation du projet
- requirements.txt: Liste des dépendances Python à installer

## Contribution

Toute contribution est la bienvenue !  
**Note : Ce dépôt est privé. Seules les personnes ayant reçu un accès peuvent forker ou contribuer.**

Pour contribuer :
1. Forkez ce dépôt (si vous y avez accès).
2. Créez une branche (`git checkout -b ma-feature`).
3. Commitez vos modifications (`git commit -am 'Ajout d'une nouvelle fonctionnalité'`).
4. Poussez la branche (`git push origin ma-feature`).
5. Ouvrez une Pull Request.
   
Pour toute question ou suggestion, contactez l’équipe.

## Licence
Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## Contact
- nanchiivan65@gmail.com
- pavelfeussi@gmail.com
- tadonkengcoretta@gmail.com

