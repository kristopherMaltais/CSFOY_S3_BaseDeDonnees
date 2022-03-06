/*DROP PACKAGE Pkg_Tp3;
DROP TYPE emprunts;
DROP TYPE emprunts_q7;
DROP TYPE tableauLocations;
DROP TYPE tableauVerification;

DROP TYPE emprunt;
DROP TYPE emprunt_q7;
DROP TYPE nbLocations;
DROP TYPE verificationsAvantInsertionEmprunt;
*/


-- Creation du package
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- Creation des objets
/
CREATE OR REPLACE TYPE emprunt AS OBJECT(
    isbn VARCHAR2(17),
    nombreEmprunt NUMBER
);
/

CREATE OR REPLACE TYPE emprunts AS TABLE OF emprunt; 

/
CREATE OR REPLACE TYPE emprunt_q7 AS OBJECT(
    titreArticle varchar(100),
    nombreEmprunt number
);
/

CREATE OR REPLACE TYPE emprunts_q7 AS TABLE OF emprunt_q7;

/
CREATE OR REPLACE TYPE nbLocations AS OBJECT(
    nomSujet VARCHAR(100), 
    nbLocations NUMBER
); 
/

CREATE OR REPLACE TYPE tableauLocations IS TABLE OF nbLocations;

/
CREATE OR REPLACE TYPE verificationsAvantInsertionEmprunt AS OBJECT
(
    estValide NUMBER(1,0),
    numArticle NUMBER(7)
);
/

CREATE OR REPLACE TYPE tableauVerification AS TABLE OF verificationsAvantInsertionEmprunt;

CREATE OR REPLACE PACKAGE Pkg_Tp3
IS
    PROCEDURE FCT_AjouterTableLog 
    (
        codeSql number,
        messageErreur varchar2,
        erreurBackTrace varchar2,
        callStack varchar2,
        utilisateur varchar2
    );
    
    PROCEDURE SP_01Commande;
    
    FUNCTION FCT_02Amendes
    (
        NumeroMembre NUMBER,
        totalAmendes OUT NUMBER
    ) RETURN NUMBER;
    
    FUNCTION FCT_07Best 
    (
        annee CHAR,
        mois CHAR
    ) RETURN emprunts_q7;
    
    FUNCTION FCT_08SommaireLocation
    (
        referenceLocation VARCHAR
    ) RETURN tableauLocations;
    
    FUNCTION VerifierAvantInsertionEmprunt
    (
        p_isbn VARCHAR,
        p_numMembre NUMBER
    ) RETURN tableauVerification;
    
END Pkg_Tp3;

CREATE OR REPLACE PACKAGE BODY Pkg_Tp3
IS

-- Table log
PROCEDURE FCT_AjouterTableLog(codeSql number, messageErreur varchar2, erreurBackTrace varchar2, callStack varchar2, utilisateur varchar2)
IS
    vCodeSql BI_TableLog.codeSql%TYPE;
    vMessageErreur BI_TableLog.messageErreur%TYPE;
    vErreurBacktrace BI_TableLog.erreurBacktrace%TYPE;
    vCallStack BI_TableLog.callStack%TYPE;
    vDateErreur BI_TableLog.dateErreur%TYPE;
    vUtilisateur BI_TableLog.utilisateur%TYPE;
    
    PROCEDURE init
    IS
    BEGIN
        vCodeSql := codeSql;
        vMessageErreur := messageErreur;
        vErreurBacktrace := erreurBackTrace;
        vCallStack := callStack;
        vDateErreur := SYSDATE;
        vUtilisateur := utilisateur;
    END init;
BEGIN
    init;
    INSERT INTO BI_TableLog (logId, codeSql, messageErreur, erreurBacktrace, callStack, dateErreur, utilisateur)
    VALUES (seq_logId.NEXTVAL, vCodeSql, vMessageErreur, vErreurBacktrace, vCallStack, vDateErreur, vUtilisateur);
END;

-- QUESTION 1 2pts
-- Procedure stockee
PROCEDURE SP_01Commande
IS
    listeEmprunt emprunts;
    limitFetch CONSTANT NUMBER := 10;
    CURSOR c_empruntDernierMois IS SELECT emprunt(ISBN, COUNT(*)) FROM BI_EMPRUNTS 
            WHERE DateEmprunt >= add_months(trunc(sysdate, 'MM'), -1) -- question pour pfl
            GROUP BY ISBN;
BEGIN
    SAVEPOINT modifierProchaineCommande;
    listeEmprunt := emprunts();
    listeEmprunt.EXTEND(limitFetch);
    
    OPEN c_empruntDernierMois;
    
    LOOP
            FETCH c_empruntDernierMois BULK COLLECT INTO listeEmprunt LIMIT limitFetch;
            EXIT WHEN listeEmprunt.COUNT = 0;
        FOR indx IN 1 .. listeEmprunt.COUNT LOOP
            IF listeEmprunt(indx).nombreEmprunt > 10 THEN
                UPDATE BI_Articles SET QuantiteEnCommande = 2, Indicateurencommande = 1  WHERE ISBN = listeEmprunt(indx).isbn;
            ELSIF listeEmprunt(indx).nombreEmprunt BETWEEN 6 AND 10 THEN
                UPDATE BI_Articles SET QuantiteEnCommande = 1, Indicateurencommande = 1 WHERE ISBN = listeEmprunt(indx).isbn;
            END IF;
        END LOOP;
    END LOOP;
    --COMMIT;
    CLOSE c_empruntDernierMois;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
        RAISE;
        ROLLBACK TO modifierProchaineCommande;
END;

-- QUESTION 2 2pts
-- Fonction
-- ** Sur cette fonction, on ne peut pas utiliser la cache car elle contient un paramètre out ** voir p.5 pdf procedures_fonctions
FUNCTION FCT_02Amendes (numeroMembre NUMBER, totalAmendes OUT NUMBER) 
RETURN NUMBER
IS
    codeMembreExisteAucuneAmende CONSTANT NUMBER := 0;
    codeMembreExisteAmendeAPayer CONSTANT NUMBER := 1;
    codeMembreInexistant CONSTANT NUMBER := 2;
    codeSortie NUMBER := -1;
    
    membreExiste NUMBER := 0;
