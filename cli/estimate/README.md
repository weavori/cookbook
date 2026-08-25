# Estimate

Pre-flight analysis: report expected generation time **before** you generate
anything. Reads `pg_stat_user_tables` row counts and applies a throughput
heuristic — no rows are written.

## Run

```bash
weavori estimate "$SOURCE_DSN"
```

## When to use it

- Planning a big run: will 50M rows finish in the CI time budget?
- Comparing schemas: which database costs more to replicate?
- Deciding `--rows` per table before committing to a run.

## What it reports

Per-table source row counts and an estimated total generation time. The
estimate is a heuristic, not a promise — but it costs nothing and touches no
data.

## Pair it with the plan preview

`weavori generate` (without `--yes`) shows the interactive generation plan
before anything is written: table list, generation order, per-table row
counts, and trigger-skipped columns. `estimate` answers "how long?"; the
preview answers "what exactly?" — use both before a production-shaped run.
