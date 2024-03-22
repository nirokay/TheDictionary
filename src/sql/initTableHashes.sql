-- Secondary hashes table (makes it easier to not post the same definition twice):
CREATE TABLE IF NOT EXISTS hashes (
    hash TEXT PRIMARY KEY UNIQUE NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
