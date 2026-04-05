CREATE TABLE day7_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(20)
);

INSERT INTO day7_customers (customer_id, customer_name, region) VALUES
(1, 'Asha', 'North'),
(2, 'Rohit', 'South'),
(3, 'Lakshmi', 'East'),
(4, 'Imran', 'West'),
(5, 'Neha', 'North');

CREATE TABLE day7_orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES day7_customers(customer_id),
    order_date DATE,
    order_value NUMERIC(10,2)
);

INSERT INTO day7_orders (order_id, customer_id, order_date, order_value) VALUES
(301, 1, '2025-01-05', 80.00),
(302, 1, '2025-02-15', 120.00),
(303, 2, '2025-01-20', 50.00),
(304, 2, '2025-03-10', 70.00),
(305, 3, '2025-02-01', 200.00),
(306, 3, '2025-03-20', 150.00),
(307, 4, '2025-03-05', 40.00),
(308, 5, '2025-02-25', 90.00),
(309, 5, '2025-03-25', 110.00);


/*Assume reference date for recency = 2025‑03‑31.

Concept focus: basic RFM components and segmentation via SQL.

Tasks:

1. Using a CTE grouped by customer, compute:
last_order_date
order_count
total_revenue.

2. Add recency in days:
recency_days = days between 2025‑03‑31 and last_order_date (use DATE arithmetic).

3. Add score buckets with CASE expressions:

recency_score:
≤ 15 days → 3
16–45 days → 2
> 45 days → 1

frequency_score:
order_count >= 3 → 3
order_count = 2 → 2
order_count = 1 → 1

monetary_score:
total_revenue >= 250 → 3
100–249.99 → 2
< 100 → 1.

4. Create an overall rfm_segment as the concatenation of the three scores (e.g., 3-2-1) and return, per customer:

customer_id, customer_name, region, recency_days, order_count, total_revenue, recency_score, frequency_score, monetary_score, rfm_segment*/


last_order_date

order_count

total_revenue

with customer_cte as(
select customer_id,

max(date(order_date)) as last_order_date,
count(order_id) as order_count,
sum(order_value) as total_revenue

from day7_orders
group by customer_id
order by customer_id)

select * from customer_cte 


/*Add recency in days:

recency_days = days between 2025‑03‑31 and last_order_date (use DATE arithmetic).*/

with recency_cte as(
select 
	customer_id,
	max(order_date)::date as last_order_date,
	count(order_id) as order_count,
	sum(order_value) as total_revenue,
	('2025-03-31'::date - Max(order_date)::date) as recency_days
	from day7_orders
	group by customer_id
)

select * from recency_cte 
order by customer_id;

with condition_cte as(
select 
	customer_id,
	max(order_date)::date as last_order_date,
	count(order_id) as order_count,
	sum(order_value) as total_revenue,
	('2025-03-31'::date - Max(order_date)::date) as recency_days,
	case
		when ('2025-03-31'::date - Max(order_date)::date) <= 15 then 3 
	 	when ('2025-03-31'::date - Max(order_date)::date) Between 16 and 45 then 2
		else 1
	end as recency_score,
	case
		when count(order_id) >= 3 then 3
		when count(order_id) = 2 then 2
		else 1
	end as frequency_score,
	case
		when sum(order_value) >= 250 then 3
		when sum(order_value) between 100 and 24999 then 2
		else 1
	end as monetary_score
	from day7_orders
	group by customer_id
),
final_cte as(
select
	c.customer_id,
	c.customer_name,
	c.region,
	r.recency_days,
	r.order_count,
	r.total_revenue,
	r.recency_score,
	r.frequency_score,
	r.monetary_score,
	concat(r.recency_score::text,'-',r.frequency_score::text,'-',r.monetary_score::text) as rfm_segment
from day7_customers c
inner join condition_cte r
on c.customer_id = r.customer_id
)
select * from final_cte 
order by customer_id

/*Concept question:

Which customer(s) fall into the best RFM segment (e.g., 3-3-3 if any), and how would a marketing team treat them vs a low‑score segment?
Ans High scores (e.g., 3‑3‑3, 3‑2‑3):
Treat as Champions or Loyalists.  Reward them with loyalty perks, early access, VIP offers.Focus on retention and advocacy.

Mid scores (e.g., 2‑2‑2):
Treat as Potential Loyalists.
Makr personalized offers, reminders, and engagement campaigns. Encourage them to increase frequency or spend.

Low scores (e.g., 2‑1‑1):
Treat as At Risk or Hibernating.
Re‑engage with win‑back campaigns, discounts, or targeted nudges.If they don’t respond, reduce marketing spend on them. */
