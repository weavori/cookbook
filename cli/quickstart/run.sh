#!/usr/bin/env bash
# Quickstart: introspect -> generate -> verify.
# Requires: weavori CLI (logged in), local PostgreSQL.
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:-postgres://localhost/weavori_demo_source}"
TARGET_DSN="${TARGET_DSN:-postgres://localhost/weavori_demo_target}"

createdb weavori_demo_source 2>/dev/null || true
createdb weavori_demo_target 2>/dev/null || true

psql "$SOURCE_DSN" -f schema.sql

weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows 1000 --yes

psql "$TARGET_DSN" -c "SELECT count(*) FROM orders o JOIN customers c ON c.id = o.customer_id;"
