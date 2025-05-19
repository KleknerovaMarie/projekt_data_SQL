CREATE OR REPLACE VIEW wages_trend_table AS
SELECT 
	p_year,
	industry_code,
	industry,
    avg_wage,
    LAG(avg_wage) OVER (PARTITION BY industry ORDER BY p_year) AS previous_avg,
    ROUND(
        (avg_wage - LAG(avg_wage) OVER (PARTITION BY industry ORDER BY p_year)) 
        / LAG(avg_wage) OVER (PARTITION BY industry ORDER BY p_year)::numeric * 100, 
        1
    ) AS percentage_difference,
    CASE 
        WHEN avg_wage > LAG(avg_wage) OVER (PARTITION BY industry ORDER BY p_year) THEN 'vzrostly'
        WHEN avg_wage < LAG(avg_wage) OVER (PARTITION BY industry ORDER BY p_year) THEN 'klesly'
        ELSE 'stejné'
    END AS wage_trend
FROM
	t_marie_kleknerova_project_SQL_primary_final
GROUP BY p_year,
	industry_code,
	industry,
    avg_wage
ORDER BY
	industry ASC,
		p_year ASC; 


SELECT *
FROM wages_trend_table
WHERE p_year BETWEEN 2007 AND 2018
ORDER BY industry ASC;

SELECT *
FROM wages_trend_table
WHERE wage_trend = 'vzrostly'
ORDER BY percentage_difference DESC
LIMIT 10;

SELECT *
FROM wages_trend_table
WHERE wage_trend = 'klesly'
ORDER BY percentage_difference ASC
LIMIT 10;

SELECT *
FROM wages_trend_table 
ORDER BY avg_wage DESC;

SELECT *
FROM wages_trend_table
ORDER BY avg_wage ASC;
