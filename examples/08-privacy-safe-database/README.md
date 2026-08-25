# Recipe 08 — Privacy-Safe Development Database

**Problem.** Staging and vendor-shared databases must not contain real identity
data — but masking pipelines are expensive and often forbidden by policy
entirely.

**Result.** An employees database where **every PII value is synthetic by
construction** — generated, never copied — with a queryable audit trail of
which columns are PII, and referential integrity intact.

## 1. Problem

"Use anonymized production data" sounds easy until legal says no, or the
anonymization breaks the relationships your tests depend on. The alternative
that sidesteps the whole debate: a database that *behaves* like production but
**contains nothing real**. No masking step, no copy step — nothing to leak.

## 2. Schema

[`schema.sql`](schema.sql): `departments` + `employees`. Every identity column
is marked with `COMMENT ON COLUMN ... IS 'PII'` (salary is `'SENSITIVE'`) so
the classification lives with the schema, where the audit can find it.

## 3. How the data should look

- Emails are **derived** from the generated names
  ([`weavori.yaml`](weavori.yaml)) — `john.smith@example.com`, never a real
  address.
- SSNs, phone numbers, and addresses come from the semantic matcher's
  format generators — valid shape, zero real identity.
- Department names come from your own value set
  ([`departments.csv`](departments.csv)).

## 4. Run

```bash
./generate.sh                          # 10,000 employees by default
ROWS=100000 ./generate.sh              # or scale up
```

## 5. Get the database

A referentially intact employees database. Every row is synthetic — there is
nothing in it that can be traced back to a real person.

## 6. Use the database

```bash
docker compose exec -T target psql -U weavori -d target < queries/audit.sql
```

## 7. Prove the result

```text
 column_name | classification
-------------+---------------
 first_name  | PII
 last_name   | PII
 email       | PII
 phone       | PII
 ssn         | PII
 address     | PII
 salary      | SENSITIVE

 first_name | last_name | email                 | phone      | ssn        | ...
------------+-----------+-----------------------+------------+------------+----
 Ava        | Martin    | ava.martin@example.com | 574-...    | 533-...    | ...
 ...
```

And the sanity check in `generate.sh` reports `emails_not_derived = 0` — every
email matches the derived pattern, so none of them can be a real address.

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/08-privacy-safe-database
./generate.sh
```

**Notes**

- **Windows:** run `./generate.sh` via Git Bash or WSL (see the root README's
  Platform support section).
- When you *do* need production's exact edge cases preserved (specific
  pathological rows, real correlations), the complementary tool is
  [recipe 06](../06-sync-staging/README.md) — copy + mask. This recipe is the
  "nothing real, ever" alternative.
