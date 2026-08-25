# Recipe 04 — Query Performance at Volume

**Problem.** Your report query is fine on dev data and crawls in production.
Nobody believes the dashboard numbers until you prove it on a real-sized
database.

**Result.** The same query: ~seconds before, ~milliseconds after one pair of
indexes — measured on a 1,000,000-row-per-table replica (change with `ROWS`).

## 1. Problem

"Revenue per customer" runs in 40 ms against 100 dev rows. At a million
orders it takes seconds — and your dev environment never showed you that,
because dev data is tiny.

## 2. Schema

[`schema.sql`](schema.sql): the classic star-ish shape — customers → orders →
order_items, plus products. **Postgres does not index FK columns
automatically.** That omission is the whole experiment.

## 3. How the data should look

- 1,000,000 rows per table (change with `ROWS=... ./generate.sh`).
- Realistic totals: `unit_price` follows the product-price matcher,
  `quantity` is a positive integer.
- `ANALYZE` runs after generation so the planner sees real statistics.

## 4. Run

```bash
./generate.sh
```

## 5. The database

Four million rows of referentially intact data — every `order_items.order_id`
points at a real order, every `orders.customer_id` at a real customer.

## 6. Use it — run the benchmark

```bash
docker compose exec -T target psql -U weavori -d target -f queries/before.sql
```

Note the `Execution Time` line. Then create the indexes and repeat:

```bash
docker compose exec -T target psql -U weavori -d target -f queries/after.sql
```

## 7. Prove it

On a typical machine at 1M rows/table:

```text
Query before optimization: ~4.8s   (Seq Scan on order_items per order)
Query after optimization:  ~320ms  (Index Only/Index Scans)
```

Expect a **10–30× speedup**; exact numbers depend on your hardware — the
`EXPLAIN (ANALYZE, BUFFERS)` output is the reproducible proof. Also compare
the `Buffers` counts: they drop by orders of magnitude, which is what matters
under load.

## 8. Reproduce

```bash
git clone <this-repo>
cd 04-query-performance
./generate.sh
docker compose exec -T target psql -U weavori -d target -f queries/before.sql
docker compose exec -T target psql -U weavori -d target -f queries/after.sql
```

**Windows:** run the scripts via Git Bash or WSL (see the root README's
Platform support section).

**Why this works**: a query's performance depends on *data volume and shape*,
not on whether the data is real. A million-row replica with real FK
relationships gives you the same query plans as production — before you ship.
