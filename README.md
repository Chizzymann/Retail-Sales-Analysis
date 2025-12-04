# Retail Sales Analysis — SQL Project

### End-to-End Data Exploration & Business Insights Using SQL

This project analyzes retail sales performance, customer behavior, and product profitability by running SQL queries on a structured sales dataset.


## Project Overview

**Database:** `retail_sales_db_c1`  
**Language:** SQL (MySQL)

The dataset includes:
- Customer demographics (Age, Gender)
- Product categories
- Timestamped sales transactions
- Quantity, Cost & Revenue metrics

Purpose: Transform raw sales data into actionable analytics insights.


## Project Objectives

* Create and set up a retail sales database  
* Clean the dataset & remove missing values  
* Perform exploratory data analysis (EDA)  
* Conduct business-driven analysis using SQL  


### 1. Database Setup
* **Database Creation:** I created a database named `retail_sales_db_c1`.

* **Table Creation:** A table named `retail_sales` was created to store the data, including columns for `transaction id` (PK), `sales date`, `sale time`, `customer id`, `gender`, `age`, `category`, `quantity`, `price per unit`, `Cost of Goods Sold (COGS)`, and `total sale`.

```sql
CREATE DATABASE retail_sales_db_c1;
USE retail_sales_db_c1;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```


### 2. Data Exploration & Cleaning
* **Records Count:** Total records were counted to understand the database size.
* **Customers Count:** Checked the number of unique customers in the dataset.
* **Category Identification:** Identified all unique product categories.
* **Basic Summary Statistics:** Carried out basic `MIN`, `MAX`, `AVG` statistics to understand data ranges and distribution.
* **Null and Missing Data Check:** Checked for any null values and deleted records with missing data.

```sql
# Display all records from the table (After importing from the excel dataset) 
select * from retail_sales;

# Count the number of Records 
select COUNT(*) AS No_of_Records from retail_sales;

# Cout the number of unique Customers
select count(distinct customer_id) as "Customer Count" from retail_sales;

# Count the number of unique products categories
select count(distinct category) as "Product Category Count" from retail_sales;

# Display the unique products categories
select distinct category from retail_sales;

# Check the minimuma and maximum age for the different genders
select gender, min(age), max(age) from retail_sales group by gender;

# Check the average age of all customers
select round(avg(age)) from retail_sales;

# Check the average age of all the different genders
select gender, round(avg(age)) from retail_sales group by gender;

# Check for Null Values
select * from retail_sales where 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
    
# Delete Null Values
delete from retail_sales where 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```


### 3. Key Data Analysis Questions (SQL Queries)

A robust set of SQL queries was developed to extract the following insights:

