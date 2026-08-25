#!/usr/bin/env bash
# Recipe 02: generate to stdout from DDL alone — no database needed.
# Requires: weavori CLI (logged in).
set -euo pipefail

ROWS="${ROWS:-20}"

weavori generate --input schema.sql --input-format ddl --rows "$ROWS" --format json \
  --formula 'email=lower(concat(first_name, ".", last_name, "@corp.io"))'
