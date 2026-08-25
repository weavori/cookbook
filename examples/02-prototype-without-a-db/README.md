# Recipe 02 — Prototype Without a Database

**Problem.** You're designing a schema and want to demo it — but the database
doesn't exist yet, and you don't want to stand one up to look at data.

**Result.** Realistic JSON streamed to stdout, straight from `CREATE TABLE`
statements. No Postgres. No target database. Nothing written anywhere.

## 1. Problem

Schema reviews work better with data in front of you. Standing up Postgres,
creating tables, and hand-inserting rows just to look at a design is
expensive — and it's exactly the friction you want to remove from a demo.

## 2. Schema

[`schema.sql`](schema.sql): a two-table app schema — users, projects, a
foreign key, role/visibility CHECKs, a `now()` default.

## 3. How the data should look

- 20 users, 20 projects (change with `ROWS=... ./generate.sh`).
- Emails derived from names via the formula in `--formula` (see below).
- Everything else from the semantic matcher: names, roles, visibility,
  timestamps.

## 4. Run

```bash
./generate.sh
```

which runs:

```bash
weavori generate --input schema.sql --input-format ddl --rows 20 --format json \
  --formula 'email=lower(concat(first_name, ".", last_name, "@corp.io"))'
```

From stdin, the same thing:

```bash
cat schema.sql | weavori generate --stdin --input-format ddl --format csv
```

## 5. The output

A stream of rows where every `projects.owner_id` references a real generated
user (FK resolution works across the parsed tables), and emails look like
`jane.doe@corp.io`:

```json
{"id":1,"first_name":"Jane","last_name":"Doe","email":"jane.doe@corp.io","role":"member","is_active":true}
```

## 6. Use it

```bash
# Inspect the shape of the data
./generate.sh | jq -r '.role' | sort | uniq -c

# Load into a scratch tool for a demo
./generate.sh > sample.json
```

## 7. Prove it

Because output is **side-effect free**, this is CI-safe by construction:

```bash
# A one-liner that fails the build if any project references a missing user
./generate.sh | jq -s 'group_by(.owner_id) | length' >/dev/null && echo "referentially intact"
```

Nothing is written to disk unless you redirect it — the same command is safe
in a demo, a CI pipeline, or a code review.

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/02-prototype-without-a-db
./generate.sh
```

**Notes**

- **Windows:** run `./generate.sh` via Git Bash or WSL — or copy the command
  below into PowerShell directly (no scripts needed for this recipe).
- Paste mode has no distribution sampling (no source database) — every other
  feature works identically: formulas, datasets, FK order, cross-column
  coherence.
- Authentication is still required (ADR 0033): `weavori login` or
  `WEAVORI_API_KEY`.
