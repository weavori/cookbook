-- Recipe 08: a privacy-safe development database.
-- PII and sensitive columns are marked with COMMENTs so the audit query
-- can enumerate them. Weavori generates every value synthetically, so the
-- database contains no real identity data by construction.

CREATE TABLE departments (
  id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name   text NOT NULL UNIQUE,
  budget numeric(12, 2) NOT NULL CHECK (budget >= 0)
);

CREATE TABLE employees (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  department_id bigint NOT NULL REFERENCES departments (id),
  first_name    text NOT NULL,
  last_name     text NOT NULL,
  email         text NOT NULL,
  phone         text NOT NULL,
  ssn           text NOT NULL,
  address       text NOT NULL,
  salary        numeric(10, 2) NOT NULL CHECK (salary >= 0),
  hire_date     date NOT NULL,
  is_active     boolean NOT NULL DEFAULT true
);

COMMENT ON COLUMN employees.first_name IS 'PII';
COMMENT ON COLUMN employees.last_name IS 'PII';
COMMENT ON COLUMN employees.email IS 'PII';
COMMENT ON COLUMN employees.phone IS 'PII';
COMMENT ON COLUMN employees.ssn IS 'PII';
COMMENT ON COLUMN employees.address IS 'PII';
COMMENT ON COLUMN employees.salary IS 'SENSITIVE';
