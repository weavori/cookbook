# Quickstart

The smallest end-to-end Weavori run: introspect an existing schema, review the
generation plan, and write referentially intact synthetic data into a target
database.

## Setup

```bash
# 1. Create a source database and apply the schema
createdb weavori_demo_source
psql "$SOURCE_DSN" -f schema.sql

# 2. Create an empty target database (Weavori creates the tables for you)
createdb weavori_demo_target
```

## Run

```bash
weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows 1000 --yes
```

Without `--yes`, Weavori shows the interactive generation plan first:

```
=== Generation Plan ===
  public.customers → 1000 rows
  public.orders → 1000 rows
```

## What you get

- **Referential integrity by construction** — `customers` is generated first;
  every `orders.customer_id` is copied from a real generated parent row.
- **Schema-aware values** — `first_name`, `last_name`, `email`, `country`,
  `status`, `total`, and `created_at` each get a semantic generator from the
  column-name matcher (~230 rules); no configuration needed.
- **Skipped columns handled automatically** — `created_at` has a `now()`
  default, so Weavori leaves it to the database and says so in the plan:
  `[triggers skip: created_at (default: now())]`.
- **Sequences synced** — after generation, identity sequences are advanced so
  future application inserts never collide with generated IDs.

## Verify

```bash
psql "$TARGET_DSN" -c "SELECT status, count(*) FROM orders GROUP BY status;"
psql "$TARGET_DSN" -c "SELECT count(*) FROM orders o JOIN customers c ON c.id = o.customer_id;"
```

The join count must equal the row count — every order points at a real customer.

## Notes

- `--rows N` is per table; the default is 1000.
- `--target` defaults to creating a new local database when omitted.
- Schema introspection is cached on disk; use `--no-cache` to force
  re-introspection, or `weavori cache clear` to empty the cache.
