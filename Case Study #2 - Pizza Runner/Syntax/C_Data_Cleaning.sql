-----------------------------------------------
-- C. DATA CLEANING: INGREDIENT OPTIMISATION --
-----------------------------------------------

-- 1. Create a new temporary table to separate [toppings] into multiple rows: toppings_break
CREATE TEMPORARY TABLE toppings_break AS
SELECT 
  pr.pizza_id,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pr.toppings, ',', n.n), ',', -1)) AS topping_id,
  pt.topping_name
FROM pizza_recipes pr
  CROSS JOIN (
    SELECT 1 AS n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
  ) AS n
  JOIN pizza_toppings pt
    ON TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pr.toppings, ',', n.n), ',', -1)) = pt.topping_id
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pr.toppings, ',', n.n), ',', -1)) != '';

SELECT 
    *
FROM
    toppings_break;
    
    
-- 2. Add a new column [record_id] to select each ordered pizza more easily
ALTER TABLE customer_orders_temp
ADD record_id INT AUTO_INCREMENT,
ADD PRIMARY KEY (record_id);

SELECT 
    *
FROM
    customer_orders_temp;


-- 3. Create a new temporary table to separate [extras] into multiple rows: #extrasBreak
CREATE TEMPORARY TABLE extrasBreak AS
SELECT 
  c.record_id,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', n.n), ',', -1)) AS extra_id
FROM customer_orders_temp c
  JOIN (
    SELECT 1 AS n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
  ) AS n
  ON LENGTH(c.extras) - LENGTH(REPLACE(c.extras, ',', '')) >= n.n - 1
WHERE c.extras IS NOT NULL AND TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', n.n), ',', -1)) != '';

SELECT 
    *
FROM
    extrasBreak;


-- 4. Create a new temporary table to separate [exclusions] into multiple rows: #exclusionsBreak 
CREATE TEMPORARY TABLE exclusionsBreak AS
SELECT 
  c.record_id,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', n.n), ',', -1)) AS exclusion_id
FROM customer_orders_temp c
  JOIN (
    SELECT 1 AS n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
  ) AS n
  ON LENGTH(c.exclusions) - LENGTH(REPLACE(c.exclusions, ',', '')) >= n.n - 1
WHERE c.exclusions IS NOT NULL AND TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', n.n), ',', -1)) != '';
 
SELECT 
    *
FROM
    exclusionsBreak;