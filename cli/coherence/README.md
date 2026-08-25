# Cross-Column Coherence

Within-row relationships that make data read as real: timelines make sense,
lifecycle states are coherent, and comparisons hold. All auto-detected from
the schema — zero configuration.

## What gets enforced

| Rule | Example | Enforcement |
|---|---|---|
| Temporal ordering | `created_at` before `updated_at`; `start_date` before `end_date` | Detected pairs are swapped when generated in the wrong order |
| Conditional nullability | `paid_at` is `NULL` unless `status = 'paid'` | Nullable `{x}_at` paired with a `status` column is `NULL` unless the status holds its terminal enum value |
| Binary CHECK constraints | `start < end`, `min <= max`, `low <= high` | Violating values swapped |

## Minimal demonstration

```sql
CREATE TABLE bookings (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  status      text NOT NULL CHECK (status IN ('confirmed', 'checked_in', 'completed', 'cancelled')),
  starts_at   timestamptz NOT NULL,
  ends_at     timestamptz NOT NULL,
  checked_in_at timestamptz,
  completed_at  timestamptz,
  CHECK (ends_at > starts_at)
);
```

```bash
weavori generate --input bookings.sql --input-format ddl --rows 100 --format csv
```

## Verify

```bash
# No impossible chronologies
SELECT count(*) FROM bookings WHERE ends_at <= starts_at;

# No "checked_in" rows without a checked_in_at timestamp
SELECT count(*) FROM bookings WHERE checked_in_at IS NOT NULL AND status NOT IN ('checked_in', 'completed');
```

Both must return `0`.

## How it's detected

1. **Temporal pairs** by column-name pattern: `{x}_at` ↔ `{x}_updated_at`,
   `created_at` ↔ `updated_at`, `started_at` ↔ `ended_at`, `began_at` ↔
   `ended_at`, `opened_at` ↔ `closed_at`, `issued_at` ↔ `due_at`,
   `start_date` ↔ `end_date`, `from_date` ↔ `to_date`.
2. **Conditional nullability** — terminal status auto-detected by preferring
   enum labels containing `paid`/`active`/`completed`/`done`; falls back to
   the first enum value.
3. **CHECK constraints** — only binary comparisons (`col1 > col2`, `>=`, `<`,
   `<=`) are enforced. Complex expressions are skipped silently (best-effort).
