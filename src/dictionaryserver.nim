## dictionaryserver
## ================
##
## This module houses the webserver to send POST and GET requests to.

{.define: ssl.}
import std/[asyncdispatch, asynchttpserver, strutils, sequtils]
import sequel, dictionary, website, parser

using
    request: Request

var server: AsyncHttpServer = newAsyncHttpServer()
const port* {.intdefine.}: uint16 = 6969 ## Server port

proc responseHeaders*(): HttpHeaders =
    ## Default http headers
    result = newHttpHeaders(@[
        ("Content-Type", "text/html; charset=utf-8")
    ])

proc serveErrorPage*(request; path: seq[string], description: string, httpCode: HttpCode = Http400) {.async.} =
    ## Generic error page server
    return request.respond(
        httpCode,
        $(await httpErrorPage(description)),
        responseHeaders()
    )


proc serveIndex*(request; path: seq[string]) {.async.} =
    ## Serves the index page
    return request.respond(
        Http200,
        $(await htmlIndex()),
        responseHeaders()
    )

proc serveNewEntryConstruct*(request; path: seq[string]) {.async.} =
    ## Serves a page for a new entry
    return request.respond(
        Http200,
        $(await htmlSubmitDefinition()),
        responseHeaders()
    )

proc handleNewDefinition*(request; path: seq[string]) {.async.} =
    ## Processes a submission and serves a success/failure page
    let
        body: string = request.body
        parsed: ParsedSubmitField = body.parseHtmlBodySubmit()
        status: ValidationResponse = await validateNewEntryAndCommit(
            parsed.word,
            parsed.definition,
            parsed.author
        )

    case status.success:
    of true:
        return request.respond(
            Http200,
            $(await htmlSubmitSuccess(status.details)),
            responseHeaders()
        )
    of false:
        return request.serveErrorPage(path, "Failed to submit your new entry: " & status.details)

proc serveDefinitions*(request; path: seq[string]) {.async.} =
    ## Queries all definitions or by patterns
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

proc serveDefinitionById*(request; path: seq[string]) {.async.} =
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


proc handleRequest*(request) {.async.} =
    ## Main request handler based on path
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
        # Serve constructor for new submission:
        return request.serveNewEntryConstruct(args)
    of "handle-submit":
        # New, improved way to handle submission:
        return request.handleNewDefinition(args)
    of "definitions":
        # Display all or queried submission(s):
        return request.serveDefinitions(args)
    of "definition":
        # Display single submission:
        # - Query:
        if args.len() != 1:
            return request.serveErrorPage(args, "Invalid query, example: <b>/definition/{id}</b>", Http400)
        # - Display by ID:
        return request.serveDefinitionById(args)
    else:
        # Display 404:
        return request.serveErrorPage(args, "Not found", Http404)


proc ctrlc() {.noconv.} =
    echo "\nShutting down server..."
    server.close()
    quit(QuitSuccess)
setControlCHook(ctrlc)


proc runServer*() {.async.} =
    ## Runs the server - listens to requests and responds
    server.listen(Port port)
    echo "Server listening on port " & $port
    while true:
        if server.shouldAcceptRequest():
            await server.acceptRequest(handleRequest)


initDatabaseTables()
waitFor runServer()
