#!/usr/bin/env bash
# Recipe 03: build the database the migration will be tested against.
# Requires: weavori CLI (logged in), Docker.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://weavori:weavori@localhost:5433/source}"
TARGET_DSN="${TARGET_DSN:-postgres://weavori:weavori@localhost:5434/target}"
ROWS="${ROWS:-100000}"

docker compose up -d
until docker compose exec -T source pg_isready -U weavori -d source >/dev/null 2>&1; do
  sleep 1
done

weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows "$ROWS" --yes

echo
echo "Duplicate emails in the generated data:"
docker compose exec -T target psql -U weavori -d target -c \
  "SELECT count(*) - count(DISTINCT email) AS duplicate_rows FROM customers;"
