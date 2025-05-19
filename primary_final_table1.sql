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



