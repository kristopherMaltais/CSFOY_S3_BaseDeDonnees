/*DROP TABLE BI_COMMENTAIRES;
DROP TABLE BI_EMPRUNTS;
DROP TABLE BI_ARTICLESAUTEURS;
DROP TABLE BI_AUTEURS;
DROP TABLE BI_COPIESARTICLES;
DROP TABLE BI_ARTICLES;
DROP TABLE BI_MAISONSEDITIONS;
DROP TABLE BI_VENTESPRODUITS;
DROP TABLE BI_TYPEARTICLES;
DROP TABLE BI_VENTES;
DROP TABLE BI_MODESPAIEMENTS;
DROP TABLE BI_MEMBRES;
DROP TABLE BI_TYPESMEMBRES;
DROP TABLE BI_PROVINCES;
DROP TABLE BI_PRODUITS;
DROP TABLE BI_HistoriqueCommentaire;
DROP TABLE BI_TableLog;
/
DROP SEQUENCE seq_EmpruntID;
DROP SEQUENCE seq_NoArticle;
DROP SEQUENCE seq_NoVente;
DROP SEQUENCE seq_logId;
/

/*************************************************
  CRÉATION DES TABLES
**************************************************/
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE TABLE BI_TableLog (
    logId number NOT NULL,
    codeSql number,
    messageErreur varchar(1000),
    erreurBacktrace varchar(1000),
    callStack varchar(1000),
    dateErreur date,
    utilisateur varchar(20),
    
    -- Contriante de table
    CONSTRAINT pk_logId PRIMARY KEY(logId)
);

CREATE TABLE BI_Provinces
(
  ProvCode         char(2) NOT NULL,
  ProvDescFr       varchar2(50) NOT NULL,
  ProvDescEn       varchar2(50) NOT NULL,
  PcTaxeProv       decimal(3,3) NOT NULL,
  PcTaxeFed        decimal(3,3) NOT NULL,
  CONSTRAINT PK_BI_Provinces_ProvCode 
  PRIMARY KEY(ProvCode)
);

CREATE TABLE BI_TypesMembres
(
  TypeMembre        varchar2(20) NOT NULL,
  TypeDescFr        varchar2(50) NOT NULL,
  TypeDescEn        varchar2(50) NOT NULL,
  NbJoursSurEmprunt number(2) NOT NULL,
  CONSTRAINT PK_BI_TypeArticles_TypeMembre
  PRIMARY KEY (TypeMembre)
);

CREATE TABLE BI_TypeArticles
(
  TypeArticle       varchar2(20) NOT NULL,
  TypeArticleDescFr varchar2(80) NOT NULL,
  TypeArticleDescEn varchar2(80) NOT NULL,
  AmendeParJour     number(3,2) NOT NULL,
  CONSTRAINT PK_BI_TypeArticles_TypeArticle
  PRIMARY KEY (TypeArticle)
);

CREATE TABLE BI_MaisonsEditions
(
  MaisonEditionID       number NOT NULL,
  Nom                   varchar2(50) NOT NULL,
  Adresse               varchar2(200) NOT NULL,
  Ville                 varchar2(50) DEFAULT 'Québec'  NOT NULL ,
  CdPostal              char(7) NOT NULL,
  ProvCode              char(2) NOT NULL,
  Pays                  varchar2(50) DEFAULT 'Canada' NOT NULL,
  NOTel                 char(14) NOT NULL,
  NoFax                 char(14),
  Email                 varchar2(100) NOT NULL,
  SiteInternet          varchar2(100),
  Contact               varchar2(50),
  CONSTRAINT CK_MaisonsEditions_CdPostal 
  CHECK (REGEXP_LIKE(CdPostal,'^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$')),
  CONSTRAINT CK_MaisonsEditions_NOTel 
  CHECK (REGEXP_LIKE(NOTel,'^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$')),
  CONSTRAINT CK_MaisonsEditions_NoFax 
  CHECK (REGEXP_LIKE(NoFax, '^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$')),
  CONSTRAINT PK_MaisonsEdit_MaisonEditionID
  PRIMARY KEY (MaisonEditionID)
);

