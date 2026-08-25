# E-commerce

The flagship example. One schema that exercises most of Weavori's feature
surface at once: foreign keys, enum types, CHECK constraints, datasets,
formulas, temporal ordering, and conditional nullability.

## What the schema demonstrates

| Schema feature | How Weavori handles it |
|---|---|
| `orders.customer_id → customers.id`, `order_items → orders`/`products` | FK resolution — parents generate first, child FKs copied from real parent rows |
| `order_status` enum | `StrategyEnum` — values sampled from the enum's own label set |
| `orders.status` ↔ `paid_at`/`shipped_at`/`delivered_at` | Conditional nullability — a nullable `{x}_at` is `NULL` unless `status` holds a terminal value (`paid`, …) |
| `paid_at >= placed_at` CHECK chain | Binary comparison CHECKs enforced by swapping violating values |
| `price >= 0`, `quantity > 0` | Best-effort CHECK handling; violated values are regenerated/swapped |
| `is_active` | Boolean-prefix rule → `true`/`false` |

## Setup

```bash
createdb weavori_ecommerce_source
createdb weavori_ecommerce_target
psql "$SOURCE_DSN" -f schema.sql
```

## Run

From this directory (so `weavori.yaml` is picked up):

```bash
weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" --rows 500 --yes
```

Without `--yes`, review the plan first — it shows generation order (parents
before children) and any skipped columns.

## What the config does

`weavori.yaml` wires three things:

1. **Datasets** — `products.sku`/`products.name` come from `datasets/products.csv`
   (your real SKU vocabulary), `customers.country` from `datasets/countries.csv`.
   Dataset mapping is the highest-priority column strategy; a bad CSV value
   fails at plan time with the exact row and column.
2. **Formulas** — `categories.slug` is derived from `name`
   (`lower(replace(name, ' ', '-'))`); `customers.email` is composed from
   `first_name`/`last_name`. Formulas are a pure transformation layer on top of
   the generated row and can reference other formula columns.
3. Nothing else — every remaining column gets its value from the semantic
   matcher or the database itself.

## Verify

```bash
psql "$TARGET_DSN" -c "SELECT status, count(*) FROM orders GROUP BY status;"
psql "$TARGET_DSN" -c "SELECT count(*) FROM orders o JOIN customers c ON c.id = o.customer_id;"
psql "$TARGET_DSN" -c "SELECT count(*) FROM orders WHERE paid_at IS NOT NULL AND status NOT IN ('paid','shipped','delivered');"
```

The last query must return `0` — a row is never `paid` without a `paid_at`.

## Try the same run without a database

The whole example also works in DDL paste mode — no source database needed:

```bash
weavori generate --input schema.sql --input-format ddl --rows 100 --format json
```

See [ddl-paste-mode](../ddl-paste-mode/README.md).
