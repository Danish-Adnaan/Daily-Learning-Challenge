/*Tasks:

1. For each customer, ordered by order_date, add:

running_total_value = cumulative sum of order_value.
rolling_2_order_avg = average of the current and previous order_value (for the first order, it can just be that order’s value).
Use window functions with an explicit ROWS BETWEEN frame so you practise the syntax.

2. Add a query that returns, for all orders together (not per customer), each order with:
overall_rank_by_value = rank orders by order_value descending.
percent_rank_within_customer = PERCENT_RANK() of each order’s value within that customer’s orders.

3. Final output (you can do this in one or two queries, as you like):
customer_id, order_id, order_date, order_value, running_total_value, rolling_2_order_avg, overall_rank_by_value, percent_rank_within_customer.

*/


CREATE TABLE day8_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_value NUMERIC(10,2)
);

INSERT INTO day8_orders (order_id, customer_id, order_date, order_value) VALUES
(401, 1, '2025-01-05', 80.00),
(402, 1, '2025-01-20', 120.00),
(403, 1, '2025-02-10', 150.00),
(404, 2, '2025-01-15', 50.00),
(405, 2, '2025-02-18', 70.00),
(406, 3, '2025-02-01', 200.00),
(407, 3, '2025-03-05', 180.00),
(408, 3, '2025-03-25', 220.00),
(409, 4, '2025-03-10', 40.00),
(410, 5, '2025-03-20', 90.00);

--running_total_value = cumulative sum of order_value.
--rolling_2_order_avg = average of the current and previous order_value (for the first order, it can just be that order’s value).

select
	customer_id,
	order_value,
	sum(order_value) over (
	order by order_date 
	rows between unbounded preceding and current row
	) as running_total_value,
	round (avg(order_value) over (
	partition by customer_id
	order by order_date
	rows between 1 preceding and current Row
	),2)as rolling_2_order_avg,
	rank() over (
	order by order_value desc
	) as overall_rank_by_value,
-- percent_rank_within_customer
	percent_rank() over(
	partition by customer_id
	order by order_value
	) as percent_rank_within_customer
from day8_orders