CREATE TABLE BI_Articles
(
  ISBN                 char(17) NOT NULL,
  TypeArticle          varchar2(20) NOT NULL,
  Titre                varchar2(100) NOT NULL,
  Resume               varchar2(500) NOT NULL,
  PrixUnitaire         number(5,2) NOT NULL,
  IndicateurEnCommande char(1) NOT NULL,
  QuantiteEnCommande   number(4) NOT NULL,
  DateParution         date NOT NULL,
  MaisonEditionID      number(7) NOT NULL,
  CONSTRAINT CK_Articles_IndicateurCommande
    CHECK (IndicateurEnCommande IN (0,1)),
  CONSTRAINT CK_Articles_QuantiteEnCommande
    CHECK (QuantiteEnCommande >= 0),
  CONSTRAINT CK_Articles_ISBN
    CHECK(REGEXP_LIKE(ISBN, '978-[0-9]-[0-9]{5}-[0-9]{3}-[0-9]|[0-9]{13}')),
  CONSTRAINT PK_BI_Articles_ISBN
  PRIMARY KEY (ISBN)
);

ALTER TABLE BI_Articles ADD
  Langue    varchar2(2) DEFAULT 'FR' NOT NULL;

CREATE TABLE BI_CopiesArticles
(
  NoArticle             number(7) NOT NULL,
  ISBN                  char(17) NOT NULL,
  IndicateurDisponible  char(1) NOT NULL,
  CONSTRAINT CK_CopiesArticles_Indicateur
  CHECK(IndicateurDisponible IN (0,1)),
  CONSTRAINT PK_CopArticles_NoArticle_ISBN
  PRIMARY KEY(NoArticle, ISBN)
);

CREATE TABLE BI_Auteurs
(
  AuteurID            number(7) NOT NULL,
  Nom                 varchar2(50) NOT NULL,
  Prenom              varchar2(50) NOT NULL,
  Pays                varchar2(50) DEFAULT 'Canada' NOT NULL,
  SiteInternet        varchar2(100),
  AnneeNaissance      char(4) NOT NULL,
  AnneeDeces          char(4),
  CONSTRAINT CK_Auteurs_AnneeNaissance
    CHECK(AnneeNaissance BETWEEN '1900' AND '2021'),
  CONSTRAINT CK_Auteurs_AnneeDeces
    CHECK(AnneeDeces BETWEEN '1900' AND '2021'),
  CONSTRAINT PK_BI_Auteurs_AuteurID
  PRIMARY KEY(AuteurID)
);


CREATE TABLE BI_ArticlesAuteurs
(
  AuteurID          number(7) NOT NULL,
  ISBN              char(17) NOT NULL,
  CONSTRAINT PK_ArtAuteurs_AuteurID_ISBN
  PRIMARY KEY(AuteurID, ISBN)
);

CREATE TABLE BI_ModesPaiements
(
  ModePaiementCd     varchar2(20) NOT NULL,
  CdDescFr           varchar2(50) NOT NULL,
  CdDescEn           varchar2(50) NOT NULL,
  CONSTRAINT PK_ModesPaiements
    PRIMARY KEY(ModePaiementCd)
);

CREATE TABLE BI_Produits
(
  CodeProduit         number(7) NOT NULL,
  Nom                 varchar2(50) NOT NULL,
  Description         varchar2(200) NOT NULL,
  PrixUnitaire        number(5,2) NOT NULL,
  IndicateurTaxable   char(1) NOT NULL,
  QteEnInventaire     number(5) NOT NULL,
  NiveauRuptureStock  number(5) NOT NULL,
  QteACommander       number(5) NOT NULL,
  CONSTRAINT CK_Produits_IndicateurTaxable 
    CHECK (IndicateurTaxable IN (0,1)),
  CONSTRAINT CK_Produits_QteEnInventaire
    CHECK (QteEnInventaire >= 0),
  CONSTRAINT CK_Produits_NiveauRuptureStock
    CHECK (NiveauRuptureStock >= 0),
  CONSTRAINT CK_Produits_QteACommander
    CHECK (QteACommander >= 0),
  CONSTRAINT PK_Produits_CodeProduit
  PRIMARY KEY(CodeProduit)
);