#### A. Total revenue generated in 2022 for each category in descending order.
```sql
SELECT
  category,
  SUM(total_sale)
FROM retail_sales
WHERE sale_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY category
ORDER BY SUM(total_sale) DESC;
```
#### B. Transactions where the customer is **above 40 years old** and purchased items from the **'Electronics'** category between March and June 2023.
```sql
SELECT * FROM retail_sales
WHERE category = 'Electronics'
  AND age > 40
  AND sale_date BETWEEN '2023-03-01' AND '2023-06-30';
```
#### C. Total profit per category, displaying only categories with profit **above $50,000**.
```sql
SELECT
  category,
  ROUND(SUM(profit), 2) AS profit_made
FROM retail_sales
GROUP BY category
HAVING profit_made > 50000
ORDER BY profit_made DESC;
```
#### D. Top 3 highest-selling days (based on total sale) in each month.
```sql
SELECT *
FROM (
    SELECT sale_date,
           SUM(total_sale) AS daily_total,
           RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
                        ORDER BY SUM(total_sale) DESC) AS ranking
    FROM retail_sales
    GROUP BY sale_date
) AS t
WHERE ranking <= 3;
```
#### E. Customers with **more than 5 purchases** in a single month.
```sql
SELECT customer_id,
       EXTRACT(YEAR FROM sale_date) AS year,
       EXTRACT(MONTH FROM sale_date) AS month_number,
       COUNT(*) AS num_transactions
FROM retail_sales
GROUP BY customer_id, year, month_number
HAVING num_transactions > 5
ORDER BY customer_id;
```
#### F. Average price per unit for each category.
```sql
SELECT category,
       ROUND(AVG(price_per_unit), 0) AS average_price
FROM retail_sales
GROUP BY category
ORDER BY average_price DESC;
```
#### G. Transactions with **Quantity > 3 on weekends**.
```sql
SELECT * FROM retail_sales
WHERE quantity > 3
  AND DAYOFWEEK(sale_date) IN (1, 7);
```
#### H. Customers who purchased from at least **3 different categories**.
```sql
SELECT customer_id,
       COUNT(DISTINCT category) AS purchased_categories
FROM retail_sales
GROUP BY customer_id
HAVING purchased_categories >= 3;
```
#### I. Most popular age group by number of transactions.
```sql
SELECT CASE
         WHEN age BETWEEN 18 AND 25 THEN '18-25'
         WHEN age BETWEEN 26 AND 35 THEN '26-35'
         WHEN age BETWEEN 36 AND 45 THEN '36-45'
         WHEN age BETWEEN 46 AND 60 THEN '46-60'
         ELSE '60+'
       END AS age_group,
       COUNT(*) AS num_transactions
FROM retail_sales
GROUP BY age_group
ORDER BY num_transactions DESC
LIMIT 1;
```
#### J. Top Selling Category in each Gender.
```sql
SELECT *
FROM (
    SELECT category,
           gender,
           SUM(total_sale),
           RANK() OVER (PARTITION BY gender ORDER BY SUM(total_sale) DESC) AS ranking
    FROM retail_sales
    GROUP BY gender, category
) AS top_category
WHERE ranking = 1;
```
#### K. Total revenue per shift (**Morning, Afternoon, Evening**) and rank.
```sql
WITH hourly_sale AS (
    SELECT *,
           CASE
             WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
             WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
           END AS shift
    FROM retail_sales
)
SELECT shift,
       SUM(total_sale) AS total_revenue,
       RANK() OVER (ORDER BY SUM(total_sale) DESC) AS ranking
FROM hourly_sale
GROUP BY shift;
```


## Findings

Based on the detailed SQL analysis, the following key patterns and results were identified:

* The dataset shows strong activity among customers aged **46–60**, making them the **most active buyers** by transaction count.
* **Evening shift** generates the **highest total sales**, while Afternoon records the lowest, indicating stronger **night-time engagement**.
* Top-selling product categories **differ significantly by gender**, highlighting opportunities for targeted marketing.
* Weekends show increased bulk purchases (quantities > 3), with **Sundays** being particularly strong for these larger transactions.
* Several customers consistently buy from **multiple categories**, showing strong cross-category interest.
* **High-value transactions above $1,000** occur frequently in premium categories.
* All categories demonstrated a high value, with an **average price per unit > $150**, confirming high revenue generation potential across the product line.


## Report Summary

* The dataset was thoroughly cleaned: **NULL values were removed**, and all fields were validated.
* Advanced **SQL queries** were used to analyze customer demographics, sales patterns, category performance, and profit trends.
* **Window functions (RANK, PARTITION)**, **CTEs**, and **date/time functions** were strategically applied to reveal deep patterns across shifts, days, and months.
* Sales behavior was segmented by gender, age, category, and timeframe for clearer business insights.
* Monthly top-performing days were identified, along with high-revenue categories and customers with repeat purchases.
* Overall, the analysis provides a **structured view of revenue distribution, customer habits, and operational performance.**


## Conclusion

Customer behavior and category performance show clear, actionable patterns that can guide revenue strategies and targeted marketing:

* **Evening** remains the **most profitable shift**, suggesting operational focus and marketing spend should prioritize night-time hours.
* Marketing efforts should be specifically directed toward the **46–60 age group** and promote **bulk deals (Quantity > 3)**, especially on Sundays.
* **Cross-category shoppers** offer strong opportunities for upselling and personalized promotions to increase Customer Lifetime Value (CLV).
* The SQL analysis successfully establishes a **strong baseline** for building dynamic dashboards, running predictive models, and optimizing overall retail operations.


## How to Use This Project
### Requirements

* MySQL or MariaDB database

* SQL client tool (MySQL Workbench, DBeaver, pgAdmin, etc.)

### Setup Instructions

1. Clone or download this repository
2. Execute the database setup SQL script
3. Import the retail dataset into the retail_sales table
4. Run the analysis queries for insights
