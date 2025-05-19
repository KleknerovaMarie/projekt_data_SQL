DROP VIEW mleko_chleba;
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