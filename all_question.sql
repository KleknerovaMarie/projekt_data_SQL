DROP TABLE IF EXISTS t_marie_kleknerova_project_sql_primary_final CASCADE;
DROP TABLE IF EXISTS t_Marie_Kleknerova_project_SQL_secondary_final CASCADE;


CREATE OR REPLACE VIEW v_marie_kleknerova_first_part AS
SELECT 
    EXTRACT(YEAR FROM cp.date_from) AS p_year,
    cpc.code,
    cpc.name AS food_category,
    ROUND(AVG(cp.value)::NUMERIC, 2) AS avg_food_price
FROM czechia_price cp
JOIN czechia_price_category cpc 
    ON cp.category_code = cpc.code
WHERE cp.region_code IS NULL
GROUP BY EXTRACT(YEAR FROM cp.date_from), cpc.code, cpc.name;


CREATE OR REPLACE VIEW v_marie_kleknerova_second_part AS
SELECT 
    cpay.payroll_year AS p_year,
    cpib.code,
    cpib.name AS industry,
    ROUND(AVG(cpay.value)::NUMERIC) AS avg_wage
FROM czechia_payroll cpay
JOIN czechia_payroll_industry_branch cpib 
    ON cpay.industry_branch_code = cpib.code
WHERE 
    cpay.value IS NOT NULL 
    AND cpay.value_type_code = 5958
    AND cpay.calculation_code = 200  
    AND cpay.payroll_year BETWEEN 2006 AND 2018
GROUP BY cpay.payroll_year, cpib.name, cpib.code
ORDER BY cpib.name ASC, cpay.payroll_year ASC;

-- Finální spojení – potraviny + mzda za daný rok
CREATE TABLE t_marie_kleknerova_project_sql_primary_final AS
SELECT 
    f.p_year,
    s.code AS industry_code,
    s.industry,
    s.avg_wage,
    f.code AS food_code,
    f.food_category,
    f.avg_food_price        
FROM v_marie_kleknerova_second_part s
LEFT JOIN v_marie_kleknerova_first_part f
    ON f.p_year = s.p_year
ORDER BY f.p_year ASC, s.industry ASC, f.food_category ASC;
SELECT *
FROM t_marie_kleknerova_project_sql_primary_final;




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




CREATE OR REPLACE VIEW mleko_chleba AS
SELECT  
    ft.p_year,
    ft.food_category,
    ft.avg_food_price,
    ft.industry,
    ft.avg_wage
FROM t_marie_kleknerova_project_SQL_primary_final ft
WHERE p_year IN (2006, 2018)
  AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový');

SELECT p_year,
		food_category,
		avg_food_price,
		industry,
		avg_wage,
		ROUND(avg_wage / avg_food_price) AS food_amount
FROM mleko_chleba
GROUP BY p_year,
		food_category,
		avg_food_price,
		industry,
		avg_wage
ORDER BY food_amount DESC;

CREATE OR REPLACE VIEW avg_chleba_mleko_wage AS
WITH unique_industry_in_year AS (
    SELECT DISTINCT 
        p_year,
        industry,
        avg_wage
    FROM t_marie_kleknerova_project_SQL_primary_final
),
avg_wage_per_year AS (
    SELECT 
        p_year,
        ROUND(AVG(avg_wage)) AS avg_avg_wage
    FROM unique_industry_in_year
    GROUP BY p_year
),
avg_food_price_per_year AS (
    SELECT 
        p_year,
        food_category,
        ROUND(AVG(avg_food_price), 2) AS avg_food_price
    FROM mleko_chleba
    WHERE p_year IN (2006, 2018)
    GROUP BY p_year, food_category
)
SELECT 
    af.p_year,
    af.food_category,
    af.avg_food_price,
    aw.avg_avg_wage,
    ROUND(aw.avg_avg_wage / af.avg_food_price) AS food_amount_avg_wage
FROM avg_food_price_per_year af
JOIN avg_wage_per_year aw 
    ON af.p_year = aw.p_year
ORDER BY
    af.p_year ASC,
    af.food_category ASC;

SELECT *
FROM avg_chleba_mleko_wage;



CREATE OR REPLACE VIEW category_trend AS
SELECT 
    p_year,
    food_category,
    avg_food_price,
    ROUND(
        (
            (avg_food_price - LAG(avg_food_price) OVER (PARTITION BY food_category ORDER BY p_year))
            /
            LAG(avg_food_price) OVER (PARTITION BY food_category ORDER BY p_year)
        ) * 100,
        2
    ) AS price_change_percent