CREATE TABLE BI_Membres
(
  NoMembre      number(7) NOT NULL,
  Nom           varchar2(50) NOT NULL,
  Prenom        varchar2(50) NOT NULL,
  TypeMembre    varchar2(20) NOT NULL,
  Salutation    varchar2(20) NOT NULL,
  Addresse      varchar2(100) NOT NULL,
  Ville         varchar2(50) DEFAULT 'Québec' NOT NULL,
  CodePostal    char(7) NOT NULL,
  ProvCode      char(2) NOT NULL,
  Pays          varchar2(50) DEFAULT 'Canada'NOT NULL,
  NOTel         char(14) NOT NULL,
  Email         varchar2(100)
);

ALTER TABLE BI_Membres ADD
    CONSTRAINT PK_Membres_NoMembre
    PRIMARY KEY(NoMembre);
    
ALTER TABLE BI_Membres ADD
    CONSTRAINT CK_Membres_CodePostal
    CHECK (REGEXP_LIKE(CodePostal,'^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$'));

ALTER TABLE BI_Membres ADD
    CONSTRAINT CK_Membres_NOTel 
    CHECK (REGEXP_LIKE(NOTel,'^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$'));


CREATE TABLE BI_Emprunts
(
  EmpruntID         number(7) NOT NULL,
  NoMembre          number(7) NOT NULL,
  NoArticle         number(7) NOT NULL,
  DateEmprunt       date DEFAULT sysDate NOT NULL,
  DateRetourPrevue  date NOT NULL,
  DateRetour        date,
  NbJoursDeRetard   number(5),
  AmendeParJour     number(3,2) NOT NULL,
  IndicateurPerte   char(1) NOT NULL,
  TotalAmende       number(5,2),
  ModePaiementCd    varchar2(20),
  ISBN              char(17) NOT NULL,
  CONSTRAINT CK_Emprunts_DateRetourPrevue
    CHECK(DateRetourPrevue >= DateEmprunt),
  CONSTRAINT CK_Emprunts_DateRetour
    CHECK(DateRetour >= DateEmprunt),
  CONSTRAINT CK_Emprunts_IndicateurPerte
    CHECK(IndicateurPerte IN (0,1)),
  CONSTRAINT PK_Emprunts_EmpruntID
    PRIMARY KEY(EmpruntID)
);

CREATE TABLE BI_Commentaires
(
  CommentaireID   number(7) NOT NULL,
  EmpruntID       number(7) NOT NULL,
  Commentaire     varchar2(250) NOT NULL,
  DateCommentaire date NOT NULL,
  CONSTRAINT PK_Commentaires_CommentaireID
    PRIMARY KEY(CommentaireID)
);

CREATE TABLE BI_Ventes
(
  VenteID           number(7) NOT NULL,
  NoMembre          number(7) NOT NULL,
  ModePaiementCd    varchar2(20) NOT NULL,
  DateVente         date NOT NULL,
  TotalVente        number(5,2) NOT NULL,
  TaxeProvCourante  number(3,3),
  TaxeFedCourante   number(5,2),
  TotalTaxes        number(7,2),
  GrandTotalVente   number(7,2),
  CONSTRAINT PK_Ventes_VenteID
    PRIMARY KEY(VenteID)
);

CREATE TABLE BI_VentesProduits
(
  VenteID           number(7) NOT NULL,
  CodeProduit       number(7) NOT NULL,
  IndicateurTaxable char(1) NOT NULL,
  QteAchetee        number(5) NOT NULL,
  PrixUnitaire      number(5,2) NOT NULL,
  TotalAchatProduit number(5,2) NOT NULL,
  CONSTRAINT CK_VentesProd_IndicateurTax 
    CHECK (IndicateurTaxable IN (0,1)),
  CONSTRAINT CK_VentesProd_QteAchetee 
    CHECK (QteAchetee > 0), 
  CONSTRAINT PK_VentesProd_VenteID_CodeProd
    PRIMARY KEY(VenteID,CodeProduit)
);

