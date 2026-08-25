# Formulas

Computed columns from the formula expression language (v1). Formulas are a
pure transformation layer: the underlying generator produces the row, then
formula columns are evaluated in dependency order before the row is written —
so `email` can be built from the generated `first_name`/`last_name`.

Same behavior everywhere: CLI `--formula` flags, `weavori.yaml`, and the MCP
`generate` tool all accept the same expressions.

## Function reference

| Function | Signature | Notes |
|---|---|---|
| `concat` | `concat(a, b, ...)` | Variadic, ≥1 arg. `null` args skipped. Non-string → error. |
| `lower` | `lower(s)` | Lowercase. |
| `upper` | `upper(s)` | Uppercase. |
| `trim` | `trim(s)` | Strip leading/trailing whitespace. |
| `substr` | `substr(s, start, length)` | 1-based `start`; negative/oversized clamps. |
| `coalesce` | `coalesce(a, b, ...)` | First non-null arg; all null → `null`. |
| `length` | `length(s)` | Returns an integer. |
| `replace` | `replace(s, old, new)` | Replaces **all** occurrences. |

Literals: `"..."` or `'...'` strings (escapes `\n \t \\ \" \'`), integers,
floats, negative numbers, and `null`. Function names are case-insensitive.

## Recipes

```bash
# Full name from parts
--formula 'full_name=concat(first_name, " ", last_name)'

# Lowercased email, composed from two columns
--formula 'email=lower(concat(first_name, ".", last_name, "@corp.io"))'

# URL slug from a title ("Hello World" -> "hello-world")
--formula 'slug=lower(replace(title, " ", "-"))'

# Fallback when a column may be null
--formula 'label=coalesce(display_name, full_name)'

# Truncate to a fixed length
--formula 'short_code=upper(substr(tracking_id, 1, 8))'

# Strip surrounding whitespace (e.g. imported columns)
--formula 'clean_sku=trim(sku)'
```

Formulas can reference other formula columns, so derived values build in
layers:

```bash
--formula 'username=lower(concat(first_name, ".", last_name))' \
--formula 'email=concat(username, "@corp.io")'
```

## Project config

```yaml
generate:
  tables:
    customers:
      columns:
        email:
          formula: "lower(concat(first_name, '.', last_name, '@corp.io'))"
```

Precedence: **CLI flags > `weavori.yaml`**. CLI and MCP both merge config
formulas in, with inline input winning on duplicates.

## Fail-fast guarantees

At plan time, before any row is generated: unknown column references, unknown
functions, wrong argument counts, dependency cycles, and duplicate definitions
all fail with a precise error. Runtime type mismatches abort the run — no
silent value substitution.

## Deliberate exclusions (v1)

No arithmetic (`+ - * /`), comparisons, conditionals, regex, or hashing.
`--formula 'total=quantity*price'` fails with `parse error: unexpected token`.
Pre-calculate derived values in the source or use a dataset instead.
