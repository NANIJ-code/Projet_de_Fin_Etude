CREATE DATA BASE contrefacon_db;

\c contrefacon_db;

CREATE TABLE users_utilisateur (
    id SERIAL PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    is_superuser BOOLEAN NOT NULL,
    username VARCHAR(150) UNIQUE NOT NULL,
    first_name VARCHAR(150) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL,
    is_staff BOOLEAN NOT NULL,
    is_active BOOLEAN NOT NULL,
    date_joined TIMESTAMP WITH TIME ZONE NOT NULL,
    parent_id INTEGER REFERENCES users_utilisateur(id),
    telephone VARCHAR(20) NOT NULL,
    pays VARCHAR(100) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);


CREATE TABLE users_otp (
    id SERIAL PRIMARY KEY,
    utilisateur_id INTEGER NOT NULL REFERENCES users_utilisateur(id),
    code VARCHAR(6) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN NOT NULL
);



CREATE TABLE core_produit (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    fournisseur_id INTEGER NOT NULL REFERENCES users_utilisateur(id),
    prix NUMERIC(10,2) NOT NULL,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE core_lotproduit (
    numero_lot VARCHAR(50) PRIMARY KEY,
    produit_id INTEGER NOT NULL REFERENCES core_produit(id),
    quantite INTEGER NOT NULL,
    date_enregistrement DATE NOT NULL,
    date_expiration DATE NOT NULL,
    qr_code VARCHAR(100)
);



CREATE TABLE core_uniteproduit (
    id SERIAL PRIMARY KEY,
    uuid_produit UUID UNIQUE NOT NULL,
    lot_id VARCHAR(50) NOT NULL REFERENCES core_lotproduit(numero_lot),
    position VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE core_qrcode (
    id SERIAL PRIMARY KEY,
    unite_produit_id INTEGER UNIQUE NOT NULL REFERENCES core_uniteproduit(id),
    image VARCHAR(100) NOT NULL
);



CREATE TABLE core_alerte (
    id SERIAL PRIMARY KEY,
    lot_id VARCHAR(50) REFERENCES core_lotproduit(numero_lot),
    message TEXT NOT NULL,
    unite_id INTEGER REFERENCES core_uniteproduit(id),
    emetteur_id INTEGER NOT NULL REFERENCES users_utilisateur(id),
    destinataire_id INTEGER NOT NULL REFERENCES users_utilisateur(id),
    date_alerte TIMESTAMP WITH TIME ZONE NOT NULL
);



CREATE TABLE core_transaction (
    id SERIAL PRIMARY KEY,
    emetteur_id INTEGER NOT NULL REFERENCES users_utilisateur(id),
    destinataire_id INTEGER NOT NULL REFERENCES users_utilisateur(id),
    date_creation TIMESTAMP WITH TIME ZONE NOT NULL,
    type_transaction VARCHAR(50) NOT NULL
);


CREATE TABLE core_ligne_transaction (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES core_transaction(id),
    produit_id INTEGER NOT NULL REFERENCES core_produit(id),
    quantite_totale INTEGER NOT NULL
);


CREATE TABLE core_ligne_transaction_lots (
    id SERIAL PRIMARY KEY,
    ligne_transaction_id INTEGER NOT NULL REFERENCES core_ligne_transaction(id),
    lotproduit_id VARCHAR(50) NOT NULL REFERENCES core_lotproduit(numero_lot)
);
