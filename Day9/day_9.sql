-- Step 1: Create the table
CREATE TABLE orders_Day9 (
    ORDERNUMBER   INT PRIMARY KEY,
    ORDERDATE     DATE NOT NULL,
    STATUS        VARCHAR(20),
    CUSTOMERNAME  VARCHAR(100),
    COUNTRY       VARCHAR(50),
    SALES         NUMERIC(10,2)
);

-- Step 2: Insert sample data (20 rows)
INSERT INTO orders_Day9 (ORDERNUMBER, ORDERDATE, STATUS, CUSTOMERNAME, COUNTRY, SALES) VALUES
(10001, '2022-01-15', 'Shipped', 'John Smith', 'USA', 2500.75),
(10002, '2022-01-18', 'Cancelled', 'Sarah Johnson', 'Canada', 1800.00),
(10003, '2022-02-02', 'Shipped', 'Michael Brown', 'UK', 3200.50),
(10004, '2022-02-10', 'In Process', 'Emily Davis', 'Australia', 1450.25),
(10005, '2022-02-15', 'Shipped', 'David Wilson', 'Germany', 2750.00),
(10006, '2022-03-01', 'Shipped', 'Linda Martinez', 'France', 3100.80),
(10007, '2022-03-05', 'Cancelled', 'James Taylor', 'USA', 900.00),
(10008, '2022-03-12', 'Shipped', 'Barbara Anderson', 'Canada', 4200.00),
(10009, '2022-03-20', 'In Process', 'Robert Thomas', 'UK', 1500.00),
(10010, '2022-04-01', 'Shipped', 'Patricia Jackson', 'Australia', 2300.00),
(10011, '2022-04-05', 'Shipped', 'Christopher White', 'Germany', 2800.50),
(10012, '2022-04-12', 'Cancelled', 'Mary Harris', 'France', 1200.00),
(10013, '2022-04-18', 'Shipped', 'Daniel Martin', 'USA', 3500.00),
(10014, '2022-05-01', 'In Process', 'Jennifer Thompson', 'Canada', 2100.00),
(10015, '2022-05-10', 'Shipped', 'Matthew Garcia', 'UK', 4000.00),
(10016, '2022-05-15', 'Shipped', 'Ashley Robinson', 'Australia', 2600.00),
(10017, '2022-06-01', 'Cancelled', 'Joshua Clark', 'Germany', 800.00),
(10018, '2022-06-08', 'Shipped', 'Amy Lewis', 'France', 3700.00),
(10019, '2022-06-15', 'Shipped', 'Andrew Lee', 'USA', 2900.00),
(10020, '2022-06-20', 'In Process', 'Jessica Walker', 'Canada', 1950.00);


/*1. Monthly revenue + status mix

Write a query returning, per year‑month:

year_month (e.g., 2020-01),

total_revenue (sum of SALES),

shipped_revenue, cancelled_revenue (split using STATUS),

cancel_rate_pct = cancelled_revenue / total_revenue * 100.

You will need:

Date functions to truncate/format month.

Conditional aggregation with CASE WHEN.*/

/*2. Top customers with window functions

For each COUNTRY, compute:

customer_revenue = sum(SALES) per customer.

Add:

country_rank_by_revenue = ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY customer_revenue DESC).

Return only top 3 customers per country (filter on the rank).*/

SELECT 
    TO_CHAR(DATE_TRUNC('month', ORDERDATE), 'YYYY-MM') AS year_month,
    SUM(SALES) AS total_revenue,
    SUM(CASE WHEN STATUS = 'Shipped' THEN SALES ELSE 0 END) AS shipped_revenue,
    SUM(CASE WHEN STATUS = 'Cancelled' THEN SALES ELSE 0 END) AS cancelled_revenue,
    ROUND(
        (SUM(CASE WHEN STATUS = 'Cancelled' THEN SALES ELSE 0 END) * 100.0) 
        / NULLIF(SUM(SALES), 0), 2
    ) AS cancel_rate_pct
FROM orders_Day9
GROUP BY DATE_TRUNC('month', ORDERDATE)
ORDER BY year_month;
--
WITH customer_revenue AS (
    SELECT  COUNTRY,CUSTOMERNAME,
        SUM(SALES) AS customer_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY COUNTRY 
            ORDER BY SUM(SALES) DESC
        ) AS country_rank_by_revenue
    FROM orders_Day9
    GROUP BY COUNTRY, CUSTOMERNAME
)
SELECT *
FROM customer_revenue
WHERE country_rank_by_revenue <= 3
ORDER BY COUNTRY, country_rank_by_revenue;


/*Customer lifecycle metrics

For each CUSTOMERNAME:

first_order_date, last_order_date, order_count, total_revenue.

Add a days_between_first_last using date difference.

Classify:

lifecycle_flag:

'New' if order_count = 1.

'Growing' if order_count between 2 and 5.

'Established' if order_count > 5.

*/

SELECT 
    CUSTOMERNAME,
    MIN(ORDERDATE) AS first_order_date,
    MAX(ORDERDATE) AS last_order_date,
    COUNT(*) AS order_count,
    SUM(SALES) AS total_revenue,
    (MAX(ORDERDATE) - MIN(ORDERDATE)) AS days_between_first_last,
    CASE 
        WHEN COUNT(*) = 1 THEN 'New'
        WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Growing'
        WHEN COUNT(*) > 5 THEN 'Established'
    END AS lifecycle_flag
FROM orders_Day9
GROUP BY CUSTOMERNAME
ORDER BY total_revenue DESC;