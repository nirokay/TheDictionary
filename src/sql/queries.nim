import std/[strutils]

const
    sqlQueriesDirectory: string = "./src/sql/"

proc importSqlQuery(filename: static[string]): static[string] =
    result = readFile(sqlQueriesDirectory & filename & ".sql").strip()

const
    sqlInitTableDefinitions*: string = importSqlQuery "initTableDefinitions"

    sqlInitTables*: array[1, string] = [
        sqlInitTableDefinitions
    ]

    sqlNewEntryHash*: string = importSqlQuery "newHash"
    sqlNewEntry*: string = importSqlQuery "newEntry"
    sqlNewEntryAnonymous*: string = importSqlQuery "newEntryAnonymous"

    sqlGetDefinitionById*: string = importSqlQuery "getDefinitionById"
    sqlGetDefinitionsByName*: string = importSqlQuery "getDefinitionsByName"
    sqlGetAllDefinitions*: string = importSqlQuery "getAllDefinitions"

    sqlGetEntriesByHash*: string = importSqlQuery "getEntriesByHash"
