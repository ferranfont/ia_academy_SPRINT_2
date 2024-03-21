-- SPRINT 2, NIVELL 1, EXERCICI 1: Totes les transaccions de les empreses alemanyes

-- Aquí seleccionem totes les transaccions de les empreses alemanyes fent servir una subconsulta
-- La subconsulta ens permet filtrar les empreses alemanyes i obtenir-ne els IDs corresponents
SELECT * 
FROM transaction AS t2
WHERE company_id IN (
	SELECT id
	FROM company AS t1
	WHERE t2.company_id = t1.id
	AND t1.country = 'Germany'
);

-- Aquí seleccionem totes les transaccions de les empreses alemanyes fent servir INNER JOIN
-- L'ús d'INNER JOIN ens permet unir les taules i aplicar el filtre per país
SELECT * 
FROM transaction AS t2
JOIN company AS t1
ON t2.company_id = t1.id
WHERE t1.country = 'Germany';

-- SPRINT 2, NIVELL 1, EXERCICI 2: Empreses amb transaccions amb una quantitat superior a la mitjana de totes les transaccions

-- En aquest cas, seleccionem les empreses amb transaccions que tenen una quantitat superior a la mitjana de totes les transaccions
-- Utilitzem una subconsulta per calcular aquesta mitjana i filtrar les empreses corresponents
SELECT company_name
FROM company AS t1
WHERE t1.id IN (
	SELECT company_id
	FROM transaction AS t2
	WHERE t2.amount > (
		SELECT AVG(amount)
		FROM transaction AS t2
	)
);

-- SPRINT 2, NIVELL 1, EXERCICI 3: Transaccions de les empreses amb el nom que comença per la lletra C

-- Seleccionem les transaccions de les empreses amb el nom que comença per la lletra C utilitzant INNER JOIN
-- Això ens permet unir les taules i aplicar el filtre pel nom de l'empresa
SELECT t1.id, company_name
FROM company AS t1
INNER JOIN transaction AS t2
ON t1.id = t2.company_id 
WHERE company_name LIKE 'C%';

-- També podem obtenir el mateix resultat amb un INNER JOIN i una subconsulta
SELECT company_name, t2.*
FROM transaction AS t2
INNER JOIN company AS t1
ON t2.company_id = t1.id
WHERE t2.company_id IN (
	SELECT t1.id
	FROM company AS t1
	WHERE company_name LIKE 'C%'
);

-- SPRINT 2, NIVELL 1, EXERCICI 4: Llista d'empreses que estan a la taula de companyies però que no tenen cap transacció

-- Aquí obtenim les empreses que no tenen cap transacció fent servir NOT EXISTS
-- Això ens permet comprovar l'absència de registres associats a les empreses
SELECT company_name 
FROM company AS t1
WHERE NOT EXISTS (
	SELECT company_id 
	FROM transaction AS t2
	WHERE t1.id = t2.company_id
);

-- Alternativament, podem fer servir INNER JOIN i WHERE per trobar empreses sense transaccions
SELECT * 
FROM company AS t1
INNER JOIN transaction AS t2
ON t1.id = t2.company_id
WHERE t2.id IS NULL;  -- No té transaccions a la taula de transaccions

-- Per comptar empreses sense transaccions podem fer servir NOT IN
SELECT COUNT(id) AS empresas_huerfanas
FROM company AS t1
WHERE id NOT IN (
	SELECT company_id
	FROM transaction AS t2
);

##############################################################################################################

-- SPRINT 2, NIVELL 2, EXERCICI 1: Llista de transaccions del mateix país de l'empresa anomenada Non Institute

-- En aquest cas, seleccionem les transaccions del mateix país que 'Non Institute' utilitzant INNER JOIN i una subconsulta
SELECT * 
FROM transaction AS t
WHERE company_id IN (
	SELECT id
	FROM company AS c
	WHERE country IN (
		SELECT country
		FROM company AS c
		WHERE company_name = 'Non Institute'
	)
);

-- Alternativament, podem fer servir INNER JOIN i una subconsulta per trobar les transaccions del mateix país que 'Non Institute'
SELECT c.country, t.*
FROM transaction AS t
JOIN company AS c
ON c.id = t.company_id
WHERE country = (
	SELECT country
	FROM company AS c
	WHERE company_name = 'Non Institute'  
);

