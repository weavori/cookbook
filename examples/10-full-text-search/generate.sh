#!/usr/bin/env bash
# Recipe 10: build a 100k-article corpus and exercise full-text search.
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
echo "Search setup and proof (search.sql):"
docker compose exec -T target psql -U weavori -d target < search.sql
