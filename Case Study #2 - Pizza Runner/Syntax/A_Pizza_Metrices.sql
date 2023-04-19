-----------------------
-- A. PIZZA METRICES -- 
-----------------------


-- 1. How many pizzas were ordered?
SELECT 
    COUNT(order_id) AS no_of_orders
FROM
    customer_orders_temp;


-- 2. How many unique customer orders were made?
SELECT 
    COUNT(DISTINCT order_id) AS unique_orders
FROM
    customer_orders_temp;


-- 3. How many successful orders were delivered by each runner?
SELECT 
    runner_id, COUNT(order_id) AS no_of_orders_delivered
FROM
    runner_orders_temp
WHERE
    cancellation IS NULL
GROUP BY runner_id;


-- 4. How many of each type of pizza was delivered?
-- Method I (Using JOIN)
SELECT 
    p.pizza_name, COUNT(*) AS delivery_count
FROM
    pizza_names p
        JOIN
    customer_orders_temp c ON p.pizza_id = c.pizza_id
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY p.pizza_name;

-- Menthod II (Using Subquery)
SELECT 
    p.pizza_name, COUNT(*) AS delivery_count
FROM
    customer_orders_temp c
        JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
WHERE
    c.order_id IN (SELECT 
            r.order_id
        FROM
            runner_orders_temp r
        WHERE
            r.cancellation IS NULL)
GROUP BY p.pizza_name;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer? 
-- Method I 
SELECT 
    customer_id,
    SUM(CASE
        WHEN pizza_id = 1 THEN 1
        ELSE 0
    END) AS `Meatlovers`,
    SUM(CASE
        WHEN pizza_id = 2 THEN 1
        ELSE 0
    END) AS Vegetarian
FROM
    customer_orders_temp
GROUP BY customer_id;

-- Method II
SELECT 
    c.customer_id,
    p.pizza_name,
    COUNT(c.order_id) AS no_of_orders
FROM
    customer_orders_temp c
        JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id , p.pizza_name
ORDER BY c.customer_id , p.pizza_name;


-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
    MAX(pizza_count) AS max_pizza_deliveries_per_order
FROM
    (SELECT 
        c.order_id, COUNT(c.pizza_id) AS pizza_count
    FROM
        customer_orders_temp c
    JOIN runner_orders_temp r ON c.order_id = r.order_id
    WHERE
        r.cancellation IS NULL
    GROUP BY c.order_id) temp;
    

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    c.customer_id,
    SUM(CASE
        WHEN exclusions != '' OR extras != '' THEN 1
        ELSE 0
    END) AS has_change,
    SUM(CASE
        WHEN exclusions = '' AND extras = '' THEN 1
        ELSE 0
    END) AS no_change
FROM
    customer_orders_temp c
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY c.customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
    COUNT(c.pizza_id) AS total
FROM
    customer_orders_temp c
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
        AND c.exclusions <> ''
        AND c.extras <> '';


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    HOUR(order_time) AS hour_of_the_day,
    COUNT(order_id) AS total_pizza_volume
FROM
    customer_orders_temp
GROUP BY HOUR(order_time)
ORDER BY hour_of_the_day;


-- 10. What was the volume of orders for each day of the week?
SELECT 
    DAYNAME(order_time) AS day_of_the_week,
    COUNT(order_id) AS total_order_volume
FROM
    customer_orders_temp
GROUP BY DAYNAME(order_time)
ORDER BY day_of_the_week;
