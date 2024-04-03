-- Main table with definitions:
CREATE TABLE IF NOT EXISTS definitions (
    id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL DEFAULT 0,
    word TEXT NOT NULL,
    description TEXT NOT NULL,
    author TEXT DEFAULT 'Anonymous',
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    timestamp INTEGER DEFAULT CURRENT_TIMESTAMP,
    sha3hash TEXT
);
