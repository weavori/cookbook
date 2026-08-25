#!/usr/bin/env bash
# Recipe 04: build the volume database the benchmark runs against.
# Requires: weavori CLI (logged in), Docker.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://weavori:weavori@localhost:5433/source}"
TARGET_DSN="${TARGET_DSN:-postgres://weavori:weavori@localhost:5434/target}"
ROWS="${ROWS:-1000000}"

docker compose up -d
until docker compose exec -T source pg_isready -U weavori -d source >/dev/null 2>&1; do
  sleep 1
done

weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows "$ROWS" --yes

# Fresh statistics so the planner behaves like a production database
docker compose exec -T target psql -U weavori -d target -c "ANALYZE;"

echo
echo "Database ready: $ROWS rows per table. Run queries/before.sql then queries/after.sql"
