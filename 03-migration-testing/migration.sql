-- The migration under test. It assumes every customer email is unique:
-- "This is what our tests showed, and production has the same data, right?"

ALTER TABLE customers
  ADD CONSTRAINT customers_email_key UNIQUE (email);
