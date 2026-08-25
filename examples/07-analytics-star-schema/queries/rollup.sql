-- The report query a dashboard would run: revenue by segment and month.
-- Joins the fact table to both dims, then buckets sold_at by month.

SELECT date_trunc('month', s.sold_at)::date AS month,
       c.segment                          AS segment,
       count(*)                           AS orders,
       round(sum(s.total), 2)             AS revenue
FROM fact_sales s
JOIN customers c ON c.id = s.customer_id
GROUP BY 1, 2
ORDER BY month DESC, revenue DESC
LIMIT 12;