BEGIN
    totalAmendes := 0;
    SELECT COUNT(*) INTO membreExiste FROM BI_Membres 
    WHERE NoMembre = numeroMembre;
    
    IF (membreExiste = 0) THEN
        codeSortie := codeMembreInexistant;
    
    ELSE
        SELECT SUM(TotalAmende) INTO totalAmendes FROM BI_Emprunts 
        WHERE NoMembre = numeroMembre
        GROUP BY NoMembre;
        
        IF (totalAmendes > 0) THEN 
            codeSortie := codeMembreExisteAmendeAPayer; 
        ELSE
            codeSortie := codeMembreExisteAucuneAmende;
            totalAmendes := 0;
        END IF; 
        
    END IF;
RETURN codeSortie;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;

-- QUESTION 7 1,5pts
-- Fonction
FUNCTION FCT_07Best (annee CHAR, mois CHAR)
    RETURN emprunts_q7
IS
    listeEmprunts emprunts_q7;
    CURSOR c_emprunts IS SELECT emprunt_q7(a.Titre, SUM(CASE WHEN EXTRACT(year FROM DATEEMPRUNT) = annee AND EXTRACT(month FROM DATEEMPRUNT) = mois THEN 1 ELSE 0 END)) FROM BI_Emprunts e
                            LEFT JOIN BI_Articles a
                                ON e.ISBN = a.ISBN
                            GROUP BY a.Titre
                            ORDER BY SUM(CASE WHEN EXTRACT(year FROM DATEEMPRUNT) = annee AND EXTRACT(month FROM DATEEMPRUNT) = mois THEN 1 ELSE 0 END) DESC;
BEGIN
    listeEmprunts := emprunts_q7();
    OPEN c_emprunts;
    FETCH c_emprunts BULK COLLECT INTO listeEmprunts;
    CLOSE c_emprunts;
    RETURN listeEmprunts;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;

-- QUESTION 8 1,5pts
-- Fonction
FUNCTION FCT_08SommaireLocation (referenceLocation VARCHAR)
RETURN tableauLocations
IS
    v_nbLocations NUMBER := 0;
    v_referenceLocation VARCHAR(7) := 0;
    
    v_tableauLocations tableauLocations := tableauLocations();
    v_espaceTableauRequis NUMBER := 0;
    v_indexCourant NUMBER := 1;
    
    v_tableauTransfertDonnees tableauLocations := tableauLocations();
    limitFetch CONSTANT NUMBER := 10;   
    
    TYPE locationsRefCurseur IS REF CURSOR;
    c_curseurAExecute locationsRefCurseur;
    
BEGIN
    v_tableauTransfertDonnees.EXTEND(limitFetch);
    v_referenceLocation := LOWER(referenceLocation);

    IF (v_referenceLocation = 'auteur') THEN   
        SELECT COUNT(DISTINCT(AuteurID)) INTO v_espaceTableauRequis FROM BI_ArticlesAuteurs
        WHERE ISBN IN (SELECT ISBN FROM BI_Emprunts);
        v_tableauLocations.EXTEND(v_espaceTableauRequis);
        
        OPEN c_curseurAExecute FOR   
        SELECT nbLocations(Prenom || ' ' || Nom, COUNT(EmpruntID)) FROM BI_Emprunts B
        INNER JOIN BI_ArticlesAuteurs AA
        ON B.ISBN = AA.ISBN
        INNER JOIN BI_Auteurs A
        ON AA.AuteurID = A.AuteurID
        GROUP BY Prenom, Nom;
        
    ELSIF (v_referenceLocation = 'article') THEN
        SELECT COUNT(DISTINCT(ISBN)) INTO v_espaceTableauRequis FROM BI_Emprunts;
        v_tableauLocations.EXTEND(v_espaceTableauRequis);
        
        OPEN c_curseurAExecute FOR 
        SELECT nbLocations(Titre, COUNT(EmpruntID)) FROM BI_Emprunts E
        INNER JOIN BI_Articles A
        ON E.ISBN = A.ISBN
        GROUP BY Titre;
        
    ELSIF (v_referenceLocation = 'membre') THEN
        SELECT COUNT(DISTINCT(NoMembre)) INTO v_espaceTableauRequis FROM BI_Emprunts;
        v_tableauLocations.EXTEND(v_espaceTableauRequis);
        
        OPEN c_curseurAExecute FOR
        SELECT nbLocations(Prenom || ' ' || Nom, COUNT(EmpruntID)) FROM BI_Emprunts E
        INNER JOIN BI_Membres M
        ON E.NoMembre = M.NoMembre
        GROUP BY Prenom, Nom;
    
    ELSE
        RAISE_APPLICATION_ERROR('-20156', 'Paramètre invalide');
    END IF;
    
    LOOP
            
        FETCH c_curseurAExecute BULK COLLECT INTO v_tableauTransfertDonnees LIMIT limitFetch;
        EXIT WHEN v_tableauTransfertDonnees.COUNT = 0;
                
        FOR indx IN 1 .. v_tableauTransfertDonnees.COUNT LOOP
            v_tableauLocations(v_indexCourant) := v_tableauTransfertDonnees(indx);
            v_indexCourant := v_indexCourant + 1;
        END LOOP;
                
    END LOOP;
    
CLOSE c_curseurAExecute;
RETURN v_tableauLocations;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;

