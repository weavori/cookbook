# Recipe 01 — Your First Realistic Database

**Problem.** Your new app has no test data. Hand-written fixtures are a
handful of rows that never look like production.

**Result.** A 1,000-row (per table) database with 100% referential integrity —
generated with zero configuration.

## 1. Problem

Your application works on the three test rows your team wrote by hand. Will it
survive a thousand customers, a thousand orders, and the queries real users
actually run?

## 2. Schema

[`schema.sql`](schema.sql): `customers` and `orders` — a foreign key, a CHECK
constraint, a nullable `paid_at`, and a `now()` default.

## 3. How the data should look

- 1,000 customers, 1,000 orders (change with `ROWS=... ./generate.sh`).
- Emails derived from names, not random strings — see
  [`weavori.yaml`](weavori.yaml).
- Everything else left to Weavori's semantic matcher: `first_name`,
  `last_name`, `country`, `status`, `total` each get a realistic generator.
- `created_at` is skipped — the database owns it (`now()` default).

## 4. Run

```bash
./generate.sh
```

Which runs: `docker compose up` → `weavori generate $SOURCE_DSN --target $TARGET_DSN --rows 1000 --yes`.

Without `--yes`, Weavori shows the interactive plan first:

```text
=== Generation Plan ===
  public.customers → 1000 rows
  public.orders → 1000 rows
```

## 5. The database

You now have a referentially intact replica:

- `customers` is generated first; every `orders.customer_id` is copied from a
  real generated parent row (integrity **by construction**, not by checking).
- Emails look like `jane.doe@example.com`, not `User48213`.
- Sequences are synced afterwards — future application inserts never collide
  with generated IDs.

## 6. Use it

Run your app against it, or check the data directly:

```bash
docker compose exec -T target psql -U weavori -d target \
  -c "SELECT status, count(*) FROM orders GROUP BY status;"
```

## 7. Prove it

```bash
docker compose exec -T target psql -U weavori -d target \
  -c "SELECT count(*) FROM orders o JOIN customers c ON c.id = o.customer_id;"
```

The join count **equals** the order count — every order points at a real
customer, and the referential integrity holds at the volume your hand-written
fixtures never reached.

## 8. Reproduce

```bash
git clone <this-repo>
cd 01-first-database
./generate.sh
```

Everything is in this directory: schema, config, compose file, script.

**Notes**

- `--rows N` is per table; per-table counts are set interactively in the
  preview (TTY only).
- The schema cache makes repeat runs start in milliseconds.
