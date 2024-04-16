-- #### NIVEL 1 ####
USE transactions;

-- Ex1: Muestra todas las transacciones realizadas por empresas de Alemania usando subquery.
SELECT id
FROM transaction
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE country = 'Germany'
);

-- Ex2: Lista de empresas que han realizado transacciones superiores a la media de todas las transacciones.
SELECT DISTINCT company_name AS Nombre_Empresa
FROM company
WHERE id IN (
    SELECT company_id
    FROM transaction
    WHERE amount > (
        SELECT AVG(amount) AS Media
        FROM transaction
    )
);

-- Ex3: Información de las transacciones realizadas por una empresa cuyo nombre inicia con 'c'.
SELECT id, (
    SELECT company_name
    FROM company
    WHERE transaction.company_id = company.id
) AS Empresa
FROM transaction
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE company_name LIKE 'c%'
);

-- Ex4: Listado de empresas que no tienen transacciones registradas.
SELECT *
FROM company
WHERE NOT EXISTS (
    SELECT company_id
    FROM transaction
    WHERE company.id = transaction.company_id
);

-- #### NIVEL 2 ####

-- Ex1: Lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que la empresa 'Non Institute'.
SELECT transaction.id, empresa.country AS Pais, empresa.company_name AS Nombre_Empresa
FROM transaction, (
    SELECT *
    FROM company
    WHERE company.country = (
        SELECT company.country
        FROM company
        WHERE company_name = 'Non Institute'
    )
) AS empresa
WHERE empresa.id = transaction.company_id;

-- Ex2: Empresa que ha realizado la transacción de mayor valor en la base de datos.
SELECT empresas.id AS id_empresa, company_name AS Empresa, amount AS Max_Venta
FROM transaction, (
    SELECT *
    FROM company
) AS empresas
WHERE empresas.id = transaction.company_id
AND amount = (
    SELECT MAX(amount)
    FROM transaction
);

-- #### NIVEL 3 ####

-- Ex1: Listado de los países cuya media de transacciones es superior a la media general.
SELECT company.country AS Pais, ROUND(AVG(operaciones.amount), 2) AS Media_Empresas
FROM company, (
    SELECT *
    FROM transaction
) AS operaciones
WHERE company.id = operaciones.company_id
GROUP BY Pais
HAVING Media_Empresas > (
    SELECT AVG(transaction.amount)
    FROM transaction
)
ORDER BY Media_Empresas DESC;

-- Ex2: Listado de empresas especificando si tienen más de 4 transacciones o menos.
SELECT company.company_name AS Empresa, COUNT(operations.id) AS Total_Operaciones, 
CASE 
    WHEN COUNT(operations.id) >= 4 THEN 'Sí' 
    ELSE 'No' 
END AS Mas_4_Operaciones
FROM company, (
    SELECT *
    FROM transaction
) AS operations
WHERE company.id = operations.company_id
GROUP BY Empresa
ORDER BY Total_Operaciones DESC;
