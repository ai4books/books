-- Clean fixture: a column literally named api_key, with no value in the file.
-- The value lives in the vault, not in source, so a scanner finds nothing.
CREATE TABLE integrations (
  id          BIGINT PRIMARY KEY,
  api_key     TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);
