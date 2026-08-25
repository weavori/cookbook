#!/usr/bin/env bash
# Recipe 09: the CI pipeline, run locally. In CI (see .github/workflows/ci.yml)
# the same steps run with WEAVORI_API_KEY instead of a logged-in session.
# Requires: weavori CLI (logged in), Docker.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://weavori:weavori@localhost:5433/source}"
TARGET_DSN="${TARGET_DSN:-postgres://weavori:weavori@localhost:5434/target}"
ROWS="${ROWS:-1000}"

docker compose up -d
until docker compose exec -T source pg_isready -U weavori -d source >/dev/null 2>&1; do
  sleep 1
done

weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows "$ROWS" --yes \
  --formula 'email=lower(concat(first_name, ".", last_name, "@example.com"))'

echo
echo "Assertions:"
docker compose exec -T target psql -U weavori -d target -v ON_ERROR_STOP=1 -f - < verify.sql
echo "All assertions passed."
