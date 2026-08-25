# DDL Paste Mode

Generate synthetic data with **no database at all**: point Weavori at a
`CREATE TABLE` file (or stdin), and data streams to stdout as JSON or CSV.
Perfect for prototyping, CI fixtures, and demos.

## From a file

```bash
weavori generate --input schema.sql --input-format ddl --rows 100 --format json
```

## From stdin

```bash
cat schema.sql | weavori generate --stdin --input-format ddl --format csv
```

## With formulas and datasets

Everything from standard mode works in paste mode — FK-aware generation,
formulas, datasets, and cross-column enforcement:

```bash
weavori generate --input schema.sql --input-format ddl --rows 50 --format json \
  --formula 'email=lower(concat(first_name, ".", last_name, "@corp.io"))' \
  --dataset countries=../../datasets/countries.csv \
  --map users.country=countries
```

## What differs from standard mode

- **No distribution sampling** — there is no source database to sample.
- **No target schema creation** — output goes to stdout only; nothing is
  written anywhere (CI-safe, side-effect free).
- Everything else is identical: the matcher, FK order, formulas, datasets,
  and cross-column coherence all behave the same.

## Notes

- `--format` accepts `json` (default) or `csv`.
- `--rows` is per table.
- Authentication is still required (ADR 0033): `weavori login` or
  `WEAVORI_API_KEY`.