FUNCTION VerifierAvantInsertionEmprunt (p_isbn VARCHAR, p_numMembre NUMBER) 
RETURN tableauVerification
IS
isbnExiste NUMBER(1,0) := 0;
copieDisponible NUMBER(1,0) := 0;
numMembreExiste NUMBER(1,0) := 0;
numArticle NUMBER(7) := 0;
verification verificationsAvantInsertionEmprunt := verificationsAvantInsertionEmprunt(0,0);
tableauVerificationInsertion tableauVerification := tableauVerification();
BEGIN   
    SELECT COUNT(*) INTO isbnExiste FROM BI_Articles WHERE ISBN = p_isbn;
    SELECT COUNT(*) INTO copieDisponible FROM BI_CopiesArticles WHERE IndicateurDisponible = '1' AND ISBN = p_isbn;
    SELECT COUNT(*) INTO numMembreExiste FROM BI_Membres WHERE NoMembre = p_numMembre;

    IF (isbnExiste > 0 AND copieDisponible > 0 AND numMembreExiste > 0) THEN
    SELECT NoArticle INTO numArticle FROM BI_CopiesArticles WHERE IndicateurDisponible = '1' AND ISBN = p_isbn FETCH FIRST 1 ROW ONLY;
    verification.estValide := 1;
    verification.numArticle := numArticle;
    END IF;
    
    tableauVerificationInsertion.EXTEND(1);
    tableauVerificationInsertion(1) := verification;
RETURN tableauVerificationInsertion;    
END;

END Pkg_Tp3;

-- Bloc test anonyme table log
DECLARE
    noEmprunt BI_Emprunts.empruntid%TYPE;
BEGIN
    SELECT empruntid INTO noEmprunt FROM BI_Emprunts WHERE nomembre = 3;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;
 
SELECT * FROM BI_tablelog;

-- Bloc anonyme test question01
DECLARE
    CURSOR c_articles IS SELECT titre, indicateurencommande, quantiteencommande FROM BI_Articles;
    CURSOR c_empruntDernierMois IS SELECT a.titre, COUNT(*) AS commandes FROM BI_EMPRUNTS e
                                    INNER JOIN BI_Articles a
                                        ON e.ISBN = a.ISBN
                                    WHERE e.DateEmprunt >= add_months(trunc(sysdate, 'MM'), -1) -- question pour pfl
                                    GROUP BY a.titre;
BEGIN
    -- etat avant la procedure
    FOR v_livre IN c_empruntDernierMois LOOP
        DBMS_OUTPUT.PUT_LINE('Le livre : ' || v_livre.titre || 'a ete commande : ' || v_livre.commandes || ' fois dans le dernier mois');
    END LOOP;
    FOR v_article IN c_articles LOOP
        DBMS_OUTPUT.PUT_LINE('AVANT LA PROCEDURE' || v_article.titre || 'est en commande: ' || v_article.indicateurencommande || '[quantite pour prochaine commande]: ' || v_article.quantiteencommande);
    END LOOP;
    
    -- lancer la procedure stocke
    SAVEPOINT etatAvantProcedure;
    Pkg_Tp3.SP_01Commande;
    
    
    -- etat apres la procedure
    FOR v_article IN c_articles LOOP
        DBMS_OUTPUT.PUT_LINE('APRES LA PROCEDURE' || v_article.titre || 'est en commande: ' || v_article.indicateurencommande || '[quantite pour prochaine commande]: ' || v_article.quantiteencommande);
    END LOOP;
    ROLLBACK TO etatAvantProcedure;
END; 

-- Bloc anonyme test question02
DECLARE
    noMembreInexistant NUMBER := 999;
    noMembreExistantSansAmendes NUMBER := 3;
    noMembreExistantAvecAmendes NUMBER := 2;
    
    codeSortieMembreInexsistant NUMBER := -1;
    totalAmendeMembreInexistant NUMBER := -1;
    
    codeSortieMembreExistantSansAmendes NUMBER := -1;
    totalAmendeMembreExistantSansAmendes NUMBER := -1;
    
    codeSortieMembreExistantAvecAmendes NUMBER := -1;
    totalAmendeMembreExistantAvecAmendes NUMBER := -1;
BEGIN
    codeSortieMembreInexsistant := Pkg_Tp3.FCT_02Amendes(noMembreInexistant, totalAmendeMembreInexistant);
    DBMS_OUTPUT.PUT_LINE('Membre inexistant. CodeSortie = ' || codeSortieMembreInexsistant || ' TotalAmendes = ' || totalAmendeMembreInexistant);
    
    codeSortieMembreExistantSansAmendes := Pkg_Tp3.FCT_02Amendes(noMembreExistantSansAmendes, totalAmendeMembreExistantSansAmendes);
    DBMS_OUTPUT.PUT_LINE('Membre existant sans amendes. CodeSortie = ' || codeSortieMembreExistantSansAmendes || ' TotalAmendes = ' || totalAmendeMembreExistantSansAmendes);
    
    codeSortieMembreExistantAvecAmendes := Pkg_Tp3.FCT_02Amendes(noMembreExistantAvecAmendes, totalAmendeMembreExistantAvecAmendes); 
    DBMS_OUTPUT.PUT_LINE('Membre existant avec amendes. CodeSortie = ' || codeSortieMembreExistantAvecAmendes || ' TotalAmendes = ' || totalAmendeMembreExistantAvecAmendes);
END;
   
-- QUESTION 3 2pts
-- Declencheur
CREATE OR REPLACE TRIGGER TR_03InsVente 
    BEFORE INSERT ON BI_Ventes
    FOR EACH ROW
BEGIN
    :NEW.VenteID := seq_NoVente.NEXTVAL;
    :NEW.TotalVente := 0;
    :NEW.TaxeProvCourante := 0;
    :NEW.TaxeFedCourante := 0;
    :NEW.TotalTaxes := 0;
    :NEW.GrandTotalVente := 0;
END;

-- Bloc anonyme test question03
DECLARE 
    CURSOR c_ventes IS SELECT * FROM BI_Ventes;
