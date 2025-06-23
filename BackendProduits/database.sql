CREATE DATA BASE contrefacon_db;

\c contrefacon_db;

-- Table Produit
CREATE TABLE core_produit (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    fournisseur_id INTEGER NOT NULL REFERENCES users_utilisateur(id) ON DELETE CASCADE,
    prix NUMERIC(10,2) NOT NULL,
    description VARCHAR(255) DEFAULT ''
);

-- Table LotProduit
CREATE TABLE core_lotproduit (
    numero_lot VARCHAR(50) PRIMARY KEY,
    produit_id INTEGER NOT NULL REFERENCES core_produit(id) ON DELETE CASCADE,
    quantite INTEGER NOT NULL DEFAULT 1,
    date_enregistrement DATE NOT NULL,
    date_expiration DATE NOT NULL,
    qr_code VARCHAR(100)  
);

-- Table UniteProduit
CREATE TABLE core_uniteproduit (
    id SERIAL PRIMARY KEY,
    uuid_produit UUID NOT NULL UNIQUE,
    lot_id VARCHAR(50) NOT NULL REFERENCES core_lotproduit(numero_lot) ON DELETE CASCADE,
    position VARCHAR(255) DEFAULT '',
    is_active BOOLEAN DEFAULT TRUE
);

-- Table QRcode
CREATE TABLE core_qrcode (
    id SERIAL PRIMARY KEY,
    unite_produit_id INTEGER NOT NULL UNIQUE REFERENCES core_uniteproduit(id) ON DELETE CASCADE,
    image VARCHAR(100)  
);

-- Table Alerte
CREATE TABLE core_alerte (
    id SERIAL PRIMARY KEY,
    lot_id VARCHAR(50) REFERENCES core_lotproduit(numero_lot) ON DELETE CASCADE,
    message TEXT NOT NULL,
    date_alerte TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Table Transaction
CREATE TABLE core_transaction (
    id SERIAL PRIMARY KEY,
    emetteur VARCHAR(255) NOT NULL,
    destinataire VARCHAR(255) NOT NULL,
    date_creation TIMESTAMP WITH TIME ZONE NOT NULL,
    type_transaction VARCHAR(50) NOT NULL
);

-- Table ligne_transaction
CREATE TABLE core_ligne_transaction (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES core_transaction(id) ON DELETE CASCADE,
    produit_id INTEGER NOT NULL REFERENCES core_produit(id) ON DELETE CASCADE,
    quantite_totale INTEGER NOT NULL
);


------------------------------------------------

-- Table Compte (hérite de AbstractUser, donc reprend la structure standard Django)
CREATE TABLE users_compte (
    id SERIAL PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    is_superuser BOOLEAN NOT NULL,
    username VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(150) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL,
    is_staff BOOLEAN NOT NULL,
    is_active BOOLEAN NOT NULL,
    date_joined TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Table Utilisateur
CREATE TABLE users_utilisateur (
    id SERIAL PRIMARY KEY,
    compte_id INTEGER NOT NULL UNIQUE REFERENCES users_compte(id) ON DELETE CASCADE,
    nom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    pays VARCHAR(100) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);

-- Table OTP
CREATE TABLE users_otp (
    id SERIAL PRIMARY KEY,
    compte_id INTEGER NOT NULL REFERENCES users_compte(id) ON DELETE CASCADE,
    code VARCHAR(6) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT FALSE
);