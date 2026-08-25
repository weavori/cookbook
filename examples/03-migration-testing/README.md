# Recipe 03 — Migration Testing

**Problem.** "It works in tests" — but the migration breaks in production,
because the test data never looked like real data.

**Result.** A UNIQUE-constraint migration that succeeds against hand-written
fixtures fails against realistic synthetic data, with the exact offending rows
identified.

## 1. Problem

Your team ships `ALTER TABLE customers ADD CONSTRAINT customers_email_key
UNIQUE (email)` — "verified" against three hand-written customers. In
production, it fails: real apps have two John Smiths, and `john.smith@example.com`
is not unique.

## 2. Schema

[`schema.sql`](schema.sql): `customers` + `orders`. Nothing exotic.

## 3. How the data should look

- 100,000 customers (change with `ROWS=... ./generate.sh`).
- Emails **derived from names** via the formula in
  [`weavori.yaml`](weavori.yaml) — exactly what a real signup flow does when
  it suggests `first.last@example.com`.
- That one decision is the whole trick: common names collide at scale.

## 4. Run

```bash
./generate.sh
```

The script prints the smoking gun at the end — how many duplicate emails the
realistic data contains.

## 5. The database

100,000 customers with realistic names and derived emails — including the
duplicates that hand-written fixtures never had.

## 6. Use it — run the migration

```bash
docker compose exec -T target psql -U weavori -d target -f migration.sql
```

## 7. Prove it

The migration **fails**. Quantify why:

```sql
-- How many rows carry a duplicated email?
SELECT count(*) - count(DISTINCT email) AS duplicate_rows FROM customers;

-- The offenders
SELECT email, count(*) AS n
FROM customers
GROUP BY email
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 5;
```

At 100,000 customers expect **thousands** of duplicate emails (the exact count
is reproducible on your machine). This is the proof: a constraint your
hand-written tests blessed would have failed on day one in production.

**The fix** — either de-duplicate, or admit the assumption:

```sql
-- De-duplicate: append +1, +2, ... to later duplicates
UPDATE customers c
SET email = c.email || '+' || d.rn
FROM (
  SELECT id, row_number() OVER (PARTITION BY email ORDER BY id) - 1 AS rn
  FROM customers
) d
WHERE c.id = d.id AND d.rn > 0;
```

...or keep the constraint off `email` entirely and use a real unique
identifier (`username`). That discussion is exactly the one you want to have
*before* the migration, not after a production incident.

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/03-migration-testing
./generate.sh
docker compose exec -T target psql -U weavori -d target -f migration.sql
```

**Windows:** run the scripts via Git Bash or WSL (see the root README's
Platform support section).

**Why this works**: Weavori generates realistic names from real name
distributions — collisions are a property of the *data*, not of the tool.
Hand-written test data is an argument for your assumptions; realistic data is
a test of them.