BEGIN
        DBMS_OUTPUT.PUT_LINE('Avant le insert de la nouvelle commande: ');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('Numero commande: ' || v_vente.VenteID || ' NumeroMembre: ' || v_vente.NoMembre || ' Mode paiement: ' || v_vente.ModePaiementCd || ' DateVente: ' || v_vente.DateVente || ' Total vente: ' || v_vente.TotalVente || ' Taxe provincial: ' || v_vente.TaxeProvCourante || ' Taxe federale: ' || v_vente.TaxeFedCourante || ' Total taxe: ' || v_vente.TotalTaxes || ' Grand total: ' || v_vente.GrandTotalVente);
    END LOOP;
    
    -- Insertion de la commande avec activation du trigger
    INSERT INTO BI_Ventes (NoMembre, ModePaiementCd, DateVente) VALUES (1, 'C', '2020-08-24');
    
    DBMS_OUTPUT.PUT_LINE('Apres le insert de la commande numero  ');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('Numero commande: ' || v_vente.VenteID ||' NumeroMembre: ' || v_vente.NoMembre || ' Mode paiement: ' || v_vente.ModePaiementCd || ' DateVente: ' || v_vente.DateVente || ' Total vente: ' || v_vente.TotalVente || ' Taxe provincial: ' || v_vente.TaxeProvCourante || ' Taxe federale: ' || v_vente.TaxeFedCourante || ' Total taxe: ' || v_vente.TotalTaxes || ' Grand total: ' || v_vente.GrandTotalVente);
    END LOOP;
END;

-- QUESTION 4 2pts
-- Declencheur
CREATE OR REPLACE TRIGGER TR_04InsVente
BEFORE INSERT OR UPDATE OR DELETE ON BI_VentesProduits
FOR EACH ROW
DECLARE  
    v_venteId NUMBER(7);
    v_codeProduit NUMBER(7);
    v_indicateurTaxable CHAR(1);
    v_qteAchetee NUMBER(5);   
    v_prixUnitaire NUMBER(5,2) := 0;
    v_totalAchatProduit NUMBER(5,2) := 0;
    v_pcTaxeProv NUMBER(3,3) := 0;
    v_pcTaxeFed NUMBER(3,3) := 0;
    v_noMembreVente NUMBER(7);
    
    v_montantTaxeProv NUMBER(3,3) := 0;
    v_montantTaxeFed NUMBER(5,2) := 0;
    v_montantTotalTaxes NUMBER(7,2) := 0;
    v_montantTotalLigneFacture NUMBER (7,2) := 0;
    
    -- Pour update
    v_nouveauTotalAchatProduit NUMBER(5,2) := 0;
    v_nouveauMontantTaxeProv NUMBER(3,3) := 0;
    v_nouveauMontantTaxeFed NUMBER(5,2) := 0;
    v_nouveauMontantTotalTaxes NUMBER(7,2) := 0;
    v_nouveauMontantTotalLigneFacture NUMBER(7,2) := 0;
BEGIN  
               
    IF (INSERTING) THEN
        v_venteId := :NEW.VenteID;
        
        SELECT NoMembre INTO v_NoMembreVente FROM BI_Ventes WHERE VenteID = v_venteId;
        SELECT PcTaxeProv, PcTaxeFed INTO v_pcTaxeProv, v_pcTaxeFed FROM BI_Provinces P
            INNER JOIN BI_Membres M
                ON P.ProvCode = M.ProvCode
            WHERE M.NoMembre = v_noMembreVente; 
            
        v_codeProduit := :NEW.CodeProduit;
        v_qteAchetee := :NEW.QteAchetee;
        SELECT IndicateurTaxable, PrixUnitaire, (PrixUnitaire * v_qteAchetee) INTO v_indicateurTaxable, v_prixUnitaire, v_totalAchatProduit  FROM BI_Produits WHERE CodeProduit = v_codeProduit;
        
        :NEW.IndicateurTaxable := v_indicateurTaxable;
        :NEW.PrixUnitaire := v_prixUnitaire;
        :NEW.TotalAchatProduit := v_totalAchatProduit;
        
        IF (v_indicateurTaxable = '1') THEN
            v_montantTaxeProv := v_totalAchatProduit * v_pcTaxeProv;
            v_montantTaxeFed := v_totalAchatProduit * v_pcTaxeFed;
        END IF;
        
        UPDATE BI_Ventes SET TotalVente = TotalVente + v_totalAchatProduit WHERE VenteID = v_venteId; 
        UPDATE BI_Ventes SET TaxeProvCourante = TaxeProvCourante + v_montantTaxeProv WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET TaxeFedCourante = TaxeFedCourante + v_montantTaxeFed WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET TotalTaxes = TaxeProvCourante + TaxeFedCourante WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET GrandTotalVente = TotalVente + TotalTaxes WHERE VenteID = v_venteId;
    END IF;
    
    IF (UPDATING OR DELETING) THEN 
        v_venteId := :OLD.VenteID;
        
        SELECT NoMembre INTO v_NoMembreVente FROM BI_Ventes WHERE VenteID = v_venteId;
        SELECT PcTaxeProv, PcTaxeFed INTO v_pcTaxeProv, v_pcTaxeFed FROM BI_Provinces P
            INNER JOIN BI_Membres M
                ON P.ProvCode = M.ProvCode
            WHERE M.NoMembre = v_noMembreVente;
            
        v_indicateurTaxable := :OLD.IndicateurTaxable;
        v_totalAchatProduit := :OLD.TotalAchatProduit;
        
        IF (v_indicateurTaxable = '1') THEN
            v_montantTaxeProv := v_totalAchatProduit * v_pcTaxeProv;
            v_montantTaxeFed := v_totalAchatProduit * v_pcTaxeFed;
        END IF;
        
        v_montantTotalTaxes := v_montantTaxeProv + v_montantTaxeFed;
        v_montantTotalLigneFacture := v_totalAchatProduit + v_montantTotalTaxes; 
        
        IF (UPDATING) THEN              
            v_nouveauTotalAchatProduit := :NEW.QteAchetee * :OLD.PrixUnitaire;
            :NEW.TotalAchatProduit := v_nouveauTotalAchatProduit;
        
            IF (v_indicateurTaxable = '1') THEN           
                v_nouveauMontantTaxeProv := v_nouveauTotalAchatProduit * v_pcTaxeProv;
                v_nouveauMontantTaxeFed := v_nouveauTotalAchatProduit * v_pcTaxeFed;
            END IF;        
        
            v_nouveauMontantTotalTaxes := v_nouveauMontantTaxeProv + v_nouveauMontantTaxeFed;
            v_nouveauMontantTotalLigneFacture := v_nouveauTotalAchatProduit + v_nouveauMontantTotalTaxes;
            v_montantTaxeProv := v_montantTaxeProv - v_nouveauMontantTaxeProv;
            v_montantTaxeFed := v_montantTaxeFed - v_nouveauMontantTaxeFed;
            v_montantTotalTaxes := v_montantTotalTaxes - v_nouveauMontantTotalTaxes;
            v_totalAchatProduit := v_totalAchatProduit - v_nouveauTotalAchatProduit;
            v_montantTotalLigneFacture := v_montantTotalLigneFacture - v_nouveauMontantTotalLigneFacture;           
        END IF;
              
        UPDATE BI_Ventes SET TaxeProvCourante = TaxeProvCourante - v_montantTaxeProv WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET TaxeFedCourante = TaxeFedCourante - v_montantTaxeFed WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET TotalTaxes = TotalTaxes - v_montantTotalTaxes WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET TotalVente = TotalVente - v_totalAchatProduit WHERE VenteID = v_venteId;
        UPDATE BI_Ventes SET GrandTotalVente = GrandTotalVente - v_montantTotalLigneFacture WHERE VenteID = v_venteId;    
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;

