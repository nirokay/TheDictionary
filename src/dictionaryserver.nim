{.define: ssl.}
import std/[asyncdispatch, asynchttpserver, strutils, sequtils, base64]
import sequel, dictionary, website

using
    request: Request

var server: AsyncHttpServer = newAsyncHttpServer()
const port {.intdefine.}: uint16 = 6969

proc responseHeaders(): HttpHeaders =
    ## Default http headers
    result = newHttpHeaders()

proc serveErrorPage(request; path: seq[string], description: string, httpCode: HttpCode = Http400) {.async.} =
    ## Generic error page server
    return request.respond(
        httpCode,
        $(await httpErrorPage(description)),
        responseHeaders()
    )


proc serveIndex(request; path: seq[string]) {.async.} =
    ## Serves the index page
    return request.respond(Http200, $(await htmlIndex()), responseHeaders())


proc serveNewEntrySubmitAndValidation(request; path: seq[string]) {.async.} =
    ## Serves an error page for a failed submit
    let status: ValidationResponse = await path.join("/").validateNewEntryAndCommit()
    if status.success:
        return request.respond(Http200, "<h1>Success!</h1><p>" & status.details & "</p>")
    else:
        return request.serveErrorPage(path, "Failed to submit your new entry: " & status.details)

proc serveNewEntryConstruct(request; path: seq[string]) {.async.} =
    ## Serves a page for a new entry
    return request.respond(
        Http200,
        $(await htmlSubmitDefinition()),
        responseHeaders()
    )



proc serveDefinitions(request; path: seq[string]) {.async.} =
    ## Serves all or multiple definitions based on their name
    let query: string = block:
        try:
            path[0]
        except IndexDefect:
            ""
    return request.respond(
        Http200,
        $(await htmlDisplayMultipleDefinitions(query)),
        responseHeaders()
    )

proc serveDefinitionById(request; path: seq[string]) {.async.} =
    ## Serves a definition queried by its ID
    var id: int
    try:
        id = path[0].parseInt()
    except ValueError as e:
        return request.serveErrorPage(path, "ID has to be an integer: " & e.msg, Http400)
    return request.respond(
        Http200,
        $(await htmlDisplaySingleDefinition(id)),
        responseHeaders()
    )


proc handleRequest(request) {.async.} =
    ## Main request handler
    let path: seq[string] = block:
        var p: seq[string] = request.url.path.split('/').deduplicate()
        if p[0] == "": p[1 .. ^1]
        else: p

    echo "New request: /" & path.join("/")

    # Default behaviour (index):
    if path.len() == 0:
        return request.serveIndex(path)

    let args: seq[string] = path[1 .. ^1]
    case path[0].toLower():
    of "submit":
        try:
            if args.len() == 0:
                raise IndexDefect.newException("Throw error to continue to new entry construction.")
            return request.serveNewEntrySubmitAndValidation(args)
        except IndexDefect:
            return request.serveNewEntryConstruct(args)
    of "definitions":
        return request.serveDefinitions(args)
    of "definition":
        if args.len() != 1:
            return request.serveErrorPage(args, "Invalid query, example: <b>/definition/{id}</b>", Http400)
        return request.serveDefinitionById(args)
    else:
        return request.serveErrorPage(args, "Not found", Http404)


proc runServer() {.async.} =
    server.listen(Port port)
    while true:
        if server.shouldAcceptRequest():
            await server.acceptRequest(handleRequest)

proc main() =
    initDatabaseTables()
    waitFor runServer()
main()
