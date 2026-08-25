-- Recipe 10: full-text search at realistic volume.
-- Search quality is only testable on a realistic corpus: thousands of
-- documents with real words, not three hand-written rows.

CREATE TABLE authors (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL
);

CREATE TABLE articles (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  author_id    bigint NOT NULL REFERENCES authors (id),
  headline     text NOT NULL,
  description  text NOT NULL,
  is_published boolean NOT NULL DEFAULT true,
  published_at timestamptz NOT NULL DEFAULT now()
);
