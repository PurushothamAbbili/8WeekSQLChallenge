-----------------------------------
-- C. Challenge Payment Question --
-----------------------------------

WITH RECURSIVE dateRecursion AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date,
    -- last_date: last day of the current plan
    CASE 
      -- if a customer kept using the current plan, last_date = '2020-12-31'
      WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
      -- if a customer changed the plan, last_date = (month difference between start_date and changing date) + start_date
      ELSE DATE_ADD(start_date, INTERVAL 
		   TIMESTAMPDIFF(MONTH, start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date))
           MONTH) END AS last_date,
    p.price AS amount
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  -- exclude trials because they didn't generate payments 
  WHERE p.plan_name NOT IN ('trial')
    AND YEAR(start_date) = 2020

  UNION ALL

  SELECT 
    customer_id,
    plan_id,
    plan_name,
    -- increment payment_date by monthly
    DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
    last_date,
    amount
  FROM dateRecursion
  -- stop incrementing when payment_date = last_date
  WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) <= last_date
    AND plan_name != 'pro annual'
)

SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  amount,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM dateRecursion
-- exclude churns
WHERE amount IS NOT NULL
ORDER BY customer_id;

