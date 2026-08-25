-- Quickstart schema: a minimal two-table database with a foreign key.
-- Apply this to a source database, then let Weavori introspect it.

CREATE TABLE customers (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL,
  email      text NOT NULL,
  country    text NOT NULL,
  is_active  boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id bigint NOT NULL REFERENCES customers (id),
  status      text NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled')),
  total       numeric(10, 2) NOT NULL CHECK (total >= 0),
  placed_at   timestamptz NOT NULL DEFAULT now(),
  paid_at     timestamptz
);
