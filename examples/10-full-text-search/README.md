# Recipe 10 — Full-Text Search at Volume

**Problem.** Search "works" on three test rows and returns garbage at scale —
because relevance only exists with a realistic corpus.

**Result.** A 100,000-article corpus (change with `ROWS`) generated in one
command, a GIN index that flips the plan from Seq Scan to Bitmap Index Scan,
and relevance-ranked results via `ts_rank`.

## 1. Problem

Full-text search has two failure modes that tiny fixtures hide: the query
plan (without an index, every search is a full scan) and relevance (ranking
only means something when there are hundreds of plausible matches). Both need
a corpus with real words, in volume.

## 2. Schema

[`schema.sql`](schema.sql): `authors` + `articles` — headline, description,
published state. No `tsvector` column: the index is built on an expression,
so the table stays a plain, portable schema.

## 3. How the data should look

- 100,000 articles, each with a generated headline and description.
- **Zero configuration needed**: the semantic matcher already knows
  `headline` → sentence and `description` → paragraph, so every document has
  real words a search can match.

## 4. Run

```bash
./generate.sh                          # 100,000 articles by default
```

## 5. Get the database

A referentially intact authors/articles database. `headline` holds a full
sentence; `description` holds a multi-sentence paragraph — every row is
searchable text.

## 6. Use the database

```bash
docker compose exec -T target psql -U weavori -d target < search.sql
```

`search.sql` builds the GIN index, explains the search plan, and returns the
top-ranked hits for "database".

## 7. Prove the result

```text
 Index Scan using articles_search_idx ...
   ->  Bitmap Index Scan on articles_search_idx
         Index Cond: (to_tsvector('english', ...) @@ plainto_tsquery(...))

 headline                          |  rank
-----------------------------------+---------
 "Database ... improves ..."       | 0.071
 "A field guide to ... databases"  | 0.052
 ...
```

Drop the index and re-run the `EXPLAIN` — the plan becomes a Seq Scan. That's
the whole experiment: search correctness *and* performance depend on a corpus
and an index, and now you can test both.

## 8. Reproduce

```bash
git clone <this-repo>
cd examples/10-full-text-search
./generate.sh
```

**Notes**

- **Windows:** run `./generate.sh` via Git Bash or WSL (see the root README's
  Platform support section).
- Swap `plainto_tsquery` for `websearch_to_tsquery` to test user-style query
  syntax (quotes, `-excluded` terms).
