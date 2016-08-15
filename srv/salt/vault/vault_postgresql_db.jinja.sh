#!/bin/sh

psql -w \
    -U {{pillar['vault']['postgres']['dbuser']}} \
    -h 127.0.0.1 \
    -p 5432 \
    {{pillar['vault']['postgres']['dbname']}} <<EOT

CREATE TABLE IF NOT EXISTS vault_kv_store (
  parent_path TEXT COLLATE "C" NOT NULL,
  path        TEXT COLLATE "C",
  key         TEXT COLLATE "C",
  value       BYTEA,
  CONSTRAINT pkey PRIMARY KEY (path, key)
);

CREATE INDEX IF NOT EXISTS parent_path_idx ON vault_kv_store (parent_path);

EOT
