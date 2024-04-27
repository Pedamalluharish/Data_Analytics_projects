USE sqlexpress
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

SELECT * FROM df_orders

-- Question 1 : Find top 10 highest revenue generating products
SELECT product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- Question 2 : Find Top 5 highest selling products in each region
SELECT DISTINCT region from df_orders

WITH cte as (
SELECT region, product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM (
SELECT *,
row_number() OVER(partition by region order by sales desc) as rnk
FROM cte) A
WHERE rnk<=5

-- Question 3 : Find Month over month growth comparision for 2022 and 2023 sales eg: Jan2022 Vs Jan2023
SELECT DISTINCT YEAR(order_date) FROM df_orders

WITH cte as (
SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, 
SUM(sale_price) AS sales
FROM df_orders
GROUP BY order_year, order_month
-- ORDER BY order_year, order_month
)
SELECT order_month
, SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month

-- Question 4 : For each category which month has highest sales
WITH cte AS (
SELECT category, FORMAT(order_date,'yyyyMM') AS order_year_month,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY category,FORMAT(order_date,'yyyyMM')
-- ORDER BY category,FORMAT(order_date,'yyyyMM')
)
SELECT * FROM (
SELECT  * ,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) as rnk
FROM cte ) a
WHERE rnk =1

-- Question 5 : Which subcategory has highest growth by profit in 2023 compare to 2022

WITH cte as (
SELECT sub_category, YEAR(order_date) AS order_year,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY sub_category, order_year
-- ORDER BY order_year, order_month
)
, cte2 AS (
SELECT sub_category
, SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
)
SELECT * 
,(sales_2023 - sales_2022)*100/sales_2022 AS Highest_percent_sales_2023
FROM cte2
ORDER BY Highest_percent_sales_2023 DESC
LIMIT 5





    