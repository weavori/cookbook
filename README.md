# Weavori Cookbook

This repo contains small examples for building with Weavori.

[Weavori](https://github.com/weavori/weavori) is a zero-config PostgreSQL synthetic data CLI. Point it at any Postgres database and it introspects the schema, resolves foreign key dependencies, and produces referentially intact synthetic data that looks and behaves like your production data — no configuration required.

## Recipes

Every example is self-contained: copy the directory, run the commands, done.

### CLI recipes (`cli/`)

| Example | What it shows |
|---|---|
| [quickstart](cli/quickstart/README.md) | First end-to-end run: introspect → plan → generate into a target database |
| [ecommerce](cli/ecommerce/README.md) | Flagship: foreign keys, enums, datasets, formulas, cross-column coherence |
| [ddl-paste-mode](cli/ddl-paste-mode/README.md) | Zero-database generation from pasted `CREATE TABLE` statements |
| [formulas](cli/formulas/README.md) | Computed columns from the expression language |
| [coherence](cli/coherence/README.md) | Temporal ordering, conditional nullability, CHECK constraints |
| [estimate](cli/estimate/README.md) | Pre-flight planning without generating a single row |
| [sync](cli/sync/README.md) | Copy real rows between databases in FK-safe order (Pro) |

### Building blocks

| Section | What it holds |
|---|---|
| [datasets/](datasets/README.md) | Reusable CSV value sets — bring your own vocabulary |
| [formulas/](formulas/README.md) | Expression patterns to copy into `--formula` |

### AI & automation (`mcp/`)

| Example | What it shows |
|---|---|
| [quickstart](mcp/quickstart/README.md) | An AI assistant drives introspect → generate over `weavori mcp` |
| [overview](mcp/README.md) | Exposed tools and how to wire Weavori into an assistant |

## Requirements

- Weavori CLI. Authentication is required for every command (except `login`, `version`, `subscribe`, `logout`) — run `weavori login` or set `WEAVORI_API_KEY`.
- PostgreSQL 14+ for the database-backed recipes.
- A Pro license for `weavori sync` (the MCP `sync` tool is Pro-only too).

## Contributing

Each example is one self-contained directory with its own `README.md`. A good example:

1. Ships the full input (schema SQL, datasets, config) — no hidden setup.
2. Lists exact commands from a clean shell.
3. Notes what the output should look like.
4. Avoids depending on another example's files.
