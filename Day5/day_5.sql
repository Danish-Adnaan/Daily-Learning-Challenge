CREATE TABLE customers_day5 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    signup_date DATE,
    region VARCHAR(20)
);

INSERT INTO customers_day5 (customer_id, customer_name, signup_date, region) VALUES
(1, 'Nikhil', '2025-01-05', 'North'),
(2, 'Sara',   '2025-01-15', 'South'),
(3, 'Dev',    '2025-02-01', 'East'),
(4, 'Isha',   '2025-02-10', 'West'),
(5, 'Rohan',  '2025-02-20', 'North');

CREATE TABLE orders_day5 (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers_day5(customer_id),
    order_date DATE,
    order_value NUMERIC(10,2)
);

INSERT INTO orders_day5 (order_id, customer_id, order_date, order_value) VALUES
(201, 1, '2025-01-07', 60.00),
(202, 1, '2025-01-25', 90.00),
(203, 2, '2025-01-20', 120.00),
(204, 2, '2025-02-05', 80.00),
(205, 2, '2025-03-01', 70.00),
(206, 3, '2025-02-03', 150.00),
(207, 3, '2025-03-10', 110.00),
(208, 4, '2025-02-12', 40.00),
(209, 5, '2025-02-25', 90.00),
(210, 5, '2025-03-05', 95.00);


/*
Tasks:

1. Using a window function over each customer’s orders:
Label each order with order_number (1 for first order, 2 for second, etc., using ROW_NUMBER).

2. Build a CTE that calculates, grouped by signup_month (month of signup_date):
first_order_revenue = sum of order_value where order_number = 1.
repeat_order_revenue = sum where order_number > 1.
customer_count = number of distinct customers in that signup_month.

3. Add:
repeat_share_pct = repeat_order_revenue / (first_order_revenue + repeat_order_revenue) * 100.

4. Return for each signup_month:
signup_month, customer_count, first_order_revenue, repeat_order_revenue, repeat_share_pct.
*/
with order_labeled as(
select 
o.order_id,o.customer_id, o.order_date, o.order_value,
row_number() over(partition by o.customer_id order by o.order_date) as order_number,
c.signup_date
from orders_day5 o join customers_day5 c
on o.customer_id = c.customer_id),

signup_cte as(
select 
 date_trunc('month', signup_date) as signup_month,
 sum(case when order_number = 1 then order_value else 0 end) as first_order_revenue,
 sum(case when order_number >1 then order_value else 0 end) as repeat_order_revenue,
 count(distinct customer_id) as customer_count,
 round(sum (case when order_number >1 then order_value else 0 end) * 100 / 
nullif(sum(order_value),0),2) as repeat_share_pct
 from order_labeled 
 group by date_trunc('month',signup_date))
 
select signup_month, customer_count, first_order_revenue, repeat_order_revenue,
repeat_share_pct from signup_cte
order by signup_month
