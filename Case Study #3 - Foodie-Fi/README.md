# 🥑 Case Study #3 - Foodie-Fi
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" width="500" height="520" alt="image">

  
## 📕 Table of Contents
* [Bussiness Task](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/README.md#%EF%B8%8F-bussiness-task)
* [Entity Relationship Diagram](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/README.md#-entity-relationship-diagram)
* [Case Study Questions](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/README.md#-case-study-questions)
* [My Solution](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/README.md#-my-solution)

---
## 🛠️ Bussiness Task
Danny and his friends launched a new startup called "Food-Fi" in 2020 and started selling monthly and annual subscriptions, 
  giving their customers unlimited on-demand access to exclusive food videos from around the world. 
  
  This case study focuses 
  on using subscription style digital data to answer some important questions such as business performance, payments, and customer journey.

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-3-erd.png">

---
## ❓ Case Study Questions
### A. Customer Journey
View my solution [HERE](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/A.%20Customer%20Journey.md).
* Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

---
### B. Data Analysis Questions
View my solution [HERE](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/B.%20Data%20Analysis%20Questions.md).

1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

---
### C. Challenge Payment Question
View my solution [HERE](https://github.com/PurushothamAbbili/8WeekSQLChallenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/C.%20Challenge%20Payment%20Question.md).

The Foodie-Fi team wants to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
  * monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
  * upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
  * upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
  * once a customer churns they will no longer make payments

---
## 🚀 My Solution
* View the complete syntax [HERE](https://github.com/PurushothamAbbili/8WeekSQLChallenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/Syntax).
* View the result and explanation [HERE](https://github.com/PurushothamAbbili/8WeekSQLChallenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution).
