#!/usr/bin/env bash
# Recipe 07: build an analytics-ready star schema and run the report query.
# Requires: weavori CLI (logged in), Docker.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://weavori:weavori@localhost:5433/source}"
TARGET_DSN="${TARGET_DSN:-postgres://weavori:weavori@localhost:5434/target}"
ROWS="${ROWS:-100000}"

docker compose up -d
until docker compose exec -T source pg_isready -U weavori -d source >/dev/null 2>&1; do
  sleep 1
done

# Scripted runs apply ROWS to every table. For real dim/fact ratios
# (10 products, 10k customers, 1M sales), drop --yes and set per-table
# counts in the interactive preview instead.
weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows "$ROWS" --yes

echo
echo "Monthly revenue by customer segment (queries/rollup.sql):"
docker compose exec -T target psql -U weavori -d target < queries/rollup.sql
