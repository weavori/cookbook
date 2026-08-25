# Weavori Cookbook

A **developer laboratory**. Every recipe starts from a real developer problem,
builds a realistic PostgreSQL database with Weavori, runs an experiment
against it, and proves a result you can reproduce on your own machine.

## The recipe loop

```text
1. Problem     →  a real developer pain point
2. Schema      →  a realistic PostgreSQL schema
3. Data        →  how the data should look (row counts, distributions, formulas, datasets)
4. Run         →  one Weavori command
5. Database    →  referentially intact, distribution-shaped synthetic data
6. Use         →  tests, queries, migrations, benchmarks, analytics
7. Prove       →  a measurable result
8. Reproduce   →  everything needed ships in the recipe directory
```

## Recipes

| # | Recipe | Problem | Result it proves |
|---|---|---|---|
| [01](examples/01-first-database/README.md) | First realistic database | A new app with no test data | 100% referential integrity, zero configuration |
| [02](examples/02-prototype-without-a-db/README.md) | Prototype without a database | Demo a schema before Postgres exists | JSON/CSV generated from DDL alone |
| [03](examples/03-migration-testing/README.md) | Migration testing | "Works in tests" — breaks in production | The UNIQUE-email migration fails on realistic data |
| [04](examples/04-query-performance/README.md) | Query performance | A report that crawls at volume | 4.8s → 320ms with one index |
| [05](examples/05-ecommerce-scale/README.md) | 5-million-row e-commerce | App tested on 10K orders, deployed on 5M | A production-shaped database for load tests, migrations, analytics |
| [06](examples/06-sync-staging/README.md) | Clone prod to staging | Dump/restore gymnastics every week | FK-safe copy of real rows in minutes (Pro) |
| [07](examples/07-analytics-star-schema/README.md) | Analytics star schema | The dashboard works on 3 hand-written rows | Revenue rollups that actually join and aggregate |
| [08](examples/08-privacy-safe-database/README.md) | Privacy-safe database | Staging must not contain real PII | PII-free by construction, with a queryable audit |
| [09](examples/09-ci-ephemeral-database/README.md) | Ephemeral DB in CI | Fixtures prove nothing in pipelines | Fresh realistic data + assertions on every push |
| [10](examples/10-full-text-search/README.md) | Full-text search at volume | Search quality needs a realistic corpus | 100k docs, GIN-indexed, relevance-ranked |

## One database, many experiments

The real payoff: a single generated database becomes the foundation for a
whole showcase.

```text
                    ┌──→ Migration testing (03)
                    │
Schema → Weavori → Database ──→ Performance testing (04)
                    │
                    ├──→ Application testing (01)
                    │
                    ├──→ Analytics (07)
                    │
                    ├──→ Search (10)
                    │
                    └──→ AI / MCP (mcp/)
```

Build the database once with recipe [05](examples/05-ecommerce-scale/README.md), then
run any experiment against it — or clone the experiment's own directory, which
is always self-contained.

## Building blocks

| Section | What it holds |
|---|---|
| [formulas/](formulas/README.md) | The expression-language reference used in step 3 (Configuring the data) |
| [mcp/](mcp/README.md) | AI-assistant workflows that drive generation and use the databases |

## Anatomy of a recipe

Every numbered directory is self-contained and ships everything the
experiment needs:

```text
README.md           # the 8-step narrative: problem → ... → reproduce
schema.sql          # the realistic schema
weavori.yaml        # how the data should look (formulas, datasets)
generate.sh         # one script: database up → Weavori → ready
docker-compose.yml  # source + target Postgres on fixed ports (DB-backed recipes)
```

Recipes may also ship `queries/*.sql` (the experiment's SQL), CSV datasets,
or `.github/workflows/` — anything the experiment needs.

Reproduce from anywhere:

```bash
git clone <this-repo>
cd examples/05-ecommerce-scale
./generate.sh
```

## Requirements

- Weavori CLI. Authentication is required for every command except `login`,
  `version`, `subscribe`, `logout` — run `weavori login` or set
  `WEAVORI_API_KEY`.
- Docker (recipes with `docker-compose.yml`) or a local PostgreSQL 14+.
- A Pro license for `weavori sync` (recipe 06) and the MCP `sync` tool.

## Platform support

All recipes work on Linux, macOS, and Windows.

- **Linux / macOS** — run `./generate.sh` directly (bash + Docker).
- **Windows** — use **Git Bash** (ships with Git for Windows) or **WSL**;
  the scripts are plain bash. Or run the commands from a recipe's README
  manually in PowerShell — the underlying tools (`weavori`, `docker
  compose`, `psql`) are all Windows-native.
- Line endings are normalized by `.gitattributes`, so scripts never break on
  CRLF checkouts.

## Contributing

A good recipe is a good experiment:

1. State the problem in one sentence.
2. Ship the full input — no hidden setup.
3. List exact commands from a clean shell.
4. Show a measurable result (timing, row counts, failing constraint).
5. Let the reader reproduce it in under five minutes.