ALTER TABLE BI_MaisonsEditions ADD
  CONSTRAINT FK_MaisonsEditions_ProvCode
  FOREIGN KEY(ProvCode) REFERENCES BI_Provinces(ProvCode);
  
ALTER TABLE BI_Articles ADD
  CONSTRAINT FK_BI_Articles_TypeArticle
  FOREIGN KEY(TypeArticle) REFERENCES BI_TypeArticles(TypeArticle);
  
ALTER TABLE BI_Articles ADD
  CONSTRAINT FK_BI_Articles_MaisonEditionID
  FOREIGN KEY(MaisonEditionID) REFERENCES BI_MaisonsEditions(MaisonEditionID);
  
ALTER TABLE BI_ArticlesAuteurs ADD
  CONSTRAINT FK_ArticlesAuteurs_AuteurID
    FOREIGN KEY(AuteurID) REFERENCES BI_Auteurs(AuteurID);
-- Ajout de la Foreign Key ISBN dans la table BI_ArticlesAuteurs
ALTER TABLE BI_ArticlesAuteurs ADD
  CONSTRAINT FK_ArticlesAuteurs_ISBN
    FOREIGN KEY(ISBN) REFERENCES BI_Articles(ISBN);

ALTER TABLE BI_Membres ADD
  CONSTRAINT FK_Membres_TypeMembre
  FOREIGN KEY(TypeMembre) REFERENCES BI_TypesMembres(TypeMembre);
  
ALTER TABLE BI_Membres ADD
  CONSTRAINT FK_Membres_ProvCode
  FOREIGN KEY(ProvCode) REFERENCES BI_Provinces(ProvCode);
  
ALTER TABLE BI_CopiesArticles ADD
  CONSTRAINT FK_CopiesArticles_ISBN
  FOREIGN KEY(ISBN) REFERENCES BI_Articles(ISBN);
  
ALTER TABLE BI_Emprunts ADD
  CONSTRAINT FK_Emprunts_NoMembre
  FOREIGN KEY(NoMembre) REFERENCES BI_Membres(NoMembre);
  
ALTER TABLE BI_Emprunts ADD
  CONSTRAINT FK_Emprunts_NoArticle_ISBN
  FOREIGN KEY(NoArticle, ISBN) REFERENCES BI_CopiesArticles(NoArticle,ISBN);

ALTER TABLE BI_Emprunts ADD
  CONSTRAINT FK_Emprunts_ModePaiementCd
  FOREIGN KEY(ModePaiementCd) REFERENCES BI_ModesPaiements(ModePaiementCd);
  
ALTER TABLE BI_Commentaires ADD
  CONSTRAINT FK_Commentaires_EmpruntID
  FOREIGN KEY(EmpruntID) REFERENCES BI_Emprunts(EmpruntID);
  
ALTER TABLE BI_Ventes ADD
  CONSTRAINT FK_Ventes_NoMembre
  FOREIGN KEY(NoMembre) REFERENCES BI_Membres(NoMembre);
  
ALTER TABLE BI_Ventes ADD
  CONSTRAINT FK_Ventes_ModePaiementCd
  FOREIGN KEY(ModePaiementCd) REFERENCES BI_ModesPaiements(ModePaiementCd);
  
ALTER TABLE BI_VentesProduits ADD
  CONSTRAINT FK_VentesProduits_VenteID
  FOREIGN KEY(VenteID) REFERENCES BI_Ventes(VenteID);
  
ALTER TABLE BI_VentesProduits ADD
  CONSTRAINT FK_VentesProduits_CodProd
  FOREIGN KEY(CodeProduit) REFERENCES BI_Produits(CodeProduit);
    


/*************************************************
  CRÉATION DES SÉQUENCES
**************************************************/
CREATE SEQUENCE seq_EmpruntID START WITH 1;
CREATE SEQUENCE seq_NoArticle START WITH 1;
CREATE SEQUENCE seq_NoVente START WITH 6;
CREATE SEQUENCE seq_logId START WITH 1;

