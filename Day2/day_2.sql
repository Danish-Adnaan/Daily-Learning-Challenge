CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    customer_id INT,
    payment_date DATE,
    amount NUMERIC(10,2),
    channel VARCHAR(20)
);

INSERT INTO payments (payment_id, customer_id, payment_date, amount, channel) VALUES
(1, 101, '2025-01-05', 120.00, 'Card'),
(2, 102, '2025-01-15', 80.00, 'UPI'),
(3, 101, '2025-01-28', 60.00, 'Card'),
(4, 103, '2025-02-03', 150.00, 'NetBanking'),
(5, 104, '2025-02-10', 200.00, 'Card'),
(6, 101, '2025-02-18', 90.00, 'UPI'),
(7, 102, '2025-03-01', 70.00, 'Card'),
(8, 103, '2025-03-05', 130.00, 'UPI'),
(9, 104, '2025-03-18', 160.00, 'Card'),
(10,105, '2025-03-25', 50.00, 'NetBanking');


/*Using a CTE, compute for each month (YYYY‑MM):

month_start (first day of month),
total_revenue (sum of amount in that month),
distinct_customers (count of distinct customer_id).

2. Add a window function to calculate:

prev_month_revenue = previous month’s revenue,
mom_growth_pct = (total_revenue - prev_month_revenue) / prev_month_revenue expressed as a percentage (handle NULL for the first month).

Build a second CTE (or extend the first) to compute, per month and channel:
channel_revenue (sum of amount).
channel_rank_in_month = rank of each channel within that month by revenue (1 = highest).

Final output:

For each month and channel, show:
month_start, channel, channel_revenue, channel_rank_in_month,
the overall total_revenue for that month, and mom_growth_pct*/


with monthly_summary as 
(select
date_trunc('month',payment_date)::date as month_start,
sum(amount) as total_amount,
count(distinct(customer_id)) as Unique_customers
from payments
group by
date_trunc('month',payment_date)::date
)
,
monthly_growth as(
--prev_month_revenue
--mom_growth_pct = (total_revenue - prev_month_revenue) / prev_month_revenue expressed as a percentage
select month_start, total_amount, unique_customers,
lag(total_amount) over (order by month_start) as prev_month_revenue,
case
	when lag(total_amount) over (order by month_start) is null then null
	else round (((total_amount-lag(total_amount) over (order by month_start))
	/lag(total_amount) over (order by month_start)*100),2)
	end as mom_growth_pct
from monthly_summary
), 
channel_summary as (
select
date_trunc('month',payment_date)::date as month_start,
channel,
sum(amount) as channel_revenue,
rank()over(
partition by date_trunc('month',payment_date)::date
order by sum(amount) desc)
as channel_rank_in_month
from payments
group by date_trunc('month',payment_date)::date, channel)
-- month_start, channel, channel_revenue, channel_rank_in_month, the overall total_revenue for that month, and mom_growth_pct.
select 
c.month_start, c.channel, c.channel_revenue, c.channel_rank_in_month, m.total_amount, m.mom_growth_pct
from channel_summary c
left Join monthly_growth m
on
c.month_start = m.month_start
order by c.month_start, c.channel_rank_in_month asc;