-- SPRINT 2, NIVELL 2, EXERCICI 2: Nom de l'empresa amb la transacció de major quantitat

-- Aquí obtenim el nom de l'empresa amb la transacció de major quantitat utilitzant INNER JOIN, SUM i ORDER BY
SELECT c.company_name, SUM(amount) AS parcial_empresa
FROM transaction AS t
JOIN company AS c
ON c.id = t.company_id
GROUP BY t.company_id
ORDER BY parcial_empresa DESC
LIMIT 1;

-- Alternativament, podem obtenir el mateix resultat utilitzant INNER JOIN, SUM i una subconsulta
SELECT company_name, subtotales.parcial_empresa
FROM company AS c
JOIN (
	SELECT SUM(amount) AS parcial_empresa, company_id 
	FROM transaction AS t
	GROUP BY t.company_id
) AS subtotales
ON subtotales.company_id = c.id
ORDER BY parcial_empresa DESC
LIMIT 1;

-- SPRINT 2, NIVELL 3, EXERCICI 1: Llista de països amb vendes agregades superiors a la mitjana de vendes

-- Aquí obtenim els països amb vendes agregades superiors a la mitjana utilitzant INNER JOIN, COUNT i HAVING
SELECT c.country, COUNT(t.id) AS contador
FROM transaction AS t
INNER JOIN company AS c
ON c.id = t.company_id
GROUP BY c.country
HAVING contador > (
	SELECT AVG(contador)
	FROM (
		SELECT COUNT(t.id) AS contador
		FROM transaction AS t
		INNER JOIN company AS c
		ON c.id = t.company_id
		GROUP BY c.country
	) AS media_global
)
ORDER BY contador DESC;

-- SPRINT 2, NIVELL 3, EXERCICI 1: Llista de països amb vendes agregades superior a la mitjana de vendes

-- En aquesta consulta, obtenim els països amb vendes agregades superiors a la mitjana utilitzant INNER JOIN, COUNT i HAVING.
-- Els resultats s'agrupen per país i es compara el nombre de transaccions amb la mitjana global de transaccions per país.
-- Els països amb un nombre de transaccions superior a la mitjana es presenten ordenats descendentment pel nombre de transaccions.
select c.country, count(t.id) as contador
from transaction as t
inner join company as c
on c.id = t.company_id
group by c.country
having contador > (
select avg(contador)
			from(
					select count(t.id) as contador
					from transaction as t
					inner join company as c
					on c.id = t.company_id
					group by c.country
			) as media_global
)
order by contador desc;

-- SPRINT 2, NIVELL 3, EXERCICI 1: Llista de països amb vendes agregades superior a la mitjana de vendes

-- Alternativament, obtenim els països amb vendes agregades superiors a la mitjana utilitzant INNER JOIN, SUM i HAVING.
-- Els resultats s'agrupen per país i es calcula la suma de les vendes per a cada país.
-- S'aplica una condició HAVING per comparar la suma de vendes amb la mitjana de vendes per país.
-- Els resultats es presenten ordenats descendentment per la suma de vendes.
select country, sum(amount) as total_pais
from transaction as t
join company as c
on c.id = t.company_id
where t.declined = 0
group by country
having total_pais  > (
			select avg(total_pais)
			from (
				select sum(amount) as total_pais
				from transaction as t
				join company as c
				on c.id = t.company_id
				where t.declined = 0
				group by country
			) as media_paises
)
order by total_pais desc;  

-- SPRINT 2, NIVELL 3, EXERCICI 3: Llista d'empreses amb més o menys de 4 transaccions

-- En aquesta consulta, obtenim una llista d'empreses amb el seu nombre de transaccions.
-- S'utilitza una sentència CASE per etiquetar les empreses com a 'Grande + 4' o 'Pequeña -4' basant-se en el nombre de transaccions.
-- Els resultats s'ordenen descendentment pel nombre de transaccions.
select company_id, company_name, count(t.id )as contador,
case
	when count(t.id ) > 4 then 'Grande + 4'
    else 'Pequeña -4'
end as casos
from transaction as t
join company as c
on c.id = t.company_id
group by company_id
order by contador desc;

