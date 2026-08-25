-- Recipe 02: prototype without a database.
-- Weavori parses these CREATE TABLE statements and generates to stdout —
-- no Postgres involved.

CREATE TABLE users (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name    text NOT NULL,
  last_name     text NOT NULL,
  email         text NOT NULL,
  role          text NOT NULL CHECK (role IN ('admin', 'member', 'viewer')),
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  last_login_at timestamptz
);

CREATE TABLE projects (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  owner_id    bigint NOT NULL REFERENCES users (id),
  name        text NOT NULL,
  description text,
  visibility  text NOT NULL CHECK (visibility IN ('private', 'public')),
  created_at  timestamptz NOT NULL DEFAULT now()
);
