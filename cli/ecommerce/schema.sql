-- Flagship example: an e-commerce database exercising most of Weavori's
-- feature surface at once — foreign keys, enum types, CHECK constraints,
-- temporal ordering, and conditional nullability.
--
-- Apply this to a source database, then see README.md for the generate recipe.

CREATE TYPE order_status AS ENUM ('pending', 'paid', 'shipped', 'delivered', 'cancelled');

CREATE TABLE categories (
  id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE,
  slug text NOT NULL
);

CREATE TABLE products (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_id bigint NOT NULL REFERENCES categories (id),
  name        text NOT NULL,
  sku         text NOT NULL UNIQUE,
  price       numeric(10, 2) NOT NULL CHECK (price >= 0),
  is_active   boolean NOT NULL DEFAULT true
);

CREATE TABLE customers (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL,
  email      text NOT NULL,
  country    text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  bigint NOT NULL REFERENCES customers (id),
  status       order_status NOT NULL DEFAULT 'pending',
  total        numeric(10, 2) NOT NULL CHECK (total >= 0),
  placed_at    timestamptz NOT NULL,
  paid_at      timestamptz,
  shipped_at   timestamptz,
  delivered_at timestamptz,
  CHECK (paid_at IS NULL OR paid_at >= placed_at),
  CHECK (shipped_at IS NULL OR shipped_at >= paid_at),
  CHECK (delivered_at IS NULL OR delivered_at >= shipped_at)
);

CREATE TABLE order_items (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id   bigint NOT NULL REFERENCES orders (id),
  product_id bigint NOT NULL REFERENCES products (id),
  quantity   integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(10, 2) NOT NULL CHECK (unit_price >= 0)
);
