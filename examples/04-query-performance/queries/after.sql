-- AFTER: two indexes on the FK columns, then the same query.

CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_orders_customer_id ON orders (customer_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT c.id, c.first_name, c.last_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY revenue DESC
LIMIT 10;
