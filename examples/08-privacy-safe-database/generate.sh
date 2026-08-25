#!/usr/bin/env bash
# Recipe 08: build a privacy-safe development database and run the PII audit.
# Requires: weavori CLI (logged in), Docker.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://weavori:weavori@localhost:5433/source}"
TARGET_DSN="${TARGET_DSN:-postgres://weavori:weavori@localhost:5434/target}"
ROWS="${ROWS:-10000}"

docker compose up -d
until docker compose exec -T source pg_isready -U weavori -d source >/dev/null 2>&1; do
  sleep 1
done

weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows "$ROWS" --yes

echo
echo "PII audit (queries/audit.sql):"
docker compose exec -T target psql -U weavori -d target < queries/audit.sql

echo
echo "Sanity check — every email must be derived, none from real people:"
docker compose exec -T target psql -U weavori -d target -c \
  "SELECT count(*) AS emails_not_derived
   FROM employees
   WHERE email !~ '@example\.com$' OR email <> lower(email);"
