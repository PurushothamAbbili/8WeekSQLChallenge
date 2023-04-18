-- B. RUNNER AND CUSTOMER EXPERIENCE --

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    WEEK(registration_date) AS week,
    COUNT(runner_id) AS no_of_signups
FROM
    runners
GROUP BY WEEK(registration_date);


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH runners_pickup AS (
  SELECT
    r.runner_id,
    c.order_id, 
    c.order_time, 
    r.pickup_time, 
    TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
  FROM customer_orders_temp c
  JOIN runner_orders_temp r
    ON c.order_id = r.order_id
  WHERE r.cancellation IS NULL
  GROUP BY r.runner_id, c.order_id, c.order_time, r.pickup_time
)

SELECT 
  runner_id,
  CEIL(AVG(pickup_minutes)) AS average_time_in_minutes
FROM runners_pickup
GROUP BY runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizza_prepration AS (
  SELECT
    c.order_id, 
    c.order_time, 
    r.pickup_time,
    TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time,
    COUNT(c.pizza_id) AS pizza_count
  FROM customer_orders_temp c
  JOIN runner_orders_temp r
    ON c.order_id = r.order_id
  WHERE r.cancellation IS NULL
  GROUP BY c.order_id, c.order_time, r.pickup_time, 
           TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)
)

SELECT 
  pizza_count,
  AVG(prep_time) AS avg_prep_time
FROM pizza_prepration
GROUP BY pizza_count;


-- 4. What was the average distance travelled for each customer?
SELECT 
    c.customer_id, ROUND(AVG(r.distance), 1) AS average_distance
FROM
    runner_orders_temp r
        JOIN
    customer_orders_temp c ON r.order_id = c.order_id
WHERE
    r.cancellation IS NULL
GROUP BY c.customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
    MAX(duration) - MIN(duration) AS difference
FROM
    runner_orders_temp;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    r.runner_id,
    c.order_id,
    r.distance,
    r.duration,
    COUNT(c.order_id) AS pizza_count,
    ROUND(60 * AVG(r.distance / r.duration), 1) AS avg_speed
FROM
    runner_orders_temp r
        JOIN
    customer_orders_temp c ON r.order_id = c.order_id
WHERE
    cancellation IS NULL
GROUP BY r.runner_id , c.order_id , r.distance , r.duration
ORDER BY r.runner_id;


-- 7. What is the successful delivery percentage for each runner?
SELECT 
    runner_id,
    COUNT(distance) AS delivered,
    COUNT(order_id) AS total,
    ROUND(100 * COUNT(distance) / COUNT(order_id),
            2) AS successful_delivery_percentage
FROM
    runner_orders_temp
GROUP BY runner_id;