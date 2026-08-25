-- Recipe 05: the 5-million-row e-commerce database.
-- A production-shaped schema: FK chains, an enum, temporal columns,
-- conditional nullability, CHECK constraints.

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

CREATE TABLE payments (
  id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id bigint NOT NULL REFERENCES orders (id),
  amount   numeric(10, 2) NOT NULL CHECK (amount >= 0),
  method   text NOT NULL CHECK (method IN ('card', 'paypal', 'bank_transfer', 'crypto')),
  paid_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE shipments (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id         bigint NOT NULL REFERENCES orders (id),
  carrier          text NOT NULL,
  tracking_number  text NOT NULL,
  shipped_at       timestamptz,
  delivered_at     timestamptz,
  CHECK (delivered_at IS NULL OR delivered_at >= shipped_at)
);

CREATE TABLE reviews (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id  bigint NOT NULL REFERENCES products (id),
  customer_id bigint NOT NULL REFERENCES customers (id),
  rating      integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title       text,
  body        text,
  created_at  timestamptz NOT NULL DEFAULT now()
);