FROM t_marie_kleknerova_project_SQL_primary_final
GROUP BY 
    p_year,
    food_category,
    avg_food_price;

SELECT *
FROM category_trend;

SELECT 
    food_category,
    ROUND(AVG(price_change_percent), 2) AS avg_price_growth_percent
FROM category_trend
WHERE price_change_percent IS NOT NULL
GROUP BY food_category
ORDER BY avg_price_growth_percent ASC
LIMIT 10;


CREATE OR REPLACE VIEW view_avg_wage_by_year AS
WITH unique_wages AS (
    SELECT DISTINCT
        p_year,
        industry,
        avg_wage
    FROM t_marie_kleknerova_project_SQL_primary_final
)
SELECT
    p_year,
    ROUND(AVG(avg_wage), 2) AS avg_avg_wage
FROM unique_wages
GROUP BY p_year;



CREATE OR REPLACE VIEW view_avg_food_price_by_year AS
WITH unique_food_price AS(
SELECT DISTINCT
    p_year,
    avg_food_price
FROM t_marie_kleknerova_project_SQL_primary_final
)
SELECT p_year,
    ROUND(AVG(avg_food_price), 2) AS agv_avg_food_price
FROM unique_food_price 
GROUP BY p_year;



CREATE OR REPLACE VIEW view_avg_wage_by_year AS
WITH unique_wages AS (
    SELECT DISTINCT
        p_year,
        industry,
        avg_wage
    FROM t_marie_kleknerova_project_SQL_primary_final
)
SELECT
    p_year,
    ROUND(AVG(avg_wage), 2) AS avg_avg_wage
FROM unique_wages
GROUP BY p_year;

SELECT *
FROM view_avg_wage_by_year;


CREATE OR REPLACE VIEW view_avg_food_price_by_year AS
SELECT
    p_year,
    ROUND(AVG(avg_food_price), 2) AS agv_avg_food_price
FROM t_marie_kleknerova_project_SQL_primary_final
GROUP BY p_year;


CREATE OR REPLACE VIEW comparison_avg_price_avg_wage AS
SELECT 
    p_year,
    agv_avg_food_price AS avg_food_price, 
    avg_avg_wage,
    prev_food_price,
    prev_wage,
    food_price_growth_percent,
    wage_growth_percent
FROM (
    SELECT 
        f.p_year,
        f.agv_avg_food_price,
        w.avg_avg_wage,
        LAG(f.agv_avg_food_price) OVER (ORDER BY f.p_year) AS prev_food_price,
        LAG(w.avg_avg_wage) OVER (ORDER BY w.p_year) AS prev_wage,
        ROUND((
            (f.agv_avg_food_price - LAG(f.agv_avg_food_price) OVER (ORDER BY f.p_year)) /
            NULLIF(LAG(f.agv_avg_food_price) OVER (ORDER BY f.p_year), 0)
        ) * 100, 2) AS food_price_growth_percent,
        ROUND((
            (w.avg_avg_wage - LAG(w.avg_avg_wage) OVER (ORDER BY w.p_year)) /
            NULLIF(LAG(w.avg_avg_wage) OVER (ORDER BY w.p_year), 0)
        ) * 100, 2) AS wage_growth_percent
    FROM view_avg_food_price_by_year f
    JOIN view_avg_wage_by_year w 
    	ON f.p_year = w.p_year
) AS growth_data
WHERE wage_growth_percent IS NOT NULL
  AND food_price_growth_percent IS NOT NULL;


SELECT p_year,
		food_price_growth_percent,
		wage_growth_percent,
		(food_price_growth_percent -  wage_growth_percent) AS different_price_wage
FROM comparison_avg_price_avg_wage
GROUP BY p_year,
		food_price_growth_percent,
		wage_growth_percent 
ORDER BY different_price_wage DESC
LIMIT 10;



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


CREATE OR REPLACE VIEW yearly_avg_gdp AS
SELECT 
    sf.e_year,
    ROUND(AVG(sf.gdp)) AS avg_gdp,
    LAG(ROUND(AVG(sf.gdp))) OVER(ORDER BY sf.e_year) AS previous_avg_gdp,
    ROUND(AVG(sf.gdp) - LAG(AVG(sf.gdp)) OVER(ORDER BY sf.e_year)) AS difference_avg_gdp,
    ROUND(
        (AVG(sf.gdp) - LAG(AVG(sf.gdp)) OVER(ORDER BY sf.e_year))::numeric 
        / NULLIF(LAG(AVG(sf.gdp)) OVER(ORDER BY sf.e_year), 0)::numeric * 100, 
        2
    ) AS percentage_difference_gdp,
      CASE 
        WHEN ROUND(AVG(sf.gdp)) > LAG(ROUND(AVG(sf.gdp))) OVER (ORDER BY e_year) THEN 'vzrostly'
        WHEN ROUND(AVG(sf.gdp)) < LAG(ROUND(AVG(sf.gdp))) OVER (ORDER BY e_year) THEN 'klesly'
        ELSE 'stejné'
    END AS yearly_avg_gdp_trend
