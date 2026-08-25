# MCP Quickstart

An AI assistant builds your test data in one conversation: describe what you
want, and the assistant drives the same engine the CLI uses.

## Prerequisites

- `weavori` installed and authenticated (`weavori login` or `WEAVORI_API_KEY`).
- The MCP server wired into your assistant (see [mcp/README.md](../README.md)).
- A source database with the [quickstart schema](../../cli/quickstart/schema.sql)
  applied, and an empty target database.

## The conversation

**You:**

> Introspect `postgres://localhost/weavori_demo_source`, then generate 1,000
> rows per table into `postgres://localhost/weavori_demo_target`. Derive the
> email column with a formula: lowercase `first_name.last_name@example.com`.

**Assistant:** calls `introspect` on the source DSN →

```json
{
  "schemas": [
    {
      "name": "public",
      "tables": ["customers", "orders"]
    }
  ]
}
```

**Assistant:** calls `generate` with the target DSN and the formula →

```json
{
  "dsn": "postgres://localhost/weavori_demo_target",
  "rows": 1000,
  "formulas": {
    "email": "lower(concat(first_name, '.', last_name, '@example.com'))"
  }
}
```

**Assistant:** streams progress per table (generation order is FK-safe —
`customers` before `orders`), then reports:

> Generated 1,000 rows into `customers` and 1,000 rows into `orders`.
> Every `orders.customer_id` references a real generated customer.

## What the assistant knew automatically

- **FK ordering** — parents generate before children; child FK values are
  copied from generated parents (referential integrity by construction).
- **The formula engine** — `email` is a computed column on top of the
  generated row; validation happens at plan time, not row 50,000.
- **Skipped columns** — `created_at` keeps its `now()` default; no value is
  generated for it.

## Try the full workflow

Ask the assistant to run the whole loop: `introspect` → `estimate` →
`doctor` → `generate`. Each tool shares the same schema knowledge, so the
assistant can reason about the plan before a single row is written.
