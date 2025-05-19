DROP TABLE t_Marie_Kleknerova_project_SQL_secondary_final CASCADE;

CREATE TABLE t_Marie_Kleknerova_project_SQL_secondary_final AS
SELECT e.country,
		e.year AS e_year,
		e.gdp,
		e.gini,
		c.population
FROM economies e
JOIN countries c
	ON e.country = c.country 
WHERE e.year BETWEEN 2006 AND 2018
		AND c.continent = 'Europe'
ORDER BY e.year ASC;