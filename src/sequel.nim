## SEQUEL module
## =============
##
## This module includes easy-to-use SQL statements.
##
## This modules name is just here to trigger a good friend of mine :)

import std/[strutils, options]
import db_connector/db_sqlite
import sql/queries

const
    databaseName*: string = "database.db"

proc getDatabase(): DbConn = open(databaseName, "", "", "")

template withDatabase*(db: untyped, body: untyped) =
    let db: DbConn = getDatabase()
    db.exec(sql"BEGIN TRANSACTION")
    var success: bool = true
    try:
        body
        success = true
    except CatchableError as e:
        success = false
        echo "[Database error]: " & $e.name & ": " & e.msg & "'"
    finally:
        try:
            if success: db.exec(sql"COMMIT")
        except CatchableError:
            discard
        db.close()

proc initDatabaseTables*() =
    withDatabase db:
        db.exec(sql sqlInitTables)

proc newEntry*(word, definition: string, author: string = "") =
    withDatabase db:
        if author != "":
            db.exec(sql sqlNewEntry, word, definition, author)
        else:
            db.exec(sql sqlNewEntryAnonymous, word, definition)
