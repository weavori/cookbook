#!/usr/bin/env bash
# Recipe 05: the 5-million-row e-commerce database.
# Requires: weavori CLI (logged in), Docker, ~10GB free disk.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://weavori:weavori@localhost:5433/source}"
TARGET_DSN="${TARGET_DSN:-postgres://weavori:weavori@localhost:5434/target}"
ROWS="${ROWS:-5000000}"

docker compose up -d
until docker compose exec -T source pg_isready -U weavori -d source >/dev/null 2>&1; do
  sleep 1
done

# Scripted runs apply ROWS to every table. For the 500K/5M/12M shape, drop
# --yes and set per-table counts in the interactive preview instead.
weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows "$ROWS" --yes

echo
echo "Row counts in the generated database:"
docker compose exec -T target psql -U weavori -d target -c \
  "SELECT 'customers' AS table_name, count(*) FROM customers
   UNION ALL SELECT 'orders', count(*) FROM orders
   UNION ALL SELECT 'order_items', count(*) FROM order_items
   UNION ALL SELECT 'products', count(*) FROM products;"
