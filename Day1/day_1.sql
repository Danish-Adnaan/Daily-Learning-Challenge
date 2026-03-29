CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(20),
    segment VARCHAR(20)
);

INSERT INTO customers (customer_id, customer_name, region, segment) VALUES
(1, 'Alpha Corp', 'North', 'Corporate'),
(2, 'Beta Retail', 'South', 'Consumer'),
(3, 'Gamma Traders', 'East', 'Small Business'),
(4, 'Delta Homes', 'North', 'Consumer'),
(5, 'Epsilon LLC', 'West', 'Corporate');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    order_value NUMERIC(10,2)
);

INSERT INTO orders (order_id, customer_id, order_date, order_value) VALUES
(101, 1, '2025-01-03', 1200.00),
(102, 2, '2025-01-04', 300.00),
(103, 1, '2025-01-10', 800.00),
(104, 3, '2025-01-11', 450.00),
(105, 4, '2025-01-12', 200.00),
(106, 5, '2025-01-13', 1500.00),
(107, 2, '2025-01-14', 400.00),
(108, 3, '2025-01-15', 550.00),
(109, 4, '2025-01-16', 300.00),
(110, 5, '2025-01-17', 700.00);


/*Write a query that returns, for each customer:
customer_id, customer_name, region,
total_revenue (sum of order_value),
order_count (number of orders).*/

select c.customer_id,c.customer_name, c.region, sum(o.order_value) as total_revenue,count(o.order_id) as order_count from customers c
inner Join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name,c.region


/*Using a window function, add:
region_rank_by_revenue: the rank of each customer within their region 
ordered by total_revenue descending (ties should have the same rank).*/

select
 c.customer_id,c.customer_name, c.region, sum(o.order_value) as total_revenue,
 rank() over(
partition by c.region order by sum(o.order_value) desc
 ) AS region_rank_by_revenue
from customers c
inner Join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name,c.region


/*Filter the result so that only:
Customers with total_revenue >= 800, and
Only the top 2 ranked customers per region (by region_rank_by_revenue) are returned.*/

select c.customer_id, c.customer_name, c.region , sum(o.order_value) as total_revenue from customers c
inner join orders o
on c.customer_id = o.customer_id
where total_revenue >= 800 
order by total_revenue desc
limit 2;

WITH ranked AS (
    SELECT c.customer_id,c.customer_name,c.region,
        SUM(o.order_value) AS total_revenue,
        RANK() OVER (
            PARTITION BY c.region 
            ORDER BY SUM(o.order_value) DESC
        ) AS region_rank_by_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.region
    HAVING SUM(o.order_value) >= 800
)
SELECT *
FROM ranked
WHERE region_rank_by_revenue <= 2;