/*************************************************
  INSERTION DES DONNÉES
**************************************************/

--Insertion de données dans la table BI_Provinces
INSERT INTO BI_Provinces (ProvCode, ProvDescFr,ProvDescEn, PcTaxeProv, PcTaxeFed) VALUES ('QC','Québec','Quebec',0.0952,0.05);
INSERT INTO BI_Provinces (ProvCode, ProvDescFr,ProvDescEn, PcTaxeProv, PcTaxeFed) VALUES ('ON','Ontario','Ontario',0.08,0.07);

--Insertion de données dans la table BI_TypeMembres
INSERT INTO BI_TypesMembres (TypeMembre, TypeDescFr, TypeDescEn, NbJoursSurEmprunt) VALUES (1, 'Résident','Resident',7);
INSERT INTO BI_TypesMembres (TypeMembre, TypeDescFr, TypeDescEn, NbJoursSurEmprunt) VALUES (2, 'Entreprise','Entreprise',15);
INSERT INTO BI_TypesMembres (TypeMembre, TypeDescFr, TypeDescEn, NbJoursSurEmprunt) VALUES (3, 'Étudiant','Student',15);

--Insertion de données dans la table BI_TypeArticles
INSERT INTO BI_TypeArticles (TypeArticle, TypeArticleDescFr, TypeArticleDescEn, AmendeParJour) VALUES('LI','Livre','Book',0.20);
INSERT INTO BI_TypeArticles (TypeArticle, TypeArticleDescFr, TypeArticleDescEn, AmendeParJour) VALUES('DVD','Film DVD','DVD Movie',1.00);
INSERT INTO BI_TypeArticles (TypeArticle, TypeArticleDescFr, TypeArticleDescEn, AmendeParJour) VALUES('BLU','Film Blu-ray','Blu-ray Movie',1.00);
INSERT INTO BI_TypeArticles (TypeArticle, TypeArticleDescFr, TypeArticleDescEn, AmendeParJour) VALUES('JEU','Jeu vidéo','Video game',1.25);

--Insertion de données dans la table BI_MaisonsEditions
INSERT INTO BI_MaisonsEditions VALUES(1,'Belle-oeuvre','192 rue de la chapelle','Québec','G0S 1N0','QC','Canada','(418) 333-4434','(418) 454-1212','belleoeuvre@hotmail.com','www.belle-oeuvre.com' , 'Gérard');
INSERT INTO BI_MaisonsEditions VALUES(2,'Belle-horizon','99 rue des zombies','Québec','G4S 3N0','QC','Canada','(418) 222-4344','(418) 555-1122','bellehorizon@hotmail.com','www.belle-horizon.com' , 'Roger');

--Insertion de données dans la table BI_Articles
INSERT INTO BI_Articles VALUES('978-2-12345-012-1','DVD','Harry Potter et les reliques de la mort - 2e partie', 'Dans ce dernier opus spectaculaire, le combat entre les forces du bien et du mal dans le monde de la magie s''intensifie et se transforme en guerre totale. Les enjeux n''ont jamais été aussi importants et personne n''est à l''abri. Mais c''est Harry Potter qui risque de devoir faire l''ultime sacrifice au moment de la confrontation cruciale imminente avec Lord Voldemort.', 18.99, 0,0,'2011-11-11',1,'FR');
INSERT INTO BI_Articles VALUES('978-2-70964-192-0','LI','Cinquante nuances de Grey','Romantique, libérateur et totalement addictif, ce roman vous obsédera, vous possédera et vous marquera à jamais.   Lorsqu''Anastasia Steele, étudiante en littérature, interviewe le richissime jeune chef d''entreprise Christian Grey, elle le trouve très séduisant mais profondément intimidant. Convaincue que leur rencontre a été désastreuse, elle tente de l''oublier ? ', 16.99, 0,0,'2021-08-02',2,'FR');
INSERT INTO BI_Articles VALUES('1008888528111','JEU','Assassin''s Creed IV: Black Flag','Assassin''s Creed 4 pour XBox 360', 59.99, 0,0,'2013-10-05',2,'FR');