FROM t_Marie_Kleknerova_project_SQL_secondary_final sf
GROUP BY sf.e_year
ORDER BY sf.e_year;

SELECT *
FROM yearly_avg_gdp;


CREATE OR REPLACE VIEW yearly_avg_wage_trend AS
SELECT 
    p_year,
    ROUND(AVG(avg_wage)) AS avg_avg_wage,
    LAG(ROUND(AVG(avg_wage))) OVER (ORDER BY p_year) AS previous_avg,
    ROUND(
        (ROUND(AVG(avg_wage)) - LAG(ROUND(AVG(avg_wage))) OVER (ORDER BY p_year)) 
        / NULLIF(LAG(ROUND(AVG(avg_wage))) OVER (ORDER BY p_year)::numeric, 0) * 100, 
        1
    ) AS percentage_difference_wage,
    CASE 
        WHEN ROUND(AVG(avg_wage)) > LAG(ROUND(AVG(avg_wage))) OVER (ORDER BY p_year) THEN 'vzrostly'
        WHEN ROUND(AVG(avg_wage)) < LAG(ROUND(AVG(avg_wage))) OVER (ORDER BY p_year) THEN 'klesly'
        ELSE 'stejné'
    END AS wage_trend
FROM
    t_marie_kleknerova_project_SQL_primary_final
GROUP BY
    p_year
ORDER BY
    p_year ASC;


SELECT *
FROM yearly_avg_wage_trend;


CREATE OR REPLACE VIEW yearly_avg_food_price_trend AS
SELECT 
    p_year,
    ROUND(AVG(avg_food_price)) AS avg_avg_food_price,
    LAG(ROUND(AVG(avg_food_price))) OVER (ORDER BY p_year) AS previous_avg_avg_food_price,
    ROUND(
        (ROUND(AVG(avg_food_price)) - LAG(ROUND(AVG(avg_food_price))) OVER (ORDER BY p_year)) 
        / NULLIF(LAG(ROUND(AVG(avg_food_price))) OVER (ORDER BY p_year)::numeric, 0) * 100, 
        1
    ) AS percentage_difference_food_price,
    CASE 
        WHEN ROUND(AVG(avg_food_price)) > LAG(ROUND(AVG(avg_food_price))) OVER (ORDER BY p_year) THEN 'vzrostly'
        WHEN ROUND(AVG(avg_food_price)) < LAG(ROUND(AVG(avg_food_price))) OVER (ORDER BY p_year) THEN 'klesly'
        ELSE 'stejné'
    END AS food_price_trend
FROM t_marie_kleknerova_project_SQL_primary_final
GROUP BY p_year
ORDER BY p_year ASC;
SELECT *
FROM yearly_avg_food_price_trend;

 
CREATE OR REPLACE VIEW yearly_combined_gdp_wage_price AS
SELECT 
      yag.e_year,
    yag.avg_gdp,
    yag.previous_avg_gdp,
    yag.difference_avg_gdp,
    yag.percentage_difference_gdp,
    yag.yearly_avg_gdp_trend,
    yaw.avg_avg_wage,
    yaw.previous_avg,
    yaw.percentage_difference_wage,
    yaw.wage_trend,
    yaf.avg_avg_food_price,
    yaf.previous_avg_avg_food_price,
    yaf.percentage_difference_food_price,
    yaf.food_price_trend
FROM yearly_avg_gdp yag
JOIN yearly_avg_wage_trend yaw 
    ON yag.e_year = yaw.p_year
JOIN yearly_avg_food_price_trend yaf 
    ON yag.e_year = yaf.p_year
ORDER BY yag.e_year;


SELECT 
    e_year,
    percentage_difference_gdp,
    yearly_avg_gdp_trend,
    percentage_difference_wage,
    wage_trend,
    percentage_difference_food_price,
    food_price_trend
FROM yearly_combined_gdp_wage_price
WHERE percentage_difference_gdp IS NOT NULL
ORDER BY e_year ASC;

