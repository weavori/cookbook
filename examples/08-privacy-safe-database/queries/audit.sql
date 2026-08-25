-- PII audit. Every column flagged in schema.sql, plus three generated
-- employees so you can see what the synthetic values look like.

-- 1. The classification inventory (from COMMENT ON COLUMN ...).
SELECT a.attname                              AS column_name,
       col_description(a.attrelid, a.attnum)  AS classification
FROM pg_attribute a
WHERE a.attrelid = 'public.employees'::regclass
  AND a.attnum > 0
  AND NOT a.attisdropped
  AND col_description(a.attrelid, a.attnum) IS NOT NULL
ORDER BY a.attnum;

-- 2. Three generated employees — synthetic by construction.
SELECT first_name, last_name, email, phone, ssn, address, salary
FROM employees
LIMIT 3;