-- Bloc anonyme test question04
DECLARE
    CURSOR c_ventesProduits IS SELECT * FROM BI_VentesProduits;
    CURSOR c_ventes IS SELECT * FROM BI_Ventes;
    v_venteID NUMBER;
BEGIN
    SAVEPOINT avantOperation;
    DBMS_OUTPUT.PUT_LINE('***** Démonstration de l''insertion d''enregistrements sur la vente (1 taxable et 1 non taxable)  ******');
    DBMS_OUTPUT.PUT_LINE('');
    
    INSERT INTO BI_Ventes (NoMembre, ModePaiementCd, DateVente) VALUES (1,'V','2022-02-12');
    v_venteID := seq_NoVente.CURRVAL;

    DBMS_OUTPUT.PUT_LINE('État de la table BI_VentesProduits avant');
    FOR v_venteProduit IN c_ventesProduits LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_venteProduit.VenteID || ' / CodeProduit=' || v_venteProduit.CodeProduit || ' / IndicateurTaxable=' || v_venteProduit.IndicateurTaxable || ' / QteAchetee=' || v_venteProduit.QteAchetee || ' / PrixUnitaire=' || v_venteProduit.PrixUnitaire || ' / TotalAchatProduit=' || v_venteProduit.TotalAchatProduit);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('État de la table BI_Ventes avant');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_vente.VenteID || ' / NoMembre=' || v_vente.NoMembre || ' / ModePaiementCd=' || v_vente.ModePaiementCd || ' / DateVente=' || v_vente.DateVente || ' / TotalVente=' || v_vente.TotalVente || ' / TaxeProvCourante=' || v_vente.TaxeProvCourante || ' / TaxeFedCourante=' || v_vente.TaxeFedCourante || ' / TotalTaxes=' || v_vente.TotalTaxes || ' / GrandTotalVente=' || v_vente.GrandTotalVente);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    INSERT INTO BI_VentesProduits (VenteID, CodeProduit, QteAchetee) VALUES (v_venteID, 4, 1);
    INSERT INTO BI_VentesProduits (VenteID, CodeProduit, QteAchetee) VALUES (v_venteID, 3, 2);
    
    DBMS_OUTPUT.PUT_LINE('État de la table BI_VentesProduits après');
    FOR v_venteProduit IN c_ventesProduits LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_venteProduit.VenteID || ' / CodeProduit=' || v_venteProduit.CodeProduit || ' / IndicateurTaxable=' || v_venteProduit.IndicateurTaxable || ' / QteAchetee=' || v_venteProduit.QteAchetee || ' / PrixUnitaire=' || v_venteProduit.PrixUnitaire || ' / TotalAchatProduit=' || v_venteProduit.TotalAchatProduit);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('État de la table BI_Ventes après');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_vente.VenteID || ' / NoMembre=' || v_vente.NoMembre || ' / ModePaiementCd=' || v_vente.ModePaiementCd || ' / DateVente=' || v_vente.DateVente || ' / TotalVente=' || v_vente.TotalVente || ' / TaxeProvCourante=' || v_vente.TaxeProvCourante || ' / TaxeFedCourante=' || v_vente.TaxeFedCourante || ' / TotalTaxes=' || v_vente.TotalTaxes || ' / GrandTotalVente=' || v_vente.GrandTotalVente);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('***** Démonstration de la mise à jour de la quantitée d''un enregistrement  *****');
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_VentesProduits avant');
    FOR v_venteProduit IN c_ventesProduits LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_venteProduit.VenteID || ' / CodeProduit=' || v_venteProduit.CodeProduit || ' / IndicateurTaxable=' || v_venteProduit.IndicateurTaxable || ' / QteAchetee=' || v_venteProduit.QteAchetee || ' / PrixUnitaire=' || v_venteProduit.PrixUnitaire || ' / TotalAchatProduit=' || v_venteProduit.TotalAchatProduit);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_Ventes avant');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_vente.VenteID || ' / NoMembre=' || v_vente.NoMembre || ' / ModePaiementCd=' || v_vente.ModePaiementCd || ' / DateVente=' || v_vente.DateVente || ' / TotalVente=' || v_vente.TotalVente || ' / TaxeProvCourante=' || v_vente.TaxeProvCourante || ' / TaxeFedCourante=' || v_vente.TaxeFedCourante || ' / TotalTaxes=' || v_vente.TotalTaxes || ' / GrandTotalVente=' || v_vente.GrandTotalVente);
    END LOOP;
    
    UPDATE BI_VentesProduits SET QteAchetee = 1 WHERE VenteID = v_venteID AND CodeProduit = 3;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_VentesProduits après');
    FOR v_venteProduit IN c_ventesProduits LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_venteProduit.VenteID || ' / CodeProduit=' || v_venteProduit.CodeProduit || ' / IndicateurTaxable=' || v_venteProduit.IndicateurTaxable || ' / QteAchetee=' || v_venteProduit.QteAchetee || ' / PrixUnitaire=' || v_venteProduit.PrixUnitaire || ' / TotalAchatProduit=' || v_venteProduit.TotalAchatProduit);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_Ventes après');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_vente.VenteID || ' / NoMembre=' || v_vente.NoMembre || ' / ModePaiementCd=' || v_vente.ModePaiementCd || ' / DateVente=' || v_vente.DateVente || ' / TotalVente=' || v_vente.TotalVente || ' / TaxeProvCourante=' || v_vente.TaxeProvCourante || ' / TaxeFedCourante=' || v_vente.TaxeFedCourante || ' / TotalTaxes=' || v_vente.TotalTaxes || ' / GrandTotalVente=' || v_vente.GrandTotalVente);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('***** Démonstration de la suppression d''un enregistrement  *****');
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_VentesProduits avant');
    FOR v_venteProduit IN c_ventesProduits LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_venteProduit.VenteID || ' / CodeProduit=' || v_venteProduit.CodeProduit || ' / IndicateurTaxable=' || v_venteProduit.IndicateurTaxable || ' / QteAchetee=' || v_venteProduit.QteAchetee || ' / PrixUnitaire=' || v_venteProduit.PrixUnitaire || ' / TotalAchatProduit=' || v_venteProduit.TotalAchatProduit);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_Ventes avant');
    FOR v_vente IN c_ventes LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_vente.VenteID || ' / NoMembre=' || v_vente.NoMembre || ' / ModePaiementCd=' || v_vente.ModePaiementCd || ' / DateVente=' || v_vente.DateVente || ' / TotalVente=' || v_vente.TotalVente || ' / TaxeProvCourante=' || v_vente.TaxeProvCourante || ' / TaxeFedCourante=' || v_vente.TaxeFedCourante || ' / TotalTaxes=' || v_vente.TotalTaxes || ' / GrandTotalVente=' || v_vente.GrandTotalVente);
    END LOOP;
    
    DELETE FROM BI_VentesProduits WHERE VenteID = v_venteID AND CodeProduit = 3;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('État de la table BI_VentesProduits après');
    FOR v_venteProduit IN c_ventesProduits LOOP
        DBMS_OUTPUT.PUT_LINE('VenteID=' || v_venteProduit.VenteID || ' / CodeProduit=' || v_venteProduit.CodeProduit || ' / IndicateurTaxable=' || v_venteProduit.IndicateurTaxable || ' / QteAchetee=' || v_venteProduit.QteAchetee || ' / PrixUnitaire=' || v_venteProduit.PrixUnitaire || ' / TotalAchatProduit=' || v_venteProduit.TotalAchatProduit);
    END LOOP;
    ROLLBACK TO avantOperation;
