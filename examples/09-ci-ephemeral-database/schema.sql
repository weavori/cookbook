-- Recipe 09: the schema the CI pipeline generates into.
-- Two tables with a foreign key and a derived email, so the pipeline can
-- assert referential integrity and formula output, not just row counts.

CREATE TABLE users (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL,
  email      text NOT NULL,
  role       text NOT NULL CHECK (role IN ('admin', 'member', 'viewer')),
  is_active  boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE projects (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  owner_id    bigint NOT NULL REFERENCES users (id),
  name        text NOT NULL,
  description text,
  visibility  text NOT NULL CHECK (visibility IN ('private', 'public')),
  created_at  timestamptz NOT NULL DEFAULT now()
);