--Insertion de données dans la table BI_Auteurs
INSERT INTO BI_Auteurs VALUES(1, 'James' , 'Erika Leonard', 'Canada', '' , '1963' , '');
INSERT INTO BI_Auteurs VALUES(2, 'Rowling' , 'J.K.', 'Angleterre', '' , '1965' , '');

--Insertion de données dans la table BI_ArticlesAuteurs
INSERT INTO BI_ArticlesAuteurs VALUES(1,'978-2-70964-192-0');
INSERT INTO BI_ArticlesAuteurs VALUES(2,'978-2-12345-012-1');

--Insertion de données dans la table BI_ModesPaiements
INSERT INTO BI_ModesPaiements VALUES('C', 'Comptant' , 'Cash');
INSERT INTO BI_ModesPaiements VALUES('V', 'Visa' , 'Visa');

--Insertion de données dans la table BI_Produits
INSERT INTO BI_Produits VALUES(1, 'Skor' , 'Barre de chocolat Skor', 3.00, 1, 25, 5,0);
INSERT INTO BI_Produits VALUES(2, 'Ruffles Crème sure et oignon' , 'Chips Ruffles à saveur de crème sure et oignon', 2.00, 1, 5, 5,15);
INSERT INTO BI_Produits VALUES(3, 'Dentyne aux fraises' , 'Gomme DEntyne à saveur de fraise', 2.50, 1, 5, 5,15);
INSERT INTO BI_Produits VALUES(4, 'Brocoli' , 'Produit non taxable', 4, 0, 66, 5,66);

--Insertion de données dans la table BI_Membres
INSERT INTO BI_Membres VALUES(1,'Filion', 'Jean', 1, 'M.', '123 rue des Sapins' , 'Québec', 'G4S 4H8', 'QC' , 'Canada', '(418) 222-6666', 'jean_filion@hotmail.com');
INSERT INTO BI_Membres VALUES(2,'Lemay', 'Nicole', 1, 'Mme.', '1 rue des Peupliers' , 'Québec', 'G2D 4H6', 'QC' , 'Canada', '(418) 332-4344', 'nicole_lemay@hotmail.com');
INSERT INTO BI_Membres VALUES(3,'Nadeau', 'Olivier', 1, 'M.', '76 rue des Pins' , 'Québec', 'G1D 7J8', 'QC' , 'Canada', '(418) 123-4567', 'onadeau@cegepgarneau.ca');

--Insertion de données dans la table BI_CopiesArticles
INSERT INTO BI_CopiesArticles VALUES(seq_NoArticle.NEXTVAL ,'978-2-70964-192-0', 0);
INSERT INTO BI_CopiesArticles VALUES(seq_NoArticle.NEXTVAL,'978-2-70964-192-0', 1);
INSERT INTO BI_CopiesArticles VALUES(seq_NoArticle.NEXTVAL,'978-2-12345-012-1', 0);
INSERT INTO BI_CopiesArticles VALUES(seq_NoArticle.NEXTVAL,'978-2-12345-012-1', 1);
INSERT INTO BI_CopiesArticles VALUES(seq_NoArticle.NEXTVAL,'1008888528111', 1);
INSERT INTO BI_CopiesArticles VALUES(seq_NoArticle.NEXTVAL,'978-2-12345-012-1', 1);

--Insertion de données dans la table BI_Emprunts
INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 1,2,'2021-01-01' , '2021-01-08' , '2021-01-10',0.2,'0','978-2-70964-192-0');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,2,'2021-01-03' , '2021-01-10' , '2021-01-03',0.2,'1','978-2-70964-192-0');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,1,'2021-01-03' , '2021-01-26' , '2021-01-03',0.2,'1','978-2-70964-192-0');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,1,'2021-09-05' , '2021-09-12' , '2021-09-12',0.2,'1','978-2-70964-192-0');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 3,4,'2021-09-06' , '2021-09-13' , '2021-09-12',0.2,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 3,4,'2021-09-08' , '2021-09-15' , '2021-09-12',0.2,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 3,3,'2021-09-15' , '2021-09-22' , '2021-09-25',0.2,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 1,4,'2021-05-25' , '2021-06-01' , '2021-08-12',1.00,'1','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2021-06-04' , '2021-06-11' , '2021-06-09',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2020-09-05' , '2020-09-09' , '2020-09-12',1.25,'0','1008888528111');

