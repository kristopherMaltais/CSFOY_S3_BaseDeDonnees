-- Créer un compte utilisateur et donnez-lui des droits
CREATE USER kristopher IDENTIFIED BY admin;
GRANT ALL PRIVILEGES TO kristopher;

-- Changer le format des dates (Bonne pratique a faire a tous les scripts)
ALTER SESSION SET NLS_DATE_FORMAT = 'dd-mm-yyyy';


-- 1. Affichez le nom de l'employé et son titre mais le tout sous la forme suivante: "Magee est un Sales Representative".
-- La nouvelle colonne se nomme Description. (25 enregistrements)
SELECT CONCAT( CONCAT(FIRST_NAME, ' est un(e)'), TITLE) AS "Nom et titre" FROM s_emp;
SELECT FIRST_NAME || ' est un(e) ' || TITLE AS "Nom et titre" FROM s_emp;


-- 2. Affichez le nom, le titre d’emploi et la date d'embauche des employés qui ont été embauchés entre le 15 mai 1990 et le 30 décembre 1991.
-- Affichez le tout en ordre décroissant de nom de famille. (13 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Prénom", TITLE AS "Titre", START_DATE AS "Date D'embauche" FROM S_EMP
    WHERE START_DATE BETWEEN '15-05-1990' AND '30-12-1991'
    ORDER BY LAST_NAME ASC;


-- 3. Affichez le nom des vendeurs (first_name et last_name sur une même colonne et séparés 
-- d'une espace) et le nom de tous leurs clients (name). Triez en ordre croissant de nom de 
-- vendeur et de clients. Utilisez des noms de colonnes significatifs dans votre affichage. Vous 
-- devez afficher seulement les vendeurs qui ont des clients. (14 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Nom vendeur", NAME AS "Nom client" FROM S_EMP
    INNER JOIN S_CUSTOMER
        ON S_EMP.ID = S_CUSTOMER.SALES_REP_ID;


-- 4. Affichez le nom et le titre des employés qui n’ont pas de supérieur. (1 enregistrement)
SELECT LAST_NAME AS "Employé(s) sans supérieur", TITLE AS "Titre" FROM S_EMP
    WHERE MANAGER_ID IS NULL;


-- 5. Affichez les noms des employés dont la troisième lettre du nom de famille est un a.
-- (2 enregistrements)
SELECT LAST_NAME AS "Employé dont troisième lettre nom de famille a" FROM S_EMP
    WHERE LAST_NAME LIKE '__a%';


-- 6. Affichez le nom des employés qui ont un n dans leur nom de famille et que leur département 
-- est Operations. (7 enregistrements)
SELECT LAST_NAME AS "Nom employé" FROM S_EMP
    INNER JOIN S_DEPT
        ON S_EMP.DEPT_ID = S_DEPT.ID
    WHERE lower(LAST_NAME) LIKE '%n%' AND NAME LIKE 'Operations'; 


-- 7. Affichez le nom des clients qui ont déjà payés une commande par carte de crédit (CREDIT).
-- Assurez-vous qu’il n’y ait pas de noms en double. (11 enregistrements)
SELECT NAME FROM S_CUSTOMER
    INNER JOIN S_ORD
        ON S_CUSTOMER.ID = s_ord.customer_id
    WHERE PAYMENT_TYPE LIKE 'CREDIT'
    GROUP BY NAME;
    
    
-- 8. Affichez les clients qui ont une cote de crédit excellente et qui habitent en Europe, information 
-- fournie par la table S_REGION. (2 enregistrements)
SELECT c.NAME AS "Nom du client" FROM S_CUSTOMER c
    INNER JOIN S_REGION r
        ON c.REGION_ID = r.ID
    WHERE CREDIT_RATING LIKE 'EXCELLENT' AND r.NAME LIKE 'Europe';


-- 9. Affichez l’adresse des entrepôts ayant en stock le produit New Air Pump. (4 enregistrements)
SELECT w.ID, ADDRESS FROM S_WAREHOUSE w
    INNER JOIN S_INVENTORY i
        ON w.id = i.warehouse_id
    INNER JOIN S_PRODUCT p
        ON i.PRODUCT_ID = p.id
    WHERE LOWER(p.NAME) LIKE 'new air pump' AND i.amount_in_stock > 0;


-- 10. Affichez le numéro des commandes comportant un des produits suivants : Bunny Boot, Bunny 
-- Ski Pole, Pro Ski Boot ou Pro Ski Pole. La requête ne doit pas produire le même numéro de 
-- commande plus d'une fois. (2 enregistrements)
SELECT DISTINCT o.ID AS "Numéro de commande" FROM S_ORD o
    INNER JOIN S_ITEM i
        ON o.ID = i.ORD_ID
    INNER JOIN S_PRODUCT p
        ON i.PRODUCT_ID = p.id
    WHERE LOWER(p.NAME) IN ('bunny boot', 'bunny ski pole', 'pro ski boot', 'pro ski pole');


-- 11. Affichez le numéro, nom et prénom des employés dont le prénom est Mark ou Colin ET dont le 
-- nom est Patel ou Magee. (1 enregistrement)
SELECT USERID AS "Numéro", LAST_NAME AS "Nom", FIRST_NAME AS "Prénom" FROM S_EMP
    WHERE LOWER(FIRST_NAME) IN ('mark', 'colin') AND LOWER(LAST_NAME) IN ('patel', 'magee');


-- 12. Affichez le nom de tous les employés du département des ventes (sales) dont le salaire n’est 
-- pas entre 1500 et 2000 (5 enregistrements)
SELECT e.FIRST_NAME AS "Nom" FROM S_EMP e
    INNER JOIN S_DEPT d
        ON e.DEPT_ID = d.ID
    WHERE LOWER(d.NAME) LIKE 'sales' AND e.SALARY NOT BETWEEN 1500 AND 2000;
        

-- 13. Affichez le nom et prénom ainsi que le salaire annuel des employés si nous y ajoutons un 
-- bonus annuel de 500.00$. La base de données contient présentement des salaires mensuels. 
-- Nommez la nouvelle colonne "Annuel". Triez les enregistrements en ordre décroissant de 
-- salaire annuel. (25 enregistrements)
SELECT LAST_NAME AS "Nom", FIRST_NAME AS "Prénom", (SALARY * 12 + 500) AS "Annuel" FROM S_EMP
    ORDER BY (SALARY * 12 + 500) DESC;


-- 14. Affichez tous les numéros de commande ainsi que les dates de commande et de livraison pour 
-- toutes les commandes ayant été effectuées pendant un mois d'août et expédiées pendant un 
-- mois de septembre, peu importe l'année. (6 enregistrements)
SELECT ID, DATE_ORDERED, DATE_SHIPPED FROM S_ORD
    WHERE EXTRACT(MONTH FROM DATE_ORDERED) = 08 AND EXTRACT(MONTH FROM DATE_SHIPPED) = 09;


-- 15. Affichez le nom de l'employé, sa date d'embauche et ajoutez une colonne affichant la date de 
-- révision du salaire. Cette date est après six mois de service. (25 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Nom", START_DATE, ADD_MONTHS(START_DATE, 6) FROM S_EMP;


-- 16. Pour chaque employé dont le salaire bi-annuel (2 fois par année) est 9000 $ ou plus, affichez le 
-- nom complet, le salaire et la date d’embauche. (4 enregistrements)
SELECT FIRST_NAME || ' ' || LAST_NAME AS "Nom complet", SALARY, START_DATE FROM S_EMP
    WHERE SALARY * 6 > 9000;


-- 17. Affichez le nom de famille des employés, leur date d'embauche et leur ancienneté. 
-- L'ancienneté est équivalente aux années entièrement complétées (pas de décimales). Les 
-- titres des colonnes à l'affichage doivent être les suivants : Nom, Date d'embauche, 
-- Ancienneté. (25 enregistrements)
SELECT LAST_NAME AS "Nom", START_DATE AS "Date d'embauche", FLOOR(months_between(CURRENT_DATE, START_DATE) / 12) AS "Anciennete" FROM S_EMP; -- Trouvé sur internet


-- 18. Pour chaque produit de la commande 106, affichez le nom du produit, la quantité achetée, le 
-- prix unitaire, le sous-total avant taxes ainsi que le total avec taxes. (6 enregistrements)
SELECT NAME AS "Nom produit", i.QUANTITY AS "Quantite", i.PRICE AS "Prix unitaire", i.QUANTITY * i.PRICE AS "Sous-total", (i.QUANTITY * i.PRICE) * 1.15 AS "Prix total avec taxes"  FROM S_ORD o
    INNER JOIN S_ITEM i
        ON o.id = i.ord_id
    INNER JOIN S_PRODUCT p
        ON i.PRODUCT_ID = p.id
    WHERE o.id = 106;
