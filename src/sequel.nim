## SEQUEL module
## =============
##
## This module includes easy-to-use SQL statements.
##
## This modules name is just here to trigger a good friend of mine :)

import std/[options, strutils, algorithm]
import db_connector/db_sqlite
import sql/queries

type
    Definition* = tuple[id: int, word, definition, author: string, upvotes, downvotes: int, timestamp, sha3hash: string]

    DatabaseError* = object of ValueError
    InvalidData* = object of DatabaseError
    DuplicateHash* = object of DatabaseError

const
    databaseSwitch*: string = (
        when defined(release): "database.db"
        else: "database-testing.db"
    ) ## Database switch (changes depending on if `-d:release` was used)
    databaseName* {.strdefine.} = databaseSwitch ## Database name, can be overridden manually

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
    except DatabaseError as e:
        echo "Reraising error: " & $e.name
        raise e
    except CatchableError as e:
        success = false
        echo "[Database error]: " & $e.name & ": " & e.msg & "'"
    finally:
        try:
            if success: db.exec(sql"COMMIT")
        except CatchableError:
            echo "[Database error]: Failed to commit"
        db.close()


proc toDefinition*(row: Row): Definition =
    result = (
        id: row[0].parseInt(),
        word: row[1],
        definition: row[2],
        author: row[3],
        upvotes: row[4].parseInt(),
        downvotes: row[5].parseInt(),
        timestamp: row[6],
        sha3hash: row[7]
    )
proc toDefinitions*(rows: seq[Row]): seq[Definition] =
    for row in rows:
        result.add row.toDefinition()


proc initDatabaseTables*() =
    ## Initialises all tables
    withDatabase db:
        db.exec(sql "PRAGMA encoding = \"UTF-8\"")
        for statement in sqlInitTables:
            db.exec(sql statement)

proc newDefinition*(word, description: string, author: string = "", hash: string) =
    ## New entry, author field is optional
    let
        word = word.strip()
        description = description.strip()
        author = author.strip()

    if "" in [word, description]:
        raise InvalidData.newException("Got an empty string while submitting new definition. Fields <b>Word</b> and <b>Definition</b> must not be empty!")

    # Check for duplicate hashes:
    withDatabase db:
        let rows: seq[Row] = db.getAllRows(sql sqlGetEntriesByHash, hash)

        # Duplicate hash, search more in-depth for matching submission data:
        if unlikely rows.len() != 0:
            for row in rows:
                let definition: Definition = row.toDefinition()
                if definition.word == word and definition.definition == description:
                    raise DuplicateHash.newException("Got duplicate entry. Refusing submission.")

        # Submit:
        if author != "":
            db.exec(sql sqlNewEntry, word, description, author, hash)
        else:
            db.exec(sql sqlNewEntryAnonymous, word, description, hash)

proc newDefinition*(definition: Definition, hash: string) =
    newDefinition(definition.word, definition.definition, definition.author, hash)

proc getDefinitionsBySqlStatement*(statement: SqlQuery, args: varargs[string]): seq[Definition] =
    ## Gets definitions based on statement and parameters
    withDatabase db:
        let response: seq[Row] = db.getAllRows(
            query = statement,
            args = args
        )
        for row in response:
            if row[0] == "": continue
            result.add row.toDefinition()
    result.sort() do (x, y: Definition) -> int:
        result = cmp(y.timestamp, x.timestamp)

proc getAllDefinitions*(): seq[Definition] =
    result = getDefinitionsBySqlStatement(sql sqlGetAllDefinitions)

proc getDefinitionsByName*(name: string): seq[Definition] =
    ## Gets definitions by their name
    result = getDefinitionsBySqlStatement(sql sqlGetDefinitionsByName, name)

proc getDefinitionById*(id: string|int): Option[Definition] =
    ## Gets definition by its ID
    let definitions: seq[Definition] = getDefinitionsBySqlStatement(sql sqlGetDefinitionById, $id)
    if definitions.len() == 0:
        result = none Definition
    else:
        result = some definitions[0]
