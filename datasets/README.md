# Datasets

Reusable CSV value sets for `--dataset` / `--map` — the "bring your own data"
surface of Weavori. When realism means *your* actual domain values (SKUs that
exist, regions you serve, tiers you sell), datasets supply the exact value set.

## Included

| File | Contents | Typical use |
|---|---|---|
| [products.csv](products.csv) | `sku,name` pairs | E-commerce product catalog |
| [countries.csv](countries.csv) | Single-column country list | Customer/shipping tables |

## How to use

**CLI** — register and map in one go (repeatable flags):

```bash
weavori generate "$SOURCE_DSN" --target "$TARGET_DSN" \
  --dataset products=../../datasets/products.csv \
  --map products.sku=products.sku \
  --map products.name=products.name
```

**Project config** (`weavori.yaml`):

```yaml
generate:
  datasets:
    products: ../../datasets/products.csv
  tables:
    products:
      columns:
        sku:
          dataset: products
          dataset_column: sku
```

Precedence: **CLI flags > `weavori.yaml`**. A mapped column overrides the
matcher, FK, and distribution strategies — it is the highest-priority column
strategy.

## Rules of the road

- Values are parsed to the target column's PostgreSQL type **at plan time**.
  A bad value fails fast with the exact location:
  `dataset "products" column "sku" row 42: cannot convert "ABC-1234" to integer`.
- Without `.csv_col`, a single-column dataset maps its only column.
- Datasets are registered once and reusable across columns, runs, and projects.
