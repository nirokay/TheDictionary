-- Main table with definitions:
CREATE TABLE IF NOT EXISTS definitions (
    id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL DEFAULT 0,
    word TEXT NOT NULL,
    description TEXT NOT NULL,
    author TEXT DEFAULT 'Anonymous',
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    timestamp INTEGER DEFAULT CURRENT_TIMESTAMP
);

-- Secondary hashes table (makes it easier to not post the same definition twice):
CREATE TABLE IF NOT EXISTS hashes (
    hash TEXT PRIMARY KEY UNIQUE NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
