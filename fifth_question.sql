DROP VIEW yearly_avg_gdp cascade;
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

DROP VIEW yearly_avg_wage_trend;
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

DROP VIEW yearly_avg_food_price_trend CASCADE;
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

DROP VIEW yearly_combined_gdp_wage_price; 
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