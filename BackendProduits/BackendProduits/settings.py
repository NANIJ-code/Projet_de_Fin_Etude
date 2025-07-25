"""
Django settings for BackendProduits project.

Generated by 'django-admin startproject' using Django 5.2.1.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.2/ref/settings/
"""

from pathlib import Path
import os
from datetime import timedelta

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-ls=)e%wpdj6q!(drb5%jww9ghx5d--=sk0ewv9n71_0w+h9&$v'

# SECURITY WARNING: don't run with debug turned on in production! 
# !!!!! Autoriser toutes les adresses IP pour le développement local, a modifier pour le deploiement
# CORS_ALLOW_ALL_ORIGINS = ['https://nom-de-domaine.com']
# Application definition
DEBUG = False
ALLOWED_HOSTS = ['13.50.196.155']
CORS_ALLOWED_ORIGINS = ['http://13.50.196.155']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'core', 
    # core l'application principale de gestion des produist
    'corsheaders',  
    # Activer la communication entre le frontend et le backend
    'rest_framework_simplejwt',
    # Authentification JWT pour l'API REST
    'rest_framework',  
    # API REST
    'users',  
    # Application pour la gestion des utilisateurs
]

""" Configuration REST Framework 
    https://www.django-rest-framework.org/api-guide/settings/
    - Utilisation de l'authentification JWT par defaut pour toutes les vues DRF
    - Taille de page par défaut de 100 éléments
# """
REST_FRAMEWORK = {
    # 'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    # 'PAGE_SIZE': 100,
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # Middleware pour CORS
]

ROOT_URLCONF = 'BackendProduits.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / "templates"],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'BackendProduits.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }

# Connexion à la base de données PostgreSQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'contrefacon_db',
        'USER': 'postgres',
        'PASSWORD': '123456', 
        # Mot de passe a modifier lors du deploiement
        'HOST': 'localhost',
        'PORT': '5432',
    }
}



# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# modèle utilisateur personnalisé
AUTH_USER_MODEL = 'users.Utilisateur'

# !!!!!!!!!!!!!!!!!! A  modifier !!!!!!!!!!!!!!!!!!!!!!!!!
FRONTEND_LOGIN_URL = "https://monappflutter.com/"  # ou l'URL de ton frontend

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),  # Par défaut 5 min, à adapter
    "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
}

# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
# Indication du répertoire de fichiers statiques

# Indication du répertoire de fichiers des media
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

CORS_ALLOW_ALL_ORIGINS = True  
# !!!! Autoriser toutes les origines pour le développement local, le desactiver pour le deploiement

# CORS_ALLOW_CREDENTIALS = True  
# # Autoriser les cookies et les en-têtes d'authentification


# configuration pour envoie des mails
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = '587'
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'mediscan814@gmail.com'
EMAIL_HOST_PASSWORD = 'fbua jmjb kzgu qemh'
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
