-- Cr�er un compte utilisateur et donnez-lui des droits
CREATE USER kristopher IDENTIFIED BY admin;
GRANT ALL PRIVILEGES TO kristopher;

-- Changer le format des dates (Bonne pratique a faire a tous les scripts)
ALTER SESSION SET NLS_DATE_FORMAT = 'dd-mm-yyyy';


-- 1. Affichez le nom de l'employ� et son titre mais le tout sous la forme suivante: "Magee est un Sales Representative".
-- La nouvelle colonne se nomme Description. (25 enregistrements)
SELECT CONCAT( CONCAT(FIRST_NAME, ' est un(e)'), TITLE) AS "Nom et titre" FROM s_emp;
SELECT FIRST_NAME || ' est un(e) ' || TITLE AS "Nom et titre" FROM s_emp;


-- 2. Affichez le nom, le titre d�emploi et la date d'embauche des employ�s qui ont �t� embauch�s entre le 15 mai 1990 et le 30 d�cembre 1991.
-- Affichez le tout en ordre d�croissant de nom de famille. (13 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Pr�nom", TITLE AS "Titre", START_DATE AS "Date D'embauche" FROM S_EMP
    WHERE START_DATE BETWEEN '15-05-1990' AND '30-12-1991'
    ORDER BY LAST_NAME ASC;


-- 3. Affichez le nom des vendeurs (first_name et last_name sur une m�me colonne et s�par�s 
-- d'une espace) et le nom de tous leurs clients (name). Triez en ordre croissant de nom de 
-- vendeur et de clients. Utilisez des noms de colonnes significatifs dans votre affichage. Vous 
-- devez afficher seulement les vendeurs qui ont des clients. (14 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Nom vendeur", NAME AS "Nom client" FROM S_EMP
    INNER JOIN S_CUSTOMER
        ON S_EMP.ID = S_CUSTOMER.SALES_REP_ID;


-- 4. Affichez le nom et le titre des employ�s qui n�ont pas de sup�rieur. (1 enregistrement)
SELECT LAST_NAME AS "Employ�(s) sans sup�rieur", TITLE AS "Titre" FROM S_EMP
    WHERE MANAGER_ID IS NULL;


-- 5. Affichez les noms des employ�s dont la troisi�me lettre du nom de famille est un a.
-- (2 enregistrements)
SELECT LAST_NAME AS "Employ� dont troisi�me lettre nom de famille a" FROM S_EMP
    WHERE LAST_NAME LIKE '__a%';


-- 6. Affichez le nom des employ�s qui ont un n dans leur nom de famille et que leur d�partement 
-- est Operations. (7 enregistrements)
SELECT LAST_NAME AS "Nom employ�" FROM S_EMP
    INNER JOIN S_DEPT
        ON S_EMP.DEPT_ID = S_DEPT.ID
    WHERE lower(LAST_NAME) LIKE '%n%' AND NAME LIKE 'Operations'; 


-- 7. Affichez le nom des clients qui ont d�j� pay�s une commande par carte de cr�dit (CREDIT).
-- Assurez-vous qu�il n�y ait pas de noms en double. (11 enregistrements)
SELECT NAME FROM S_CUSTOMER
    INNER JOIN S_ORD
        ON S_CUSTOMER.ID = s_ord.customer_id
    WHERE PAYMENT_TYPE LIKE 'CREDIT'
    GROUP BY NAME;
    
    
-- 8. Affichez les clients qui ont une cote de cr�dit excellente et qui habitent en Europe, information 
-- fournie par la table S_REGION. (2 enregistrements)
SELECT c.NAME AS "Nom du client" FROM S_CUSTOMER c
    INNER JOIN S_REGION r
        ON c.REGION_ID = r.ID
    WHERE CREDIT_RATING LIKE 'EXCELLENT' AND r.NAME LIKE 'Europe';


-- 9. Affichez l�adresse des entrep�ts ayant en stock le produit New Air Pump. (4 enregistrements)
SELECT w.ID, ADDRESS FROM S_WAREHOUSE w
    INNER JOIN S_INVENTORY i
        ON w.id = i.warehouse_id
    INNER JOIN S_PRODUCT p
        ON i.PRODUCT_ID = p.id
    WHERE LOWER(p.NAME) LIKE 'new air pump' AND i.amount_in_stock > 0;


-- 10. Affichez le num�ro des commandes comportant un des produits suivants : Bunny Boot, Bunny 
-- Ski Pole, Pro Ski Boot ou Pro Ski Pole. La requ�te ne doit pas produire le m�me num�ro de 
-- commande plus d'une fois. (2 enregistrements)
SELECT DISTINCT o.ID AS "Num�ro de commande" FROM S_ORD o
    INNER JOIN S_ITEM i
        ON o.ID = i.ORD_ID
    INNER JOIN S_PRODUCT p
        ON i.PRODUCT_ID = p.id
    WHERE LOWER(p.NAME) IN ('bunny boot', 'bunny ski pole', 'pro ski boot', 'pro ski pole');


-- 11. Affichez le num�ro, nom et pr�nom des employ�s dont le pr�nom est Mark ou Colin ET dont le 
-- nom est Patel ou Magee. (1 enregistrement)
SELECT USERID AS "Num�ro", LAST_NAME AS "Nom", FIRST_NAME AS "Pr�nom" FROM S_EMP
    WHERE LOWER(FIRST_NAME) IN ('mark', 'colin') AND LOWER(LAST_NAME) IN ('patel', 'magee');


-- 12. Affichez le nom de tous les employ�s du d�partement des ventes (sales) dont le salaire n�est 
-- pas entre 1500 et 2000 (5 enregistrements)
SELECT e.FIRST_NAME AS "Nom" FROM S_EMP e
    INNER JOIN S_DEPT d
        ON e.DEPT_ID = d.ID
    WHERE LOWER(d.NAME) LIKE 'sales' AND e.SALARY NOT BETWEEN 1500 AND 2000;
        

-- 13. Affichez le nom et pr�nom ainsi que le salaire annuel des employ�s si nous y ajoutons un 
-- bonus annuel de 500.00$. La base de donn�es contient pr�sentement des salaires mensuels. 
-- Nommez la nouvelle colonne "Annuel". Triez les enregistrements en ordre d�croissant de 
-- salaire annuel. (25 enregistrements)
SELECT LAST_NAME AS "Nom", FIRST_NAME AS "Pr�nom", (SALARY * 12 + 500) AS "Annuel" FROM S_EMP
    ORDER BY (SALARY * 12 + 500) DESC;


-- 14. Affichez tous les num�ros de commande ainsi que les dates de commande et de livraison pour 
-- toutes les commandes ayant �t� effectu�es pendant un mois d'ao�t et exp�di�es pendant un 
-- mois de septembre, peu importe l'ann�e. (6 enregistrements)
SELECT ID, DATE_ORDERED, DATE_SHIPPED FROM S_ORD
    WHERE EXTRACT(MONTH FROM DATE_ORDERED) = 08 AND EXTRACT(MONTH FROM DATE_SHIPPED) = 09;


-- 15. Affichez le nom de l'employ�, sa date d'embauche et ajoutez une colonne affichant la date de 
-- r�vision du salaire. Cette date est apr�s six mois de service. (25 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Nom", START_DATE, ADD_MONTHS(START_DATE, 6) FROM S_EMP;


-- 16. Pour chaque employ� dont le salaire bi-annuel (2 fois par ann�e) est 9000 $ ou plus, affichez le 
-- nom complet, le salaire et la date d�embauche. (4 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Nom complet", SALARY, START_DATE FROM S_EMP
    WHERE SALARY * 6 > 9000;


-- 17. Affichez le nom de famille des employ�s, leur date d'embauche et leur anciennet�. 
-- L'anciennet� est �quivalente aux ann�es enti�rement compl�t�es (pas de d�cimales). Les 
-- titres des colonnes � l'affichage doivent �tre les suivants : Nom, Date d'embauche, 
-- Anciennet�. (25 enregistrements)
SELECT LAST_NAME AS "Nom", START_DATE AS "Date d'embauche", FLOOR(months_between(CURRENT_DATE, START_DATE) / 12) AS "Anciennete" FROM S_EMP; -- Trouv� sur internet


-- 18. Pour chaque produit de la commande 106, affichez le nom du produit, la quantit� achet�e, le 
-- prix unitaire, le sous-total avant taxes ainsi que le total avec taxes. (6 enregistrements)
SELECT NAME AS "Nom produit", i.QUANTITY AS "Quantite", i.PRICE AS "Prix unitaire", i.QUANTITY * i.PRICE AS "Sous-total", (i.QUANTITY * i.PRICE) * 1.15 AS "Prix total avec taxes"  FROM S_ORD o
    INNER JOIN S_ITEM i
        ON o.id = i.ord_id
    INNER JOIN S_PRODUCT p
        ON i.PRODUCT_ID = p.id
    WHERE o.id = 106;
