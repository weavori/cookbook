# Recipe 05 — The 5-Million-Row E-commerce Database

**Problem.** Your application works with 10,000 orders. What happens at
5 million?

**Result.** A production-shaped PostgreSQL database — FK chains across eight
tables, your own product vocabulary, derived emails, coherent lifecycle
timestamps — ready for load tests, migrations, benchmarks, analytics, and
AI workflows.

## 1. Problem

"Works on my machine" scales badly when the machine has 500× more data.
Queries time out, migrations hit unexpected duplicates, load tests plateau —
none of it visible on the 10K-order staging set. You need a database that
*behaves* like production to find these before users do.

## 2. Schema

[`schema.sql`](schema.sql): the shape of a real store — `categories` →
`products`, `customers`, `orders` (enum status, temporal `paid/shipped/
delivered` columns, CHECK chains), `order_items`, `payments`, `shipments`,
`reviews`.

## 3. How the data should look

| Table | Target rows | How it's made |
|---|---|---|
| `customers` | 500,000 | matcher names + country dataset + email formula |
| `orders` | 5,000,000 | FK-sampled customers, enum status, coherent timestamps |
| `order_items` | 12,000,000 | FK-sampled orders and products, priced by the money matcher |
| `products` / `categories` | 15 / 6 | your real SKU vocabulary (dataset) |
| `payments` / `shipments` / `reviews` | same base | FK chains with realistic methods, carriers, ratings |

Configured in [`weavori.yaml`](weavori.yaml): datasets supply `sku`, `name`,
and `country`; formulas derive `email` and `slug`. Every other column comes
from the schema-aware matcher.

**About row counts**: the scripted path applies one `--rows` base to every
table. For the exact 500K/5M/12M shape, run without `--yes` and set per-table
counts in the interactive preview. Volume is what matters for the
experiments — `ROWS=100000` gives a 2-minute smoke test.

## 4. Run

```bash
./generate.sh          # 5M per table; or ROWS=100000 ./generate.sh
```

Or plan first without generating anything:

```bash
weavori estimate "$SOURCE_DSN"
```

## 5. The database

Eight tables, tens of millions of rows, referentially intact by construction:
every `order_items.order_id` points at a real order, every order at a real
customer. Lifecycle timestamps are coherent — a row is never `paid` without a
`paid_at`, and `placed_at ≤ paid_at ≤ shipped_at ≤ delivered_at` always holds
(cross-column enforcement, zero config). Identity sequences are synced, so
your app can keep inserting.

## 6. Use it

```bash
# Distribution sanity — does it look like production?
docker compose exec -T target psql -U weavori -d target -c \
  "SELECT status, count(*) FROM orders GROUP BY status ORDER BY count(*) DESC;"

# Application tests / load tests / migrations against :5434
export DATABASE_URL=postgres://weavori:weavori@localhost:5434/target
```

Then run the experiments from this cookbook against this same database:

- [Migration testing](../03-migration-testing/README.md) — realistic
  duplicates, the same way production has them
- [Query performance](../04-query-performance/README.md) — index
  before/after on a real-sized table
- [Analytics](README.md#analytics) — cohort and funnel queries that need volume

## 7. Prove it

```sql
-- Referential integrity at scale: must equal the order_items count
SELECT count(*) FROM order_items oi JOIN orders o ON o.id = oi.order_id;

-- Coherence: must be 0
SELECT count(*) FROM orders
WHERE paid_at IS NOT NULL AND status NOT IN ('paid', 'shipped', 'delivered');

-- Realism: a skewed, production-looking distribution
SELECT country, count(*) FROM customers GROUP BY country ORDER BY count(*) DESC LIMIT 5;
```

The first two queries returning exactly what they should — at 5M orders — is
the proof that the database *behaves* like production.

### Analytics

```sql
-- Monthly revenue trend (the dashboard query)
SELECT date_trunc('month', paid_at) AS month, SUM(total) AS revenue
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered')
GROUP BY 1 ORDER BY 1;

-- Customer lifetime value: the top decile
SELECT width_bucket(lifetime, 0, (SELECT max(lifetime) FROM (
         SELECT SUM(total) AS lifetime FROM orders GROUP BY customer_id) x), 10) AS decile,
       count(*)
FROM (SELECT SUM(total) AS lifetime FROM orders GROUP BY customer_id) y
GROUP BY 1 ORDER BY 1;
```

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/05-ecommerce-scale
./generate.sh
```

Everything ships in this directory: schema, config, datasets, compose file,
script.

**Notes**

- **Windows:** run `./generate.sh` via Git Bash or WSL (see the root README's
  Platform support section).
- ~10 GB free disk at 5M rows/table; `ROWS=100000` needs far less.
- Generation streams in constant memory; millions of rows do not require
  millions of buffers.
- Authentication required (`weavori login` or `WEAVORI_API_KEY`).
