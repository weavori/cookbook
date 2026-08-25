-- BEFORE: the report query with no indexes.
-- order_items.order_id and orders.customer_id are unindexed FKs, so every
-- order forces a full scan of order_items.

EXPLAIN (ANALYZE, BUFFERS)
SELECT c.id, c.first_name, c.last_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY revenue DESC
LIMIT 10;
