DROP VIEW view_avg_wage_by_year CASCADE;
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



DROP VIEW view_avg_food_price_by_year cascade;

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



DROP VIEW comparison_avg_price_avg_wage;

DROP VIEW IF EXISTS view_avg_wage_by_year CASCADE;
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

DROP VIEW IF EXISTS view_avg_food_price_by_year CASCADE;
CREATE OR REPLACE VIEW view_avg_food_price_by_year AS
SELECT
    p_year,
    ROUND(AVG(avg_food_price), 2) AS agv_avg_food_price
FROM t_marie_kleknerova_project_SQL_primary_final
GROUP BY p_year;

DROP VIEW IF EXISTS comparison_avg_price_avg_wage CASCADE;
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
