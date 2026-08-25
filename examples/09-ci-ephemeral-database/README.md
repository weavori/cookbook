# Recipe 09 — Ephemeral Database in CI

**Problem.** Your pipeline has run against the same three hand-written fixture
rows for a year. It passes every time — and proves nothing.

**Result.** A GitHub Actions workflow that spins up fresh Postgres, generates a
realistic database with Weavori (CI mode, `WEAVORI_API_KEY`), and asserts
referential integrity and formula output — on every push. Plus the identical
pipeline to run locally.

## 1. Problem

Hand-written fixtures are constant — so they never catch what changes: a new
column that breaks inserts, a formula that stops deriving correctly, an FK
that now points nowhere. CI needs *fresh, realistic data on every run*, and
that data needs to be cheap enough to throw away.

## 2. Schema

[`schema.sql`](schema.sql): `users` + `projects` — a foreign key, role and
visibility CHECKs, and a derived email. Enough structure that the assertions
are meaningful.

## 3. How the data should look

- 1,000 rows per table (change `--rows` in the workflow).
- Emails derived from names via `--formula` — the pipeline asserts the
  derivation still holds, so a broken formula fails the build.

## 4. Run (CI)

1. Copy [`schema.sql`](schema.sql), [`verify.sql`](verify.sql), and
   [`.github/workflows/ci.yml`](.github/workflows/ci.yml) into your repo root.
2. Add `WEAVORI_API_KEY` as a **repository secret** (GitHub → Settings →
   Secrets). CI mode authenticates via the key — no interactive login.
3. Push. The `weavori-ci-demo` workflow runs the pipeline.

## 5. Run (locally)

```bash
./generate.sh                          # same pipeline, Docker, logged-in CLI
```

## 6. The pipeline

```text
fresh Postgres (2 service containers)
        ↓
weavori generate  source → target       (CI mode: WEAVORI_API_KEY)
        ↓
psql -v ON_ERROR_STOP=1 -f verify.sql  (assertions)
```

## 7. Prove the result

The workflow's "Run assertions" step prints:

```text
NOTICE:  OK: users=1000, projects=1000, referential integrity intact, all emails derived
```

If any table is empty, any project references a missing owner, or any email
stops matching the derived pattern, the job **fails** — loudly, on every push.

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/09-ci-ephemeral-database
./generate.sh                          # local run — no CI needed
```

**Notes**

- **Windows:** run `./generate.sh` via Git Bash or WSL (see the root README's
  Platform support section).
- The workflow pins the `postgres:16-alpine` service containers and installs
  Weavori from the official installer (`curl -fsS https://weavori.com/install
  | bash`).
