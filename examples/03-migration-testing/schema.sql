-- Recipe 03: migration testing.
-- The experiment: "make customer emails unique" works on hand-written test
-- data, but realistic data has duplicate emails (two John Smiths).

CREATE TABLE customers (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL,
  email      text NOT NULL,
  country    text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id bigint NOT NULL REFERENCES customers (id),
  total       numeric(10, 2) NOT NULL CHECK (total >= 0),
  placed_at   timestamptz NOT NULL DEFAULT now()
);