-- DEBUT TEST QUESTION 1 (ajout 6 emprunts)
INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2022-01-05' , '2022-01-09' , '2022-01-09',1.25,'0','1008888528111');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2022-01-01' , '2022-01-02' , '2022-01-02',1.25,'0','1008888528111');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2022-01-03' , '2022-01-04' , '2022-01-04',1.25,'0','1008888528111');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2022-01-05' , '2022-01-06' , '2022-01-06',1.25,'0','1008888528111');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2022-01-10' , '2022-01-11' , '2022-01-11',1.25,'0','1008888528111');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,5,'2022-01-12' , '2022-01-13' , '2022-01-13',1.25,'0','1008888528111');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-01' , '2022-01-02' , '2022-01-02',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-03' , '2022-01-04' , '2022-01-04',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-05' , '2022-01-06' , '2022-01-06',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-07' , '2022-01-08' , '2022-01-08',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-09' , '2022-01-10' , '2022-01-10',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-11' , '2022-01-12' , '2022-01-12',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-13' , '2022-01-14' , '2022-01-14',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-15' , '2022-01-16' , '2022-01-16',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-17' , '2022-01-18' , '2022-01-18',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-19' , '2022-01-20' , '2022-01-20',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts(EmpruntID, NoMembre, NoArticle, DateEmprunt, DateRetourPrevue, DateRetour,AmendeParJour,IndicateurPerte,ISBN) 
VALUES(seq_EmpruntID.NEXTVAL, 2,3,'2022-01-21' , '2022-01-22' , '2022-01-22',1.00,'0','978-2-12345-012-1');

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',666);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);
-- FIN TEST QUESTION 1

INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',666);

--Insertion de données dans la table BI_Commentaires
INSERT INTO BI_Commentaires VALUES(1,1,'A perdu un livre.', '2021-09-15');
INSERT INTO BI_Commentaires VALUES(2,1,'A brisé un livre.', '2021-09-14');
INSERT INTO BI_Commentaires VALUES(3,2,'livre en feu', '2021-09-15');

--Insertion de données dans la table BI_Ventes
INSERT INTO BI_Ventes (VenteID, NoMembre, ModePaiementCd, DateVente, TotalVente) VALUES(1,1,'V','2021-01-02', 6);
INSERT INTO BI_Ventes (VenteID, NoMembre, ModePaiementCd, DateVente, TotalVente) VALUES(2,1,'C','2021-01-02', 2);
INSERT INTO BI_Ventes (VenteID, NoMembre, ModePaiementCd, DateVente, TotalVente) VALUES(3,1,'C','2021-09-03', 3);
INSERT INTO BI_Ventes (VenteID, NoMembre, ModePaiementCd, DateVente, TotalVente) VALUES(4,1,'C','2021-08-20', 9);
INSERT INTO BI_Ventes (VenteID, NoMembre, ModePaiementCd, DateVente, TotalVente) VALUES(5,1,'C','2021-08-20', 2.50);

--Insertion de données dans la table BI_VentesProduits
INSERT INTO BI_VentesProduits VALUES(1,1,'1',2,3,6);
INSERT INTO BI_VentesProduits VALUES(2,2,'1',1,2,2);
INSERT INTO BI_VentesProduits VALUES(3,1,'1',1,3,3);
INSERT INTO BI_VentesProduits VALUES(4,3,'1',2,2.50,5);
INSERT INTO BI_VentesProduits VALUES(4,2,'1',2,2,4);
INSERT INTO BI_VentesProduits VALUES(5,3,'1',1,2.50,2.50);



