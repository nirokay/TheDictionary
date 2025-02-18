## Website module
## ==============
##
## This module implements the HTML sent as a response by the webserver. It is not well optimised, as
## for each new response, it:
##
## * stringifies the HTML
## * stringifies the CSS and embeds it into the HTML
## * reads the javascript file from disk and embeds into the HTML
##
## But it works! And just for fun with friends this is more than enough :)

import std/[asyncdispatch, strutils, options, tables, os]
import websitegenerator
export websitegenerator
import sequel, dictionary, parser

const
    contentBoxId*: string = "content-display-div"
    searchBarId*: string = "search-bar-field"

    inputFieldsWidth = "92%"

const
    javascriptLocation*: string = "./src/javascript/"
    defaultJavascriptNotAvailable*: string = "window.onload = function() { alert('Could not load javascript for this page - page may not function correctly...') }"
    javascriptScripts*: Table[string, string] = block:
        var result: Table[string, string]
        for kind, element in walkDir(javascriptLocation, true):
            if unlikely kind in [pcDir, pcLinkToDir]: continue
            if likely element.endsWith(".js"):
                result[element] = ""

        for i, _ in result:
            let path: string = javascriptLocation & i
            try:
                result[i] = path.readFile()
            except CatchableError as e:
                echo "Cannot open file '" & path & "'."
                echo $e.name & ": " & e.msg
                result[i] = defaultJavascriptNotAvailable

        result

proc getJavascript(scriptName: string): string =
    ## Attempts to return javascript from the `const Table`
    if javascriptScripts.hasKey(scriptName):
        result = javascriptScripts[scriptName]
    else:
        result = defaultJavascriptNotAvailable

const
    # Css values:
    roundedCorners = ["border-radius", "6px"]
    unifiedBorder = border("10px")
    unifiedPadding = padding("10px")
    centeredMargin = ["margin", "auto"]

    overflowHidden = ["overflow", "hidden"]

    widthMax = maxWidth("750px")

    backgroundHtml = backgroundColour(
        rgb(30, 30, 40) # rgb(23, 25, 33)
    )
    backgroundContent = backgroundColour(
        rgb(40, 40, 60)
    )
    backgroundInputFields = backgroundColour(
        rgb(50, 50, 70)
    )
    backgroundButton = backgroundColour(
        rgb(50, 30, 58)
    )
    backgroundButtonHover = backgroundColour(
        rgb(60, 40, 68)
    )

    textColour = colour(rgb(245, 245, 245))

    textCenter = ["text-align", "center"]
    textUnderline = ["text-decoration", "underline"]
    textNoDecoration = ["text-decoration", "none"]


proc `->`(elem: string, properties: seq[array[2, string]]): CssElement =
    ## Css element
    newCssElement(elem, properties)
proc `|>`(class: string, properties: seq[array[2, string]]): CssElement =
    ## Css class
    newCssClass(class, properties)
proc link(which: string, colour: CssColour|string): CssElement =
    ## Css link stuff
    newCssElement("a:" & which,
        ["color", $colour],
        textNoDecoration
    )


const
    # Css classes:
    classCenter = "center" |> @[
        centeredMargin
    ]
    classCenterAll = "center-everything" |> @[
        centeredMargin,
        textCenter
    ]

    classFlexBox = "div-flex-box" |> @[
        centeredMargin,
        textCenter,
        display("flex"),
        alignItems("center"),
        ["flex", "auto"],
        ["flex-wrap", "wrap"],
        ["flex-basis", "auto"]
    ]

    classContentDiv = "content-display" |> @[
        centeredMargin,
        unifiedBorder,
        roundedCorners,
        backgroundContent,
        unifiedPadding,
        widthMax
    ]

    classSearchBar = "search-bar" |> @[
        centeredMargin,
        unifiedBorder,
        roundedCorners,
        backgroundContent,
        unifiedPadding
    ]

    classSearchDiv = "search-bar-div" |> @[
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["margin-top", "auto"],
        ["margin-bottom", "10px"],
        display("flex"),
        alignItems("baseline"),
        ["flex-wrap", "nowrap"],
        unifiedBorder,
        roundedCorners,
        padding("2px"),
        widthMax
    ]

    classRedirectButton = "button-redirect" |> @[
        textColour,
        backgroundButton,
        textAlign("center"),
        textNoDecoration,
        ["transition", "0.3s"],
        ["margin", "4px 2px"],
        padding("5px 10px"),
        roundedCorners
    ]
    classRedirectButtonHover = "button-redirect:hover" |> @[
        backgroundButtonHover,
        ["transition", "0.1s"]
    ]
    classDefinition = "definition" |> @[
        # border("thick solid " & $White),
        ["margin", "10px"],
        backgroundInputFields,
        unifiedPadding,
        roundedCorners
    ]
    classDefinitionWord = "definition-word" |> @[
        textUnderline,
        ["margin-top", "5px"],
        ["margin-bottom", "5px"],
        ["word-wrap", "break-word"],
        ["white-space", "pre-wrap"],
        overflowHidden
    ]
    classDefinitionDescription = "definition-description" |> @[
        ["margin-top", "10px"],
        ["word-wrap", "break-word"],
        ["white-space", "pre-wrap"],
        overflowHidden
    ]
    classDefinitionAuthor = "definition-author" |> @[
        ["word-wrap", "break-word"],
        ["white-space", "pre-wrap"],
        overflowHidden
    ]