END;    

-- QUESTION 5 2pts
-- Creation de la table historique
CREATE TABLE BI_HistoriqueCommentaire(
    CommentaireId NUMBER(7) NOT NULL,
    EmpruntId NUMBER NOT NULL,
    Commentaire VARCHAR(200) NOT NULL,
    DateCommentaire DATE NOT NULL
);

-- Declencheur
CREATE OR REPLACE TRIGGER TR_05Emprunt
    BEFORE INSERT OR DELETE OR UPDATE OF DateRetour, ModePaiementCd ON BI_Emprunts 
    FOR EACH ROW
DECLARE
     typeArticle BI_Articles.TYPEARTICLE%TYPE;
     nombreJourEmpruntLivre NUMBER;
     jourRetard NUMBER;
BEGIN
    IF INSERTING THEN
        -- Champs id
        :NEW.EmpruntID := seq_EmpruntID.NEXTVAL;
        
         -- Champs ISBN
        SELECT ISBN INTO :NEW.ISBN FROM BI_CopiesArticles WHERE NoArticle = :NEW.NoArticle;
        :NEW.DateEmprunt := trunc(SYSDATE);

        -- DateEmprunt
        :NEW.DateEmprunt := trunc(SYSDATE);
                
        -- DateRetourPrevue et AmendeParJour
        -- Aller chercher le type de article
        SELECT  TypeArticle INTO typeArticle FROM BI_Articles WHERE ISBN = (Select ISBN FROM BI_CopiesArticles WHERE NoArticle = :NEW.NoArticle);
        
        -- Aller chercher nombre jour emprunt pour les emprunts de livre
        SELECT NbJoursSurEmprunt INTO nombreJourEmpruntLivre FROM BI_TypesMembres WHERE TypeMembre = (SELECT TypeMembre FROM BI_Membres WHERE NoMembre = :NEW.NoMembre);
        
        IF typeArticle = 'LI' THEN
            :NEW.DateRetourPrevue := :NEW.DateEmprunt + nombreJourEmpruntLivre;
            :NEW.AmendeParJour := 0.2;
        ELSIF typeArticle = 'DVD' OR typeArticle = 'BLU' THEN
            :NEW.DateRetourPrevue := :NEW.DateEmprunt + 7;
            :NEW.AmendeParJour := 1.0;
        ELSIF typeArticle = 'JEU' THEN
            :NEW.DateRetourPrevue := :NEW.DateEmprunt + 10;
            :NEW.AmendeParJour := 1.25;
        END IF;
        
        -- DateRetour
        :NEW.DateRetour := NULL;
        
        -- NbJourDeRetard
        :NEW.NbJoursDeRetard := 0;
        
        -- IndicateurPerte
        :NEW.IndicateurPerte := '0';
        
        -- TotalAmende
        :NEW.TotalAmende := 0;
        
        -- ModePaiementCd
        :NEW.ModePaiementCd := NULL;
         
        -- IndicateurDisponible
        UPDATE BI_CopiesArticles SET IndicateurDisponible = '0' WHERE noArticle = :NEW.NoArticle;
    END IF;
    
    IF UPDATING  THEN
        jourRetard := :NEW.DateRetour - :OLD.DateRetourPrevue;
            IF jourRetard > 0 THEN
                :NEW.TotalAmende := jourRetard * :OLD.AmendeParJour;
                :NEW.NbJoursDeRetard := jourRetard;
            END IF;
            UPDATE BI_CopiesArticles SET IndicateurDisponible = '1';
    END IF;      
            
    IF DELETING THEN
        INSERT INTO BI_HistoriqueCommentaire (CommentaireId, EmpruntId, Commentaire, DateCommentaire)
        SELECT commentaireid, empruntid, commentaire, datecommentaire  FROM BI_Commentaires
        WHERE EmpruntId = :OLD.EmpruntId;
        
        DELETE FROM BI_Commentaires WHERE EmpruntId = :OLD.EmpruntId;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;

