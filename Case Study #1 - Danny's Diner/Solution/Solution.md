# 🍜 Case Study #1: Danny's Diner

## Solution

View the complete syntax [here](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Syntax/Danny's%20Diner.sql).

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT 
    customer_id, 
    SUM(price) AS total_amount
FROM
    sales
        JOIN
    menu ON sales.product_id = menu.product_id
GROUP BY customer_id; 
````

#### Steps:
- Use **SUM** and **GROUP BY** to find out ```total_sales``` contributed by each customer.
- Use **JOIN** to merge ```sales``` and ```menu``` tables as ```customer_id``` and ```price``` are from both tables. 

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT 
    customer_id,
    COUNT(DISTINCT (order_date)) AS no_of_days_visited
FROM
    sales
GROUP BY customer_id;
````

#### Steps:
- Used **DISTINCT** with **COUNT** to find out the ```no_of_days_visited``` by each customer.
- If we do not use **DISTINCT** on ```order_date```, the number of days may be repeated. For example, if Customer A visited the restaurant twice on '2021–01–07', then number of days is counted as 2 days instead of 1 day.

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH order_sales AS (
   SELECT 
       customer_id, 
       product_name, 
       order_date,
       DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
   FROM
       sales s
           JOIN
       menu m ON s.product_id = m.product_id
)

SELECT 
    customer_id,
    product_name,
    order_date
FROM
    order_sales
WHERE
    rnk = 1
GROUP BY customer_id , product_name , order_date;
````

#### Steps:
- Create a temp table ```order_sales``` and use **Windows function** with **DENSE_RANK** to create a new column ```rank``` based on ```order_date```.
- Instead of **ROW_NUMBER** or **RANK**, use **DENSE_RANK** as ```order_date``` is not time-stamped hence, there is no sequence as to which item is ordered first if 2 or more items are ordered on the same day.
- Subsequently, **GROUP BY** all columns to show ```rnk = 1``` only.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT 
    m.product_name,
    COUNT(s.product_id) AS no_of_times_purchased
FROM
    menu m
        RIGHT JOIN
    sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY no_of_times_purchased DESC
LIMIT 1;
````

#### Steps:
- **COUNT** number of ```product_id``` and **ORDER BY** ```no_of_times_purchased``` by descending order. 
- Then, use **LIMIT 1** to filter highest number of purchased item.

#### Answer:
| most_purchased | product_name | 
| -------------- | ------------ |
| 8              | ramen        |


- Most purchased item on the menu is ramen which is 8 times. 

***

### 5. Which item was the most popular for each customer?

````sql
WITH fav_item AS (
   SELECT
      s.customer_id, 
      m.product_name,
      COUNT(m.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rnk 
   FROM
      sales s
         JOIN 
      menu m ON s.product_id = m.product_id
   GROUP BY s.customer_id, s.product_id, m.product_name
)    

SELECT 
    customer_id,
    product_name,
    order_count
FROM
    fav_item
WHERE
    rnk = 1;
````

#### Steps:
- Create a ```fav_item``` and use **DENSE_RANK** to ```rank``` the ```order_count``` for each product by descending order for each customer.
- Generate results where product ```rnk = 1``` only as the most popular product for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ------------ |------------ |
| A           | ramen        |  3          |
| B           | sushi        |  2          |
| B           | curry        |  2          |
| B           | ramen        |  2          |
| C           | ramen        |  3          |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu.

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH member_sales AS (
   SELECT
      s.customer_id,
      m.join_date,
      s.order_date,
      s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
   FROM 
      sales s
         JOIN 
      members m ON s.customer_id = m.customer_id
   WHERE s.order_date >= m.join_date
)

SELECT 
    s.customer_id,
    s.order_date,
    m2.product_name
FROM
    member_sales s
        JOIN
    menu m2 ON s.product_id = m2.product_id
WHERE
    rnk = 1;
````

#### Steps:
- Create ```member_sales``` by using **windows function** and partitioning ```customer_id``` by ascending ```order_date```. Then, filter ```order_date``` to be on or after ```join_date```.
- Then, filter table by ```rnk = 1``` to show 1st item purchased by each customer.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ----------- |------------  |
| A           | 2021-01-07  | curry        |
| B           | 2021-01-11  | sushi        |

- Customer A's first order as member is curry.
- Customer B's first order as member is sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH member_sales AS (
   SELECT 
      s.customer_id,
      m.join_date,
      s.order_date,
      s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
   FROM 
      sales s
         JOIN 
      members m ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT 
    s.customer_id,
    s.order_date,
    m2.product_name
FROM
    member_sales s
        JOIN
    menu m2 ON s.product_id = m2.product_id
WHERE
    rnk = 1;
````

#### Steps:
- Create a ```member_sales``` to create new column ```rnk``` by using **Windows function** and partitioning ```customer_id``` by descending ```order_date``` to find out the last ```order_date``` before customer becomes a member.
- Filter ```order_date``` before ```join_date```.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A’s last order before becoming a member is sushi and curry.
- Whereas for Customer B, it's sushi. That must have been a real good sushi!

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
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
````

#### Steps:
- Filter ```order_date``` before ```join_date``` and perform a **COUNT** **DISTINCT** on ```product_id``` and **SUM** the ```total spent``` before becoming member.

#### Answer:
| customer_id | unique_menu_item | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |

Before becoming members,
- Customer A spent $ 25 on 2 items.
- Customer B spent $40 on 2 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
WITH price_points AS (
	SELECT 
		*,
		CASE
			WHEN m.product_id = 1 THEN m.price * 20
			ELSE m.price * 10
		END AS points
	FROM 
      menu m
)
    
SELECT 
    s.customer_id,
    SUM(p.points) AS total_points
FROM
    price_points p
        JOIN
    sales s ON p.product_id = s.product_id
GROUP BY s.customer_id;
````

#### Steps:
Let’s breakdown the question.
- Each $1 spent = 10 points.
- But, sushi (product_id 1) gets 2x points, meaning each $1 spent = 20 points
So, we use CASE WHEN to create conditional statements
- If product_id = 1, then every $1 price multiply by 20 points
- All other product_id that is not 1, multiply $1 by 10 points
Using ```price_points```, **SUM** the ```points```.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is 860.
- Total points for Customer B is 940.
- Total points for Customer C is 360.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
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
````

#### Steps:
- In ```dates```, find out customer’s ```valid_date``` (which is 6 days after ```join_date``` and inclusive of ```join_date```) and ```last_day``` of Jan 2021 (which is ‘2021–01–31’).

Our assumptions are:
- On Day -X to Day 1 (customer becomes member on Day 1 ```join_date```), each $1 spent is 10 points and for sushi, each $1 spent is 20 points.
- On Day 1 ```join_date``` to Day 7 ```valid_date```, each $1 spent for all items is 20 points.
- On Day 8 to ```last_day``` of Jan 2021, each $1 spent is 10 points and sushi is 2x points.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.

***

## BONUS QUESTIONS

### Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

````sql
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
 ````
 
#### Answer: 
| customer_id | order_date | product_name | price | member(Y/N) |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things - Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

````sql
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
````

#### Answer: 
| customer_id | order_date | product_name | price | member(Y/N) | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL


***
