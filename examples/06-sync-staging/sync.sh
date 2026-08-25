#!/usr/bin/env bash
# Recipe 06: clone a production database to staging, FK-safe.
# Requires: weavori CLI (Pro license, logged in).
set -euo pipefail

SOURCE_DSN="${SOURCE_DSN:?set SOURCE_DSN (e.g. the production DSN)}"
TARGET_DSN="${TARGET_DSN:?set TARGET_DSN (e.g. the staging DSN)}"

weavori sync "$SOURCE_DSN" --target "$TARGET_DSN" --mode copy
