# Create Database
CREATE database retail_sales_db_c1;

# Call Database for use
use retail_sales_db_c1;

#Create table with columns
create table retail_sales
(
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

# Display all records from the table (After importing from the excel dataset) 
select * 
from retail_sales;

# Count the number of Records 
select COUNT(*) AS No_of_Records 
from retail_sales;

# Cout the number of unique Customers
select count(distinct customer_id) as "Customer Count" 
from retail_sales;

# Count the number of unique products categories
select count(distinct category) as "Product Category Count" 
from retail_sales;

# Display the unique products categories
select distinct category 
from retail_sales;

# Check the minimuma and maximum age for the different genders
select 
	gender, 
	min(age), 
	max(age) 
from retail_sales 
group by gender;

# Check the average age of all customers
select round(avg(age)) 
from retail_sales;

# Check the average age of all the different genders
select 
	gender, 
	round(avg(age)) 
from retail_sales group by gender;

# Check for Null Values
select * 
from retail_sales 
where 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
    
# Delete Null Values
delete from retail_sales 
where 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
    
# Add Profit column per treansaction
alter table retail_sales
add column Profit float as (total_sale - cogs) stored;

# TOTAL REVENUE GENERATED IN 2022 for each category in descending order
select 
	category, 
	sum(total_sale) 
from retail_sales 
where sale_date >= '2022-01-01' 
AND sale_date <= '2022-12-31'
group by category
order by sum(total_sale) desc;
    
/* Transactions where the customer is above 40 years old and purchased items 
	from the 'Electronics' category between March and June 2023. */
select * from retail_sales
where category = "Electronics"
	and age > 40
	and sale_date between '2023-03-01' and '2023-06-30';

/* Calculate the total profit per category and display 
	only categories with profit above 50,000. */
select c
	ategory, 
	round(sum(profit), 2) as profit_made 
from retail_sales
group by category
having profit_made > 50000
order by profit_made desc;

# Find the top 3 highest-selling days (based on total_sale) in each month.
select *
from (
    select
        sale_date,
        SUM(total_sale) AS daily_total,
        RANK() over (partition by EXTRACT(year from sale_date), EXTRACT(month from sale_date)
                     order by SUM(total_sale) desc) as ranking
    from retail_sales
    group by sale_date
) as t
where ranking <= 3;

# Customers with more than 5 purchases in a single month.
SELECT 
    customer_id,
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month_number,
    COUNT(*) AS num_transactions
FROM retail_sales
GROUP BY customer_id, year, month_number
having num_transactions > 5
order by customer_id;


# Average price per unit for each category
SELECT
	category,
    round(AVG(price_per_unit), 0) AS average_price
FROM retail_sales
GROUP BY category
order by average_price desc;

# Transactions with Quantity > 3 on weekends
SELECT *
FROM retail_sales
WHERE 
    quantity > 3
    AND DAYOFWEEK(sale_date) IN (1,7);
        
# Customers who purchased from at least 3 different categories
SELECT customer_id, COUNT(DISTINCT category) as purchased_categories
FROM retail_sales
GROUP BY customer_id
having purchased_categories >= 3;

# Most Popular age group by number of transactions
SELECT
    CASE
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

# Top Selling Category in each Gender
SELECT * 
FROM (
	SELECT 
		category,
		gender,
		sum(total_sale),
		RANK() over (PARTITION BY gender order by sum(total_sale) desc) as RANKING
	FROM retail_sales
	GROUP BY gender, category)
AS TOP_CATEGORY
HAVING RANKING = 1;

# Total revenue per shift (Morning, Afternoon, Evening) and rank
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    SUM(total_sale) AS total_revenue,
    RANK() OVER (ORDER BY SUM(total_sale) DESC) AS ranking
FROM hourly_sale
GROUP BY shift;