const
    # Css stylesheet:
    css*: CssStyleSheet = block: ## Main css stylesheet
        var result = newCssStyleSheet("styles.css")
        result.add(
            "html" -> @[
                textColour,
                backgroundHtml,
                fontFamily("Verdana, Geneva, Tahoma, sans-serif")
            ],
            "h1, h2, h3, h4, h5, h6" -> @[
                textUnderline,
                textCenter
            ],
            "input" -> @[
                textColour,
                backgroundInputFields,
                width(inputFieldsWidth),
                roundedCorners
            ],
            "textarea" -> @[
                textColour,
                backgroundInputFields,
                width(inputFieldsWidth),
                ["resize", "vertical"],
                roundedCorners
            ],
            "form" -> @[
                textColour,
                border("solid 1px"),
                width("90%"),
                widthMax,
                ["margin", "auto 10px"],
                unifiedPadding,
                roundedCorners
            ],
            "button" -> @[
                textCenter,
                ["margin-top", "10px"]
            ],

            link("link", HotPink),
            link("visited", HotPink),
            link("hover", LightPink),
            link("active", WhiteSmoke),

            classCenter,
            classCenterAll,

            classFlexBox,

            classContentDiv,
            classSearchBar,
            classSearchDiv,

            classRedirectButton,
            classRedirectButtonHover,

            classDefinition,
            classDefinitionWord,
            classDefinitionDescription,
            classDefinitionAuthor
        )
        result


type Buttons* = enum
    toIndex, toDefinitions, toSubmitDefinitions

proc addContentBox(html: var HtmlDocument, elements: seq[HtmlElement] = @[p(" ")]) =
    ## Main content box
    html.add(
        `div`(
            elements
        ).setClass(classContentDiv).add(
            attr("id", contentBoxId)
        )
    )

proc li(elements: seq[HtmlElement]): HtmlElement = li($elements)

proc newPage*(name, description: string, generateContentBox: bool = true, scriptPath: string = ""): HtmlDocument =
    ## Generalised HTML page generator
    result = newHtmlDocument(name & ".html")

    # Meta stuff:
    result.addToHead(
        htmlComment(" Html and Css generated using website generator: https://github.com/nirokay/websitegenerator "),
        charset("utf-8"),
        viewport("width=device-width, initial-scale=1"),
        title(name),
        description(description)
    )

    # Script:
    if scriptPath != "":
        result.addToHead(
            script(scriptPath.getJavascript()).add(
                attr("defer")
            )
        )

    # Css:
    result.addToHead(
        newHtmlElement("style",
            $css
        )
    )

    # Buttons:
    let buttons = @[toIndex, toDefinitions, toSubmitDefinitions]
    var buttonList: seq[HtmlElement] = @[]
    for button in buttons:
        var
            dest: string
            text: string
        proc `->`(d, t: string) =
            dest = d
            text = t

        case button:
        of toIndex:
            "/" -> "Home"
        of toDefinitions:
            "/definitions" -> "Definitions"
        of toSubmitDefinitions:
            "/submit" -> "Submit"

        buttonList.add(
            a(dest, text).setClass(classRedirectButton)
        )
    if buttonList.len() != 0:
        result.addToBody(`div`(
            buttonList
        ).setClass(classCenterAll))


    # Basic structure:
    result.addToBody(
        h1(name)
    )
    if generateContentBox: result.addContentBox()

proc box(element: HtmlElement): HtmlElement =
    ## Sets the `classDefinition` class to the `HtmlElement`
    return element.setClass(classDefinition)

proc getHtmlDefinition*(definition: Definition): HtmlElement =
    ## Converts `Definition` to an `HtmlElement` with redundant sussy character replacement for security
    let
        id = definition.id
        timestamp = definition.timestamp
        word = definition.word.replaceAllSussyCharactersDecodeEncode().decode()
        author = definition.author.replaceAllSussyCharactersDecodeEncode().decode()
        definition = definition.definition.replaceAllSussyCharactersDecodeEncode().decode()

    result = box `div`(
        h2(
            $a("/definition/" & $id, word) # Direct to the post itself
        ).setClass(classDefinitionWord),
        p(definition).setClass(classDefinitionDescription),
        small("by <b>" & author & "</b> @ " & timestamp & " UTC").setClass(classDefinitionAuthor)
    )

proc linksToSources(): HtmlElement =
    proc button(link, text: string): HtmlElement =
        result = a(link, text).setClass(classRedirectButton)
    result = `div`(
        `div`(
            button("https://github.com/nirokay/TheDictionary", "TheDictionary - Source-Code"),
            button("https://github.com/nirokay/TheDictionary/releases/latest", "TheDictionary - Releases")
        ).setClass(classFlexBox)
    )

