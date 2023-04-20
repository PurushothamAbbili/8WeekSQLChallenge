----------------------------------
-- Case Study #1: Danny's Diner --
----------------------------------

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    customer_id, 
    SUM(price) AS total_amount
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY customer_id;


-- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id,
    COUNT(DISTINCT (order_date)) AS no_of_days_visited
FROM
    sales
GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS(
SELECT 
    customer_id, product_name, order_date, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
)

SELECT 
    customer_id, product_name, order_date
FROM
    CTE
WHERE
    rnk = 1
GROUP BY customer_id , product_name , order_date;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    m.product_name, COUNT(s.product_id) AS no_of_times_purchased
FROM
    menu m
        RIGHT JOIN
    sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY no_of_times_purchased DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?
WITH fav_item AS(
SELECT
	s.customer_id, 
    m.product_name, COUNT(m.product_id) AS order_count,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rnk 
FROM sales s JOIN menu m ON s.product_id = m.product_id GROUP BY s.customer_id, 
    s.product_id, 
    m.product_name)
    
SELECT 
    customer_id, product_name, order_count
FROM
    fav_item
WHERE
    rnk = 1;
 
 
-- 6. Which item was purchased first by the customer after they became a member?
WITH member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rnk
   FROM sales s
   JOIN members m
      ON s.customer_id = m.customer_id
   WHERE s.order_date >= m.join_date
)

SELECT 
    s.customer_id, s.order_date, m2.product_name
FROM
    member_sales s
        JOIN
    menu m2 ON s.product_id = m2.product_id
WHERE
    rnk = 1;


-- 7. Which item was purchased just before the customer became a member?
WITH member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rnk
   FROM sales s
   JOIN members m
      ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT 
    s.customer_id, s.order_date, m2.product_name
FROM
    member_sales s
        JOIN
    menu m2 ON s.product_id = m2.product_id
WHERE
    rnk = 1;


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id,
    COUNT(DISTINCT s.product_id) AS total_items,
    SUM(m.price) AS amt_spent
FROM
    members mem
        JOIN
    sales s ON mem.customer_id = s.customer_id
        JOIN
    menu m ON s.product_id = m.product_id
WHERE
    s.order_date < mem.join_date
GROUP BY s.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
WITH price_points AS (
SELECT 
    *,
    CASE
        WHEN m.product_id = 1 THEN m.price * 20
        ELSE m.price * 10
    END AS points
    FROM menu m)
    
SELECT 
    s.customer_id, SUM(p.points) AS total_points
FROM
    price_points p
        JOIN
    sales s ON p.product_id = s.product_id
GROUP BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January?
WITH dates AS (
   SELECT *, 
      DATE_ADD(join_date, INTERVAL +6 DAY ) AS valid_date, 
      LAST_DAY('2021-01-31') AS last_date
   FROM members AS m
)

SELECT 
    d.customer_id,
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
        WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
        ELSE 10 * m.price
    END) AS points
FROM
    dates AS d
        JOIN
    sales AS s ON d.customer_id = s.customer_id
        JOIN
    menu AS m ON s.product_id = m.product_id
WHERE
    s.order_date < d.last_date
GROUP BY d.customer_id
ORDER BY points DESC;

-- BONUS QUESTIONS
-- 1. Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN mem.join_date <= s.order_date THEN 'Y'
        ELSE 'N'
    END AS `member(Y/N)`
FROM
    sales s
        LEFT JOIN
    menu m ON s.product_id = m.product_id
        LEFT JOIN
    members mem ON s.customer_id = mem.customer_id;


/* 2. Rank All The Things - Danny also requires further information about the ranking of customer products, 
   but he purposely does not need the ranking for non-member purchases.
   so, he expects null ranking values for the records when customers are not yet part of the loyalty program. */
WITH final_table AS (
SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN mem.join_date <= s.order_date THEN 'Y'
        ELSE 'N'
    END AS `member(Y/N)`
FROM
    sales s
        LEFT JOIN
    menu m ON s.product_id = m.product_id
        LEFT JOIN
    members mem ON s.customer_id = mem.customer_id
)
    
SELECT 
	*,
	CASE 
		WHEN `member(Y/N)` = 'N' THEN NULL 
        ELSE RANK() OVER(PARTITION BY customer_id, `member(Y/N)` ORDER BY order_date) END AS ranking 
FROM 
	final_table;
