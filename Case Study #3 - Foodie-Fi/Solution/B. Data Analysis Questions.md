# 🥑 Case Study #3 - Foodie-Fi
## B. Data Analysis Questions
### 1. How many customers has Foodie-Fi ever had?
```MySQL
SELECT 
    COUNT(DISTINCT customer_id) AS no_of_unique_customers
FROM
    subscriptions;
```
| no_of_unique_customers  |
|-------------------------|
| 1000                    |

---
### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
```MySQL
SELECT 
    MONTH(start_date) AS month, COUNT(*) AS distribution
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY MONTH(start_date);
```
| month | distribution         |
|--------|----------------------|
| 1      | 88                   |
| 2      | 68                   |
| 3      | 94                   |
| 4      | 81                   |
| 5      | 88                   |
| 6      | 79                   |
| 7      | 89                   |
| 8      | 88                   |
| 9      | 87                   |
| 10     | 79                   |
| 11     | 75                   |
| 12     | 84                   |

---
### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?
```MySQL
SELECT 
    YEAR(s.start_date) AS events,
    p.plan_name,
    COUNT(*) AS counts
FROM
    subscriptions s
        JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    YEAR(s.start_date) > 2020
GROUP BY YEAR(s.start_date) , p.plan_name
ORDER BY p.plan_name;
```
| events | plan_name     | counts  |
|--------|---------------|---------|
| 2021   | basic monthly | 8       |
| 2021   | churn         | 71      |
| 2021   | pro annual    | 63      |
| 2021   | pro monthly   | 60      |

---
### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```MySQL
SELECT 
	SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS churn_count, 
    CAST(100*SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS FLOAT) / COUNT(DISTINCT customer_id) AS churn_pct
FROM
	subscriptions s
		JOIN 
	plans p ON s.plan_id = p.plan_id;
```
| churn_count | churn_pct   |
|-------------|-------------|
| 307         | 30.7        |

---
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```MySQL
WITH nextPlan AS (
  SELECT 
	s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY p.plan_id) AS next_plan
  FROM 
	subscriptions s
		JOIN 
	plans p ON s.plan_id = p.plan_id
)

SELECT 
	COUNT(*) AS churn_after_trial,
	ROUND(100*COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) AS pct
FROM 
	nextPlan
WHERE plan_name = 'trial' 
  AND next_plan = 'churn';
```
| churn_after_trial | pct         |
|-------------------|-------------|
| 92                | 9           |

---
### 6. What is the number and percentage of customer plans after their initial free trial?
```MySQL
WITH nextPlan AS (
  SELECT 
    s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id 
			ORDER BY p.plan_id) AS next_plan
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
  next_plan,
  COUNT(*) AS customer_plan,
  CAST(100 * COUNT(*) AS FLOAT) 
      / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS percentage
FROM nextPlan
WHERE next_plan IS NOT NULL
  AND plan_name = 'trial'
GROUP BY next_plan;
```
| next_plan     | customer_plan | percentage  |
|---------------|---------------|-------------|
| basic monthly | 546           | 54.6        |
| churn         | 92            | 9.2         |
| pro annual    | 37            | 3.7         |
| pro monthly   | 325           | 32.5        |

---
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```MySQL
WITH plansDate AS (
  SELECT 
    s.customer_id,
    s.start_date,
	p.plan_id,
    p.plan_name,
    LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS next_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
  plan_id,
  plan_name,
  COUNT(*) AS customers,
  CAST(100*COUNT(*) AS FLOAT) 
      / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS conversion_rate
FROM plansDate
WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31'))
  OR (next_date IS NULL AND start_date < '2020-12-31')
GROUP BY plan_id, plan_name
ORDER BY plan_id;
```
| plan_id | plan_name     | customers | conversion_rate  |
|---------|---------------|-----------|------------------|
| 0       | trial         | 19        | 1.9              |
| 1       | basic monthly | 224       | 22.4             |
| 2       | pro monthly   | 326       | 32.6             |
| 3       | pro annual    | 195       | 19.5             |
| 4       | churn         | 235       | 23.5             |

---
### 8. How many customers have upgraded to an annual plan in 2020?
```MySQL
SELECT 
    COUNT(DISTINCT s.customer_id) AS upgraded_customers
FROM
    subscriptions s
        JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    YEAR(s.start_date) = 2020
        AND p.plan_name LIKE '%annual%';
```
| upgraded_customers |
|--------------------|
| 195                |

---
### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```MySQL
WITH trialPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS trial_date
  FROM 
	subscriptions s
		JOIN 
	plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'trial'
),

annualPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS annual_date
  FROM 
	subscriptions s
		JOIN 
	plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'pro annual'
)

SELECT 
  ROUND(AVG(CAST(TIMESTAMPDIFF(DAY, trial_date, annual_date) AS FLOAT))) AS avg_days_to_annual
FROM 
	trialPlan t
		JOIN 
	annualPlan a ON t.customer_id = a.customer_id;
```
| avg_days_to_annual  |
|---------------------|
| 105                 |

On average, it takes 105 days for a customer to an annual plan from the day they join Foodie-Fi.

---
### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 30-60 days etc)?
```MySQL
WITH trialPlan AS (
  SELECT 
	s.customer_id, 
	s.start_date AS trial_date
  FROM 
	subscriptions s
  WHERE plan_id = 0
),
annualPlan AS (
  SELECT 
    s.customer_id, 
    s.start_date AS annual_date
  FROM 
	subscriptions s
  WHERE plan_id = 3
),
bins AS (
  SELECT 
   FLOOR(TIMESTAMPDIFF(DAY, tp.trial_date, ap.annual_date) / 30) + 1 AS avg_months_to_upgrade
  FROM 
   trialPlan tp
	  JOIN annualPlan ap ON tp.customer_id = ap.customer_id
)
  
SELECT 
    CONCAT(((avg_months_to_upgrade - 1) * 30),
            ' - ',
            (avg_months_to_upgrade * 30),
            ' days') AS breakdown,
    COUNT(*) AS customer_count
FROM
    bins
GROUP BY avg_months_to_upgrade
ORDER BY avg_months_to_upgrade;
```
| breakdown    | customer_count  |
|--------------|-----------------|
| 0-30 days    | 48              |
| 30-60 days   | 25              |
| 60-90 days   | 33              |
| 90-120 days  | 35              |
| 120-150 days | 43              |
| 150-180 days | 35              |
| 180-210 days | 27              |
| 210-240 days | 4               |
| 240-270 days | 5               |
| 270-300 days | 1               |
| 301-330 days | 1               |
| 330-360 days | 1               |

---
### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```MySQL
WITH nextPlan AS (
  SELECT 
    s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY p.plan_id) AS next_plan
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
    COUNT(*) AS pro_to_basic_monthly
FROM
    nextPlan
WHERE
    plan_name = 'pro monthly'
        AND next_plan = 'basic monthly'
        AND YEAR(start_date) = 2020;
```
| pro_to_basic_monthly|
|---------------------|
| 0                   |

There were no customers downgrading from a pro monthly to a basic monthly plan in 2020.

---
My solution for **[C. Challenge Payment Question](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/C.%20Challenge%20Payment%20Question.md)**.