-- Bloc anonyme test question05
DECLARE
    empruntAvecRetard BI_EMPRUNTS%ROWTYPE;
    empruntSansRetard BI_EMPRUNTS%ROWTYPE;
    articleDisponibilite BI_Copiesarticles%ROWTYPE;
    quantiteEmprunt number;
    quantiteCommentaire number;
    commentaireHistorique BI_HistoriqueCommentaire%ROWTYPE;
    id1 number;
    id2 number;
BEGIN    
    -- Inserer 2 nouveaux emprunts
    INSERT INTO BI_Emprunts (NoMembre, NoArticle) VALUES(1, 2);
    id1 := seq_EmpruntID.CURRVAL;
    INSERT INTO BI_Emprunts (NoMembre, NoArticle) VALUES(1, 3);
    id2 := seq_EmpruntID.CURRVAL;
    
    -- Aller chercher 2 nouveaux emprunts pour voir etat
    SELECT * INTO empruntAvecRetard FROM BI_Emprunts WHERE empruntid = id1;
    SELECT * INTO empruntSansRetard FROM BI_Emprunts WHERE empruntid = id2;
    
    -- Aller chercher copie de article pour voir son statut de disponibilite
    SELECT * INTO articleDisponibilite FROM BI_Copiesarticles WHERE NoArticle = 2;
    
    DBMS_OUTPUT.PUT_LINE('Insert nouvels emprunts: ');
    DBMS_OUTPUT.PUT_LINE('Emprunt Id: ' || empruntAvecRetard.empruntid || ' NumeroMembre: ' || empruntAvecRetard.NoMembre || ' No Article: ' || empruntAvecRetard.noarticle || ' Date emprunt: ' || empruntAvecRetard.dateemprunt || ' Date retour prevue: ' || empruntAvecRetard.dateretourprevue || ' Date retour: ' || empruntAvecRetard.dateretour || ' Nombre jour retard: ' || empruntAvecRetard.nbjoursderetard || ' amende par jour: ' || empruntAvecRetard.amendeparjour || ' indicateur Perte: ' || empruntAvecRetard.indicateurperte || ' total amende: ' || empruntAvecRetard.totalamende || ' mode paiement: ' || empruntAvecRetard.modepaiementcd || ' isbn: ' || empruntAvecRetard.isbn);
    DBMS_OUTPUT.PUT_LINE('Emprunt Id: ' || empruntSansRetard.empruntid || ' NumeroMembre: ' || empruntSansRetard.NoMembre || ' No Article: ' || empruntSansRetard.noarticle || ' Date emprunt: ' || empruntSansRetard.dateemprunt || ' Date retour prevue: ' || empruntSansRetard.dateretourprevue || ' Date retour: ' || empruntSansRetard.dateretour || ' Nombre jour retard: ' || empruntSansRetard.nbjoursderetard || ' amende par jour: ' || empruntSansRetard.amendeparjour || ' indicateur Perte: ' || empruntSansRetard.indicateurperte || ' total amende: ' || empruntSansRetard.totalamende || ' mode paiement: ' || empruntSansRetard.modepaiementcd || ' isbn: ' || empruntSansRetard.isbn);
    DBMS_OUTPUT.PUT_LINE('Statut article disponibilite apres emprunt de article 3: ' || articleDisponibilite.indicateurdisponible);
    
    -- update emprunt
    UPDATE BI_Emprunts SET DateRetour = '2022-02-18' where empruntid = id1;
    UPDATE BI_Emprunts SET DateRetour = '2022-02-21' where empruntid = id2;
    SELECT * INTO empruntAvecRetard FROM BI_Emprunts WHERE empruntid = id1;
    SELECT * INTO empruntSansRetard FROM BI_Emprunts WHERE empruntid = id2;
    
     -- Aller chercher article statut apres le retour
    SELECT * INTO articleDisponibilite FROM BI_Copiesarticles WHERE NoArticle = 2;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Emprunt sans retard');
    DBMS_OUTPUT.PUT_LINE('Emprunt Id: ' || empruntAvecRetard.empruntid || ' NumeroMembre: ' || empruntAvecRetard.NoMembre || ' No Article: ' || empruntAvecRetard.noarticle || ' Date emprunt: ' || empruntAvecRetard.dateemprunt || ' Date retour prevue: ' || empruntAvecRetard.dateretourprevue || ' Date retour: ' || empruntAvecRetard.dateretour || ' Nombre jour retard: ' || empruntAvecRetard.nbjoursderetard || ' amende par jour: ' || empruntAvecRetard.amendeparjour || ' indicateur Perte: ' || empruntAvecRetard.indicateurperte || ' total amende: ' || empruntAvecRetard.totalamende || ' mode paiement: ' || empruntAvecRetard.modepaiementcd || ' isbn: ' || empruntAvecRetard.isbn);
    DBMS_OUTPUT.PUT_LINE('Emprunt avec retard');
    DBMS_OUTPUT.PUT_LINE('Emprunt Id: ' || empruntSansRetard.empruntid || ' NumeroMembre: ' || empruntSansRetard.NoMembre || ' No Article: ' || empruntSansRetard.noarticle || ' Date emprunt: ' || empruntSansRetard.dateemprunt || ' Date retour prevue: ' || empruntSansRetard.dateretourprevue || ' Date retour: ' || empruntSansRetard.dateretour || ' Nombre jour retard: ' || empruntSansRetard.nbjoursderetard || ' amende par jour: ' || empruntSansRetard.amendeparjour || ' indicateur Perte: ' || empruntSansRetard.indicateurperte || ' total amende: ' || empruntSansRetard.totalamende || ' mode paiement: ' || empruntSansRetard.modepaiementcd || ' isbn: ' || empruntSansRetard.isbn);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Statut article disponibilite apres retour de article 3: ' || articleDisponibilite.indicateurdisponible);
    
    
    -- Avant delete
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Avant delete: ');
    SELECT COUNT(*) INTO quantiteemprunt FROM BI_Emprunts WHERE empruntid = 2;
    SELECT COUNT(*) INTO quantitecommentaire FROM BI_Commentaires WHERE empruntid = 2;
    DBMS_OUTPUT.PUT_LINE('Nombre emprunt pour id emprunt de 1: ' || quantiteemprunt);
    DBMS_OUTPUT.PUT_LINE('Nombre commentaire pour id emprunt de 1: ' || quantitecommentaire);
    
    DELETE FROM BI_Emprunts WHERE empruntid = 2;
    
    -- Apres delete
    DBMS_OUTPUT.PUT_LINE('Apres delete: ');
    SELECT COUNT(*) INTO quantiteemprunt FROM BI_Emprunts WHERE empruntid = 2;
    SELECT COUNT(*) INTO quantitecommentaire FROM BI_Commentaires WHERE empruntid = 2;
    DBMS_OUTPUT.PUT_LINE('Nombre emprunt pour id emprunt de 1: ' || quantiteemprunt);
    DBMS_OUTPUT.PUT_LINE('Nombre commentaire pour id emprunt de 1: ' || quantitecommentaire);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Ajout du commentaire dans table historique ');
    SELECT * INTO commentairehistorique  FROM BI_Historiquecommentaire WHERE EmpruntId = 2;
    DBMS_OUTPUT.PUT_LINE('commentaireId: ' || commentairehistorique.CommentaireId || ' empruntId: ' || commentairehistorique.EmpruntId || ' commentaire: ' || commentairehistorique.Commentaire || ' date commentaire: ' || commentairehistorique.DateCommentaire);
