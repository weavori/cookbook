# MCP

`weavori mcp` starts a Model Context Protocol server over stdio — the same
battle-tested generation engine, exposed as tools an AI assistant can call
directly. No scripting, no shell commands: an assistant introspects a schema,
estimates, generates, or syncs inside a conversation.

## Exposed tools

| Tool | Purpose |
|---|---|
| `introspect` | Introspect a PostgreSQL database schema |
| `estimate` | Estimate generation time and cost |
| `generate` | Generate synthetic data into a target database |
| `doctor` | Run comprehensive diagnostics |
| `sync` | Copy data from one database to another (Pro-only) |

Semantics are identical to the CLI: formulas, datasets, FK-aware generation,
quota/license enforcement, and error codes all apply to MCP runs.

## Start it

```bash
weavori mcp
```

## Wire it into an assistant

Add a stdio MCP server entry pointing at the `weavori` binary (or the
`weavori mcp` invocation) in your assistant's MCP configuration:

```json
{
  "mcpServers": {
    "weavori": {
      "command": "weavori",
      "args": ["mcp"]
    }
  }
}
```

Authentication is resolved from the CLI's cached session or
`WEAVORI_API_KEY` — the MCP server never opens a browser or consults the OS
keyring.

## Examples

| Example | What it shows |
|---|---|
| [quickstart](quickstart/README.md) | An assistant drives introspect → generate, with formulas, end to end |
