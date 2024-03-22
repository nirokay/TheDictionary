import std/[strutils]

const
    sqlQueriesDirectory: string = "./src/sql/"

proc importSqlQuery(filename: static[string]): static[string] =
    result = readFile(sqlQueriesDirectory & filename & ".sql").strip()

const
    sqlInitTables*: string = importSqlQuery "initTables"
    sqlNewEntry*: string = importSqlQuery "newEntry"
    sqlNewEntryAnonymous*: string = importSqlQuery "newEntryAnonymous"
    sqlNewEntryHash*: string = importSqlQuery "newHash"
    sqlGetDefinitionById*: string = importSqlQuery "getDefinitionById"
    sqlGetDefinitionsByName*: string = importSqlQuery "getDefinitionsByName"
    sqlGetAllDefinitions*: string = importSqlQuery "getAllDefinitions"
