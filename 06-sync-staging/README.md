# Recipe 06 — Clone Production to Staging

**Problem.** Every week you rebuild staging with dump/restore gymnastics, and
it's half a day of fiddling with FK order, permissions, and "why does this
table import before that one?"

**Result.** One command copies real rows from one PostgreSQL database to
another — in FK-safe order (parents before children), over the fast COPY
protocol. (Pro feature.)

## 1. Problem

Staging should look like production. Instead it's a snapshot from three
months ago, because re-cloning means pg_dump, schema ordering, and praying.

## 2. Schema

None needed — `weavori sync` introspects the **source** database and creates
the target schema from it (`--create-tables`, default on).

## 3. How the data should look

Identical to the source: this is a data-copy tool, not a masking pipeline.
Sync copies values unmasked, in FK dependency order, so the target is
referentially intact — the same guarantee generation provides.

## 4. Run

```bash
SOURCE_DSN=postgres://prod... TARGET_DSN=postgres://staging... ./sync.sh
```

which runs:

```bash
weavori sync "$SOURCE_DSN" --target "$TARGET_DSN" --mode copy
```

Targeted copies:

```bash
weavori sync "$SOURCE_DSN" --target "$TARGET_DSN" --schema public
weavori sync "$SOURCE_DSN" --target "$TARGET_DSN" --table orders
```

## 5. The database

A staging database whose row counts and shapes match production — with the
referential integrity intact, because parents sync before children.

## 6. Use it

```bash
export DATABASE_URL="$TARGET_DSN"
# run the test suite, the load test, the migration rehearsal...
```

## 7. Prove it

```bash
psql "$TARGET_DSN" -c "
  SELECT (SELECT count(*) FROM orders) AS orders,
         (SELECT count(*) FROM customers) AS customers;
"
```

Compare to the source — row counts match, and the FK join counts equal the
row counts (same integrity check as the other recipes, now on real data).

## 8. Reproduce

You need two databases: a source with data and an empty target.

```bash
git clone <this-repo>
cd 06-sync-staging
SOURCE_DSN=... TARGET_DSN=... ./sync.sh
```

**Notes**

- `--mode insert` for maximum compatibility; `--batch N` tunes large tables.
- Synced rows count against the monthly quota.
- Circular FK dependencies are detected and warned about.
- For *masked* test data, use `weavori generate` (recipes 01–05) instead.
