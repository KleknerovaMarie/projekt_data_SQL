DROP VIEW category_trend;
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
