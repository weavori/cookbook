-- Assertions for the CI pipeline. Each DO block raises when a check fails;
-- psql runs with ON_ERROR_STOP so the job fails loudly.

DO $$
DECLARE
  n_users    integer;
  n_projects integer;
  orphans    integer;
  bad_emails integer;
BEGIN
  SELECT count(*) INTO n_users    FROM users;
  SELECT count(*) INTO n_projects FROM projects;
  SELECT count(*) INTO orphans
  FROM projects p LEFT JOIN users u ON u.id = p.owner_id
  WHERE u.id IS NULL;
  SELECT count(*) INTO bad_emails
  FROM users WHERE email !~ '@example\.com$' OR email <> lower(email);

  IF n_users = 0 OR n_projects = 0 THEN
    RAISE EXCEPTION 'tables empty: users=%, projects=%', n_users, n_projects;
  END IF;
  IF orphans > 0 THEN
    RAISE EXCEPTION '% project(s) reference missing owners', orphans;
  END IF;
  IF bad_emails > 0 THEN
    RAISE EXCEPTION '% email(s) not derived from the formula', bad_emails;
  END IF;

  RAISE NOTICE 'OK: users=%, projects=%, referential integrity intact, all emails derived', n_users, n_projects;
END $$;
