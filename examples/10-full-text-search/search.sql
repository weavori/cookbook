-- Recipe 10: search setup and proof.
-- 1. Build a GIN index over a tsvector expression (no tsvector column needed).
-- 2. Show the plan — with the index it must be a Bitmap Index Scan.
-- 3. Show relevance-ranked results.

CREATE INDEX IF NOT EXISTS articles_search_idx
  ON articles USING GIN (to_tsvector('english', headline || ' ' || description));

-- The plan with the index. Drop the index (DROP INDEX articles_search_idx)
-- and re-run this to see the Seq Scan the search would get without it.
EXPLAIN (ANALYZE, BUFFERS)
SELECT headline
FROM articles
WHERE to_tsvector('english', headline || ' ' || description)
      @@ plainto_tsquery('english', 'database');

-- Relevance-ranked results: ts_rank orders the best matches first.
SELECT a.headline,
       ts_rank(to_tsvector('english', a.headline || ' ' || a.description),
               plainto_tsquery('english', 'database')) AS rank
FROM articles a
WHERE to_tsvector('english', a.headline || ' ' || a.description)
      @@ plainto_tsquery('english', 'database')
ORDER BY rank DESC
LIMIT 5;