proc htmlIndex*(): Future[HtmlDocument] {.async.} =
    ## HTML - Index page
    result = newPage("TheDictionary", "TheDictionary is a basic Urban Dictionary clone.", false)
    let all: seq[Definition] = getAllDefinitions()

    var elements: seq[HtmlElement]
    if all.len() != 0:
        elements &= @[
            h2("Latest addition"),
            all[0].getHtmlDefinition(),
            hr(),
        ]
    elements &= @[
        h2("About"),
        box `div`(
            p(
                "TheDictionary is a basic " & $a("https://urbandictionary.com/", "Urban Dictionary") & " clone." & $br() &
                "This is a community-/user-run dictionary, that lets you submit and view definitions."
            )
        ),

        hr(),

        h2("Links"),
        box linksToSources()
    ]
    result.addContentBox(elements)


proc htmlSubmitDefinition*(): Future[HtmlDocument] {.async.} =
    ## HTML - Submit page
    result = newPage("TheDictionary - Submit", "", false, "definition_submit.js")
    let
        idWord: string = "submit-word"
        idDefinition: string = "submit-definition"
        idAuthor: string = "submit-author"

    proc newField(id, text, name, placeholder: string, isTextarea: bool = false): HtmlElement =
        result = li(@[
            label(id, text),
            br(),
            (
                if isTextArea: textarea("").add(
                    attr("placeholder", placeholder),
                    attr("rows", "10"),
                    attr("id", id),
                    attr("name", name)
                )
                else: input("text", id).add(
                    attr("placeholder", placeholder),
                    attr("name", name)
                )
            )
        ])
    result.addContentBox(@[
        form(
            ul(@[
                newField(idWord, "Word:", "word", "My interesting word", false),
                newField(idDefinition, "Definition:", "definition", "My interesting definition", true),
                newField(idAuthor, "Author:", "author", "My name (optional)", false),
                `div`(newHtmlElement("button", "Submit").add(
                    attr("type", "submit")
                )).setClass(classCenterAll)
            ]),
        ).add(
            attr("action", "/handle-submit"),
            attr("method", "post"),
            attr("accept-charset", "utf-8")
        ).setClass(classCenter)
    ])

proc htmlSubmitSuccess*(word: string): Future[HtmlDocument] {.async.} =
    ## HTML - Submit success page
    result = newPage("TheDictionary - Successful submit", "", false, "definition_submit_success.js")
    result.addContentBox(@[
        p(
            "Successfully added new definition for word '" & $b(word.decode().replaceAllSussyCharacters()) & "'!" & $br() &
            "You will be redirected in " & $b("3 seconds") & "!"
        ).setClass(classCenterAll)
    ])

proc htmlDisplaySingleDefinition*(id: int): Future[HtmlDocument] {.async.} =
    ## HTML - Definition page
    result = newPage("TheDictionary - Definition", "", false)
    let definition: Option[Definition] = getDefinitionById(id)
    if definition.isSome():
        result.addContentBox(@[
            getHtmlDefinition(get definition)
        ])
    else:
        result.addContentBox(@[
            p("Post ID does not exist...").setClass(classCenterAll)
        ])


proc htmlDisplayMultipleDefinitions*(query: string = ""): Future[HtmlDocument] {.async.} =
    ## HTML - (Multiple) Definitions page
    result = newPage("TheDictionary - Definitions", "", false, "definitions.js")
    let definitions: seq[Definition] = (
        if query != "": getDefinitionsByName(query)
        else: getAllDefinitions()
    )

    # Small text under header:
    proc whatIsBeingSearched(params: string): string =
        try:
            result = params[1 .. ^2].decode().replaceAllSussyCharacters()
        except IndexDefect:
            result = params.replaceAllSussyCharacters()

    let searchInfo: string = (
        if query != "": "Showing results for '" & $b(whatIsBeingSearched(query)) & "'."
        else: "Displaying all definitions."
    )

    result.addToBody(`div`(
        small(searchInfo)
    ).setClass(classCenterAll))

    # Search bar:
    result.addToBody(
        `div`(
            input("text", searchBarId).add(
                attr("placeholder", "Search query"),
                attr("name", "Search")
            ),
            newHtmlElement("button", "Search").add(
                attr("onclick", "searchBarQuery();")
            )
        ).setClass(classSearchDiv)
    )

    # Definitions:
    if definitions.len() != 0:
        var box: seq[HtmlElement]
        for definition in definitions:
            box.add definition.getHtmlDefinition()
        result.addContentBox(box)
    else:
        let error: string = (
            if query != "": "No posts matching the query were found..."
            else: "No posts found..."
        )
        result.addContentBox(@[
            p(error).setClass(classCenterAll)
        ])

proc httpErrorPage*(details: string): Future[HtmlDocument] {.async.} =
    ## HTML - Error page
    result = newPage("TheDictionary - Error", "", false)
    result.add(
        p(details).setClass(classCenterAll)
    )
