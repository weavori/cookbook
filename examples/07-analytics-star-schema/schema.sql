-- Recipe 07: analytics star schema.
-- Dims (categories, products, customers) + one fact table (fact_sales).
-- The classic BI shape: rollups join facts to dims on surrogate keys.

CREATE TABLE categories (
  id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE,
  slug text NOT NULL
);

CREATE TABLE products (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_id bigint NOT NULL REFERENCES categories (id),
  name        text NOT NULL,
  price       numeric(10, 2) NOT NULL CHECK (price >= 0),
  is_active   boolean NOT NULL DEFAULT true
);

CREATE TABLE customers (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL,
  email      text NOT NULL,
  country    text NOT NULL,
  segment    text NOT NULL,
  joined_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE fact_sales (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id bigint NOT NULL REFERENCES customers (id),
  product_id  bigint NOT NULL REFERENCES products (id),
  quantity    integer NOT NULL CHECK (quantity > 0),
  unit_price  numeric(10, 2) NOT NULL CHECK (unit_price >= 0),
  total       numeric(12, 2) NOT NULL CHECK (total >= 0),
  sold_at     timestamptz NOT NULL DEFAULT now()
);
