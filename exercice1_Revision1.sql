-- Création de la table ex_chercheur
CREATE TABLE ex_chercheur(
    chercheurId number NOT NULL,
    nom varchar2(50) NOT NULL,
    prenom varchar2(50) NOT NULL,
    adresse varchar2(100) NULL,
    ville varchar2(50) NULL,
    province varchar2(50) DEFAULT 'Québec' NULL,
    telephone char(12) NULL,
    dateEmbauche date DEFAULT sysdate NOT NULL,
    
    -- Contraintes de table
    CONSTRAINT Pk_chercheurId PRIMARY KEY (chercheurId)
);

-- Création de la table ex_affectation
CREATE TABLE ex_affectation(
    chercheurId number NOT NULL,
    projetId number NOT NULL,
    estResponsable char(1) NOT NULL,
    
    -- Contraintes de table
    CONSTRAINT Pk_chercheurIdProjetId PRIMARY KEY (chercheurId, projetId),
    CONSTRAINT Fk_chercheurId FOREIGN KEY (chercheurId) REFERENCES ex_chercheur(chercheurId),
    CONSTRAINT Fk_projetId FOREIGN KEY (projetId) REFERENCES ex_projet(projetId)
);

-- Création de la table ex_projet
CREATE TABLE ex_projet(
    projetId number NOT NULL,
    description varchar(100) NOT NULL,
    dateDebut date NOT NULL,
    dateFin date NULL,
    
    -- Contraintes de table
    CONSTRAINT Pk_projetId PRIMARY KEY (projetId),
    CONSTRAINT dateFInPlusGrandDateDebut CHECK (dateFin >= dateDebut)
);

-- Création de la table emprunt
CREATE TABLE ex_emprunt(
    projetId number NOT NULL,
    equipementId number NOT NULL,
    dateEmprunt date NOT NULL,
    datePrevueRetour date NOT NULL,
    dateReelleRetour date NULL,
    
    -- Contraintes de table
    CONSTRAINT Pk_projetIdEquipementId PRIMARY KEY (projetId, equipementId),
    CONSTRAINT Fk_projetId2 FOREIGN KEY (projetId) REFERENCES ex_projet(projetId),
    CONSTRAINT Fk_equipementId FOREIGN KEY (equipementId) REFERENCES ex_equipement(equipementId),
    CONSTRAINT dateRetourPrevuPlusGrandDateEmprunt CHECK(datePrevueRetour >= dateEmprunt),
    CONSTRAINT dateRetourReellePlusGrandDateEmprunt CHECK(dateReelleRetour >= dateEmprunt)
);

-- création de la table equipement
CREATE TABLE ex_equipement(
    equipementId number NOT NULL,
    nom varchar(30) NOT NULL,
    prix float(2) NOT NULL CHECK ( prix >= 0),
    
    -- Contraintes de table
    CONSTRAINT Pk_equipementId PRIMARY KEY (equipementId)
);


-- Requête de vérification
INSERT INTO ex_chercheur (chercheurId, nom, prenom, adresse, ville, telephone)
    VALUES (1, 'Tremblay', 'Sophie', '125 Gérard-Morrisette', 'Sillery', '418 770-4012');

SELECT * FROM ex_chercheur;
