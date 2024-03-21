## SEQUEL module
## =============
##
## This module includes easy-to-use SQL statements.
##
## This modules name is just here to trigger a good friend of mine :)

import std/[options, strutils]
import db_connector/db_sqlite
import sql/queries

type
    Definition* = tuple[id: int, word, definition, author: string, upvotes, downvotes: int]

    DatabaseError* = object of ValueError
    InvalidData* = object of DatabaseError

const
    databaseName*: string = "database.db"

proc getDatabase(): DbConn =
    ## Opens the database (used only for the `withDatabase` template)
    open(databaseName, "", "", "")

template withDatabase*(db: untyped, body: untyped) =
    ## Template to avoid writing repetitive code
    ##
    ## Usage:
    ## ```
    ## withDatabase db:
    ##     db.exec(sql"DROP TABLE definitions;")
    ## ```
    runnableExamples:
        withDatabase db:
            db.exec(sql"DROP TABLE definitions;")
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
            echo "[Database error]: Failed to commit"
        db.close()

proc initDatabaseTables*() =
    ## Initialises all tables
    withDatabase db:
        db.exec(sql sqlInitTables)

proc newDefinition*(word, definition: string, author: string = "") =
    ## New entry, author field is optional
    let
        word = word.strip()
        definition = definition.strip()
        author = author.strip()

    if "" in [word, definition]:
        raise InvalidData.newException("Got an empty string while submitting new definition. Fields word and definition must not be empty!")

    withDatabase db:
        if author != "":
            db.exec(sql sqlNewEntry, word, definition, author)
        else:
            db.exec(sql sqlNewEntryAnonymous, word, definition)

proc getDefinitionById*(id: int): Option[Row] =
    ## Gets definition by their ID
    withDatabase db:
            let response: Row = db.getRow(sql sqlGetDefinitionById, id)
            if response[0] == "":
                result = none Row
            else:
                result = some response

proc getDefinitionsByName*(name: string): seq[Row] =
    ## Gets definitions by their name
    withDatabase db:
        result = db.getAllRows(sql sqlGetDefinitionsByName, name)
