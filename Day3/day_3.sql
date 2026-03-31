CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_cost NUMERIC(10,2)
);

INSERT INTO products (product_id, product_name, category, unit_cost) VALUES
(1, 'Basic Tee', 'Apparel', 5.00),
(2, 'Premium Hoodie', 'Apparel', 18.00),
(3, 'Running Shoes', 'Footwear', 30.00),
(4, 'Sneakers', 'Footwear', 22.00),
(5, 'Sports Cap', 'Accessories', 4.00);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT REFERENCES products(product_id),
    order_date DATE,
    quantity INT,
    unit_price NUMERIC(10,2)
);

INSERT INTO order_items (order_item_id, order_id, product_id, order_date, quantity, unit_price) VALUES
(1, 1001, 1, '2025-01-05', 5, 10.00),
(2, 1001, 5, '2025-01-05', 3, 8.00),
(3, 1002, 2, '2025-01-06', 2, 25.00),
(4, 1003, 3, '2025-01-10', 1, 55.00),
(5, 1003, 5, '2025-01-10', 4, 7.50),
(6, 1004, 4, '2025-01-12', 3, 35.00),
(7, 1005, 2, '2025-01-15', 1, 24.00),
(8, 1005, 3, '2025-01-15', 2, 50.00),
(9, 1006, 1, '2025-01-20', 10, 9.00),
(10,1006, 4, '2025-01-20', 2, 32.00);


/*

1.Write a query that returns, for each order_item row:
order_item_id, order_id, product_name, category, revenue (unit_price * quantity), profit as defined above.

2.Using a CTE, aggregate to the order_id level:
order_id, order_date, total_revenue, total_profit.

3.From this order‑level CTE, compute:
profit_margin_pct = total_profit / total_revenue * 100.

4.Finally, write a query that returns, for each product:
product_id, product_name, category,
total_quantity_sold, total_revenue, total_profit,
and a rank of products within each category by total_profit (highest profit = rank 1) using a window function.*/


with order_summary as(
select 
o.order_item_id, o.order_id, o.order_date, p.product_name, p.category, o.unit_price * o.quantity as revenue, (o.unit_price - p.unit_cost) * o.quantity as profit
from order_items o 
inner join products p
on o.product_id = p.product_id ),

order_level as(
select c.order_id,c.order_date, sum(c.revenue) as total_revenue, sum (c.profit) as total_profit
from order_summary c
group by c.order_id, c.order_date),

profit_percentage as(
select order_id, order_date, total_revenue, total_profit, 
round((total_profit * 100.0 / NULLIF(total_revenue,0)),2) as profit_margin_pct from order_level),
-- select * from profit_percentage;

main_query as(
select p.product_id , p.product_name, p.category, sum(o.quantity) as total_quantity_sold,
sum(o.unit_price * o.quantity) as total_revenue, 
sum((o.unit_price - p.unit_cost) * o.quantity) as total_profit,
rank()
over(partition by p.category order by sum((o.unit_price - p.unit_cost) * o.quantity) desc) as profit_rank
from order_items o  
inner join products p
on o.product_id = p.product_id
group by p.product_id, p.product_name, p.category)

select * from main_query;