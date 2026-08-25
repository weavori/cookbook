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
| [01](01-first-database/README.md) | First realistic database | A new app with no test data | 100% referential integrity, zero configuration |
| [02](02-prototype-without-a-db/README.md) | Prototype without a database | Demo a schema before Postgres exists | JSON/CSV generated from DDL alone |
| [03](03-migration-testing/README.md) | Migration testing | "Works in tests" — breaks in production | The UNIQUE-email migration fails on realistic data |
| [04](04-query-performance/README.md) | Query performance | A report that crawls at volume | 4.8s → 320ms with one index |
| [05](05-ecommerce-scale/README.md) | 5-million-row e-commerce | App tested on 10K orders, deployed on 5M | A production-shaped database for load tests, migrations, analytics |
| [06](06-sync-staging/README.md) | Clone prod to staging | Dump/restore gymnastics every week | FK-safe copy of real rows in minutes (Pro) |

## One database, many experiments

The real payoff: a single generated database becomes the foundation for a
whole showcase.

```text
                    ┌──→ Migration testing (03)
                    │
Schema → Weavori → Database ──→ Performance testing (04)
                    │
                    ├──→ Application testing
                    │
                    ├──→ Analytics
                    │
                    └──→ AI / MCP (mcp/)
```

Build the database once with recipe [05](05-ecommerce-scale/README.md), then
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

Reproduce from anywhere:

```bash
git clone <this-repo>
cd 05-ecommerce-scale
./generate.sh
```

## Requirements

- Weavori CLI. Authentication is required for every command except `login`,
  `version`, `subscribe`, `logout` — run `weavori login` or set
  `WEAVORI_API_KEY`.
- Docker (recipes with `docker-compose.yml`) or a local PostgreSQL 14+.
- A Pro license for `weavori sync` (recipe 06) and the MCP `sync` tool.

## Contributing

A good recipe is a good experiment:

1. State the problem in one sentence.
2. Ship the full input — no hidden setup.
3. List exact commands from a clean shell.
4. Show a measurable result (timing, row counts, failing constraint).
5. Let the reader reproduce it in under five minutes.