END;


-- QUESTION 6 2pts
-- Declencheur
CREATE OR REPLACE TRIGGER TR_06Location
BEFORE INSERT ON BI_Emprunts
FOR EACH ROW
DECLARE
    const_nbEmpruntsMaximum CONSTANT NUMBER := 10;
    v_nbEmpruntsEnCoursMembre NUMBER(2,0) := 0;
BEGIN
    SELECT COUNT(*) INTO v_nbEmpruntsEnCoursMembre FROM BI_Emprunts WHERE NoMembre = :NEW.NoMembre AND DateRetour IS NULL;
    
    IF (v_nbEmpruntsEnCoursMembre >= const_nbEmpruntsMaximum) THEN       
        RAISE_APPLICATION_ERROR(-20008, 'Le nombre de locations maximum simultanées par membre est de 10.');
    END IF;
EXCEPTION
WHEN OTHERS THEN
    Pkg_Tp3.FCT_AjouterTableLog(SQLCODE, SQLERRM, sys.DBMS_UTILITY.format_error_backtrace, sys.DBMS_UTILITY.format_call_stack, USER);
END;

    -- Bloc anonyme test question06
BEGIN
    SAVEPOINT avantOperation;
    INSERT INTO BI_Emprunts (EmpruntID,NoMembre,NoArticle,DateEmprunt,DateRetourPrevue,AmendeParJour,IndicateurPerte,ISBN,TotalAmende) 
    VALUES (seq_EmpruntID.NEXTVAL,2,2,'2021-02-02','2021-12-31',1,1,'978-2-70964-192-0',1);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK TO avantOperation;
END; 

    -- Bloc anonyme test question07
DECLARE
    empruntsMois emprunts_q7;
BEGIN
    empruntsMois := emprunts_q7();
    empruntsMois := Pkg_Tp3.FCT_07Best(2021, 09);
    
    FOR noLigne IN 1 .. empruntsMois.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Titre article: ' || TO_CHAR(empruntsMois(noLigne).titreArticle)  || ' --- Nombre de fois commande durant le mois 09 de annee 2021: ' || TO_CHAR(empruntsMois(noLigne).nombreEmprunt) || ' fois' );
    END LOOP;
END;

 -- Bloc anonyme test question08
DECLARE
    locationsAuteurs tableauLocations := tableauLocations();
    locationsArticles tableauLocations := tableauLocations();
    locationsMembres tableauLocations := tableauLocations();
BEGIN
    locationsAuteurs := Pkg_Tp3.FCT_08SommaireLocation('Auteur');
    locationsArticles := Pkg_Tp3.FCT_08SommaireLocation('Article');
    locationsMembres := Pkg_Tp3.FCT_08SommaireLocation('Membre');
    
    DBMS_OUTPUT.PUT_LINE('Locations liés aux auteurs');
    FOR indx IN 1 .. locationsAuteurs.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('NomAuteur : ' || locationsAuteurs(indx).nomSujet || ', NbLocations : ' || locationsAuteurs(indx).nbLocations);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Locations liés aux articles');
    FOR indx IN 1 .. locationsArticles.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('NomArticle : ' || locationsArticles(indx).nomSujet || ', NbLocations : ' || locationsArticles(indx).nbLocations);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Locations liés aux membres');
    FOR indx IN 1 .. locationsMembres.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('NomMembre : ' || locationsMembres(indx).nomSujet || ', NbLocations : ' || locationsMembres(indx).nbLocations);
    END LOOP;
    
END;
-- Tester Paramètre invalide
SELECT * FROM TABLE(FCT_08SommaireLocation('abcde'));