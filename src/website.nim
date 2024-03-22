import std/[asyncdispatch, tables]
import websitegenerator
export websitegenerator

const
    javascriptLocation*: string = "./src/javascript/"
    contentBoxId*: string = "content-display-div"

proc `->`(elem: string, properties: varargs[array[0..1, string]]): CssElement =
    newCssElement(elem, properties)

const css: CssStyleSheet = block:
    var result = newCssStyleSheet("styles.css")
    result.add(
        "h1, h2, h3, h4, h5, h6" -> @[
            ["text-decoration", "underline"]
        ]
    )
    result


type Buttons* = enum
    toIndex, toDefinitions, toSubmitDefinitions

proc addContentBox(html: var HtmlDocument) =
    html.add(
        `div`(
            p("Content")
        ).add(
            attr("id", contentBoxId)
        )
    )

proc newPage*(name, description: string, buttons: seq[Buttons], generateContentBox: bool = true, scriptPath: string = ""): HtmlDocument =
    ## Generalised HTML page generator
    result = newDocument(name & ".html")

    # Meta stuff:
    result.addToHead(
        comment(" Html and Css generated using website generator: https://github.com/nirokay/websitegenerator "),
        charset("utf-8"),
        viewport("width=device-width, initial-scale=1"),
        title(name),
        description(description)
    )

    # Script:
    if scriptPath != "":
        let rawScript: string = readFile(javascriptLocation & scriptPath)
        result.addToHead(
            script(rawScript).add(
                attr("defer")
            )
        )

    # Css:
    result.addToHead(
        newElement("style",
            $css
        )
    )

    # Buttons:
    for button in buttons:
        result.addToBody(
            case button:
            of toIndex: a("/", "Home")
            of toDefinitions: a("/definitions", "Definitions")
            of toSubmitDefinitions: a("/submit", "Submit")
        )


    # Basic structure:
    result.addToBody(
        h1(name)
    )
    result.addContentBox()

proc htmlIndex*(): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary", "TheDictionary is a basic Urban Dictionary clone.", @[toDefinitions, toSubmitDefinitions], false)

proc htmlSubmitDefinition*(): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Submit", "", @[toIndex, toDefinitions], true, "definition_submit.js")

proc htmlDisplaySingleDefinition*(): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Definition", "", @[toIndex])

proc htmlDisplayMultipleDefinitions*(): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Definitions", "", @[toIndex])

proc httpErrorPage*(details: string): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Error", "", @[toIndex], false)
    result.add(
        p(details)
    )

