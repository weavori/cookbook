# Sync (Pro)

Copy **real rows** from one PostgreSQL database to another — the complement
to generation (fresh synthetic data). Tables are synced in FK dependency
order (parents before children), so the target is referentially intact.
Pro feature; synced rows count against the monthly quota.

## Run

```bash
weavori sync "$SOURCE_DSN" --target "$TARGET_DSN"
```

Tables are created on the target first (default `--create-tables`), then
copied in dependency order over the fast COPY protocol.

## Targeted copies

```bash
# Only the public schema
weavori sync "$SOURCE_DSN" --target "$TARGET_DSN" --schema public

# Only one table (still in FK-safe order)
weavori sync "$SOURCE_DSN" --target "$TARGET_DSN" --table orders
```

## Tuning

| Flag | Default | When to change it |
|---|---|---|
| `--mode copy\|insert` | `copy` | `insert` for maximum compatibility (restrictive privileges) |
| `--batch N` | package default | Tune batch size for very large tables |
| `--create-tables` | `true` | Set `--create-tables=false` when the target schema already exists |

## Notes

- Sync copies values **unmasked** — it is a data-copy tool, not a masking
  pipeline. For masked test data, use `weavori generate` instead.
- Circular FK dependencies are detected and warned about; generation proceeds
  in the resolved order.
