# Recipe 07 — Analytics Star Schema

**Problem.** The dashboard is built, but the three hand-written rows in the dev
database tell you nothing about whether the queries actually work.

**Result.** A star schema (dims + one fact table) with 100,000 rows per table
(change with `ROWS`), and a revenue-by-segment rollup query that runs against
it — the exact shape a BI tool expects.

## 1. Problem

Analytics queries are only meaningful on analytics-shaped data: facts join to
dims, dates bucket cleanly, and aggregates come out looking like a business
rather than a coincidence. With a handful of test rows, every rollup query
"works" — and every one of them is unproven.

## 2. Schema

[`schema.sql`](schema.sql): the classic star shape — `categories`, `products`,
`customers` as dims, `fact_sales` as the single fact table, all joined on
surrogate keys.

## 3. How the data should look

- Product names and customer segments come from your own value sets
  ([`products.csv`](products.csv), [`segments.csv`](segments.csv)) — see
  [`weavori.yaml`](weavori.yaml).
- Emails and slugs are derived, so `segment` and `country` rollups don't
  collide with identity columns.
- Everything else — prices, quantities, countries, timestamps — comes from
  the semantic matcher.

## 4. Run

```bash
./generate.sh                          # ROWS=100000 per table by default
ROWS=1000000 ./generate.sh             # or scale up
```

## 5. Get the database

A target database with four referentially intact tables. `fact_sales` rows
reference real generated customers and products.

## 6. Use the database

```bash
docker compose exec -T target psql -U weavori -d target < queries/rollup.sql
```

`queries/rollup.sql` buckets `fact_sales` by month and joins both dims —
the pattern every BI dashboard is built on.

## 7. Prove the result

```text
 month      | segment        | orders | revenue
------------+----------------+--------+----------
 2026-08-01 | enterprise     |   1234 | 123456.78
 2026-08-01 | mid-market     |    987 |  98765.43
 ...
```

Aggregates that sum correctly, dims that join cleanly, and a fact table big
enough that the query plan actually matters.

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/07-analytics-star-schema
./generate.sh
```

**Notes**

- **Windows:** run `./generate.sh` via Git Bash or WSL (see the root README's
  Platform support section).
- Scripted runs apply `ROWS` to every table. For real dim/fact ratios
  (10 products, 10k customers, 1M sales), drop `--yes` and set per-table
  counts in the interactive preview.
