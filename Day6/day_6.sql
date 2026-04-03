CREATE TABLE subs_day6_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(20)
);

INSERT INTO subs_day6_customers (customer_id, customer_name, region) VALUES
(1, 'Alpha Corp', 'North'),
(2, 'Beta Ltd',  'South'),
(3, 'Gamma Inc', 'East'),
(4, 'Delta LLC', 'West'),
(5, 'Epsilon Co','North');

CREATE TABLE subs_day6_subscriptions (
    sub_id INT PRIMARY KEY,
    customer_id INT REFERENCES subs_day6_customers(customer_id),
    start_date DATE,
    end_date DATE
);

INSERT INTO subs_day6_subscriptions (sub_id, customer_id, start_date, end_date) VALUES
(101, 1, '2024-10-01', NULL),
(102, 2, '2024-11-15', '2025-02-28'),
(103, 3, '2025-01-05', NULL),
(104, 4, '2024-12-20', '2025-03-15'),
(105, 5, '2025-02-10', NULL);


/*Assume “snapshot date” = 2025‑03‑31 and the rule:

A customer is active at snapshot if start_date <= snapshot_date and (end_date IS NULL OR end_date > snapshot_date).
Otherwise they are churned (subscription ended on or before snapshot).

Tasks:

1. Write a query that returns, per customer:
customer_id, customer_name, region, start_date, end_date,
status_at_snapshot = 'Active' or 'Churned' based on the rule above.

2. Using a CTE, aggregate to region level:
active_customers, churned_customers, and total_customers per region.
churn_rate_pct = churned_customers / total_customers * 100.

3. Return one row per region with:
region, active_customers, churned_customers, total_customers, churn_rate_pct.

4. Concept questions (answer in comments/SQL or here):
How would results change if snapshot date were 2025‑02‑28 instead?
Why is clearly defining the snapshot date and churn rule crucial for consistent churn metrics?

*/
with status_cte as(
select 
c.customer_id,
c.customer_name,
c.region,
s.start_date,
s.end_date,
case 
	when s.start_date <= date '2025-03-31'
		and (s.end_date is null or s.end_date > date '2025-03-31')
		then 'Active'
		else 'Churned' end as status_as_snapshot
from subs_day6_customers c
join subs_day6_subscriptions s
on c.customer_id = s.customer_id),

-- active_customers, churned_customers, and total_customers per region. churn_rate_pct = churned_customers / total_customers * 100.
region_cte as(
	select 
	region,
	count(case when status_as_snapshot = 'Active' then customer_id end) as active_customer,
	count(case when status_as_snapshot = 'Churned' then customer_id end) as churned_customer,
	count(customer_id) as total_customers,
	round(
		count(case when status_as_snapshot = 'Churned' then customer_id end) * 100 / nullif(count(customer_id), 0), 2
		) as churn_rate_pct
	from status_cte
	group by region),

final_cte as(
select region, active_customer,churned_customer, total_customers, churn_rate_pct
from region_cte)

select * from final_cte	

/*4. Concept questions (answer in comments/SQL or here):
1. How would results change if snapshot date were 2025‑02‑28 instead?
Ans: The results change mainly for Delta LLC. At the earlier snapshot (Feb 28),
they’re still active; at the later snapshot (Mar 31), they’ve churned.

2. Why is clearly defining the snapshot date and churn rule crucial for consistent churn metrics?
Ans : The snapshot date is the reference point in time
when you measure whether a customer is active or churned.Without a fixed snapshot date, churn metrics become inconsistent
The churn rule defines what counts as churn. If the rule isn’t consistent, two analysts could classify the same customer differently, 
leading to unreliable metrics.

Clear, consistent definitions of snapshot date and churn rule ensure
that churn metrics are stable, comparable, and trustworthy.
*/