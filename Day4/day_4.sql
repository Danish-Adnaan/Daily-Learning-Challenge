CREATE TABLE customers_day4 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(20)
);

INSERT INTO customers_day4 (customer_id, customer_name, region) VALUES
(1, 'Riya', 'North'),
(2, 'Arjun', 'South'),
(3, 'Meera', 'West'),
(4, 'Karan', 'East'),
(5, 'Tanya', 'North');

CREATE TABLE orders_day4 (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    order_value NUMERIC(10,2)
);

INSERT INTO orders_day4 (order_id, customer_id, order_date, order_value) VALUES
(101, 1, '2025-01-05', 80.00),
(102, 1, '2025-01-20', 120.00),
(103, 2, '2025-01-10', 50.00),
(104, 2, '2025-02-15', 60.00),
(105, 2, '2025-03-01', 70.00),
(106, 3, '2025-02-05', 200.00),
(107, 4, '2025-02-20', 40.00),
(108, 4, '2025-03-10', 45.00),
(109, 5, '2025-03-05', 90.00);

/*
1. For each customer, compute:
first_order_date, last_order_date, order_count, total_spent.

2. Add a flag is_repeat_customer:
1 if order_count >= 2, else 0.

3.Using a window function over region, compute:
region_rank_by_spend = rank customers within their region by total_spent descending.

4.Return only customers where:
is_repeat_customer = 1 or total_spent >= 150.
For each such customer, show:
customer_id, customer_name, region, order_count, total_spent, is_repeat_customer, region_rank_by_spend.*/

select customer_id, min(order_date) as first_order_date, max(order_date) as last_order_date,
count(order_id) as order_count, sum(order_value) as total_spent
from orders_day4
group by customer_id
order by customer_id asc;

with data_flag as (
select customer_id, count(order_id) as order_count, 
case 
when count(order_id) >= 2 then 1
else 0
end as is_repeat_customer
from orders_day4
group by customer_id
order by customer_id asc),

region_summary as(
select c.customer_id, c.customer_name, c.region, 
sum(o.order_value) as total_spent,
row_number() over 
(partition by c.region order by sum(o.order_value) desc) as region_rank_by_spend
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name, c.region
order by c.region),

final_cte as(
select
c.customer_id, c.customer_name,c.region, count(o.order_id) as order_count,
sum(o.order_value) as total_spent, 
case 
when count(o.order_id) >= 2 then 1
else 0
end as is_repeat_customer,
row_number() over 
(partition by c.region order by sum(o.order_value) desc) as region_rank_by_spend
from customers_day4 c
inner join orders_day4 o
on c.customer_id = o.customer_id
group by c.customer_id)

select * from final_cte
where is_repeat_customer = 1 or total_spent>=150;

