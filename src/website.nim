import std/[asyncdispatch, strutils, options]
import websitegenerator
export websitegenerator
import sequel, dictionary, parser

const
    javascriptLocation*: string = "./src/javascript/"
    contentBoxId*: string = "content-display-div"

    inputFieldsWidth = "92%"

proc `->`(elem: string, properties: varargs[array[0..1, string]]): CssElement =
    ## Css element
    newCssElement(elem, properties)
proc `|>`(class: string, properties: varargs[array[0..1, string]]): CssElement =
    ## Css class
    newCssClass(class, properties)
proc link(which: string, colour: CssColour|string): CssElement =
    ## Css link stuff
    newCssElement("a:" & which,
        ["color", $colour],
        ["text-decoration", "none"]
    )

const
    # Css classes:
    classCenter = "center" |> @[
        ["margin", "auto"]
    ]
    classCenterAll = "center-everything" |> @[
        ["margin", "auto"],
        ["text-align", "center"]
    ]

    classContentDiv = "content-display" |> @[
        ["margin", "auto"],
        border("10px"),
        backgroundColour(rgb(40, 40, 60)),
        padding("10px"),
        maxWidth("750px")
    ]

    classRedirectButton = "button-redirect" |> @[
        colour(White),
        backgroundColour(rgb(50, 30, 58)),
        textAlign("center"),
        ["text-decoration", "none"],
        ["transition", "0.3s"],
        ["margin", "4px 2px"],
        padding("5px 10px"),
        ["border-radius", "6px"]
    ]
    classRedirectButtonHover = "button-redirect:hover" |> @[
        backgroundColour(rgb(60, 40, 68)),
        ["transition", "0.1s"]
    ]
    classDefinition = "definition" |> @[
        border("thick solid " & $White),
        ["margin", "10px"],
        padding("10px")
    ]
    classDefinitionWord = "definition-word" |> @[
        ["text-decoration", "underline"],
        ["margin-top", "5px"],
        ["margin-bottom", "5px"],
        ["word-wrap", "break-word"],
        ["white-space", "pre-wrap"]
    ]
    classDefinitionDescription = "definition-description" |> @[
        ["margin-top", "10px"],
        ["word-wrap", "break-word"],
        ["white-space", "pre-wrap"]
    ]
    classDefinitionAuthor = "definition-author" |> @[
        ["word-wrap", "break-word"],
        ["white-space", "pre-wrap"]
    ]

    # Css stylesheet:
    css: CssStyleSheet = block:
        var result = newCssStyleSheet("styles.css")
        result.add(
            "html" -> @[
                colour(White),
                backgroundColour(rgb(23, 25, 33)),
                fontFamily("Verdana, Geneva, Tahoma, sans-serif")
            ],
            "h1, h2, h3, h4, h5, h6" -> @[
                ["text-decoration", "underline"],
                ["text-align", "center"]
            ],
            "input" -> @[
                colour(White),
                backgroundColour(rgb(50, 50, 70)),
                width(inputFieldsWidth)
            ],
            "textarea" -> @[
                colour(White),
                backgroundColour(rgb(50, 50, 70)),
                width(inputFieldsWidth),
                ["resize", "vertical"]
            ],
            "form" -> @[
                colour(White),
                border("solid 1px"),
                width("90%"),
                maxWidth("750px"),
                ["margin", "auto 10px"],
                padding("10px")
            ],
            "button" -> @[
                ["text-align", "center"],
                ["margin-top", "10px"]
            ],

            link("link", HotPink),
            link("visited", HotPink),
            link("hover", LightPink),
            link("active", WhiteSmoke),

            classCenter,
            classCenterAll,

            classContentDiv,

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
    html.add(
        `div`(
            elements
        ).setClass(classContentDiv).add(
            attr("id", contentBoxId)
        )
    )

proc li(elements: seq[HtmlElement]): HtmlElement = li($elements)

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
    var buttonList: seq[HtmlElement]
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

proc getHtmlDefinition*(definition: Definition): HtmlElement =
    let
        id = definition.id
        timestamp = definition.timestamp
        word = definition.word.decode()
        author = definition.author.decode()
        definition = definition.definition.decode()
    echo definition
    result = `div`(
        h2(
            $a("/definition/" & $id, word) # Direct to the post itself
        ).setClass(classDefinitionWord),
        p(definition).setClass(classDefinitionDescription),
        small("by <b>" & author & "</b> @ " & timestamp & " UTC").setClass(classDefinitionAuthor)
    ).setClass(classDefinition)


proc htmlIndex*(): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary", "TheDictionary is a basic Urban Dictionary clone.", @[toDefinitions, toSubmitDefinitions], false)
    let all: seq[Definition] = getAllDefinitions()
    if all.len() != 0:
        result.addContentBox(@[
            h2("Latest addition"),
            all[0].getHtmlDefinition()
        ])

proc htmlSubmitDefinition*(): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Submit", "", @[toIndex, toDefinitions], false, "definition_submit.js")
    let
        idWord: string = "submit-word"
        idDefinition: string = "submit-definition"
        idAuthor: string = "submit-author"

        replaceMe: string = "#REPLACE_ME#" # 10.000 IQ move
    proc newField(id, text, name, placeholder: string, isTextarea: bool = false): HtmlElement =
        result = li(@[
            label(id, text),
            br(),
            (
                if isTextArea: newElement("textarea", replaceMe).add( # 100.000 IQ move
                    attr("placeholder", placeholder),
                    attr("rows", "3"),
                    attr("id", id),
                    attr("name", name)
                )
                else: input("text", id, name).add(attr("placeholder", placeholder))
            )
        ])
    result.addContentBox(@[form(@[
        ul(@[
            newField(idWord, "Word:", "word", "My interesting word", false),
            text replace($newField(idDefinition, "Definition:", "definition", "My interesting definition", true), replaceMe, ""), # 1.000.000 IQ move
            newField(idAuthor, "Author:", "author", "My name (optional)", false),
            `div`(newElement("button", "Submit").add(
                attr("type", "submit")
            )).setClass(classCenterAll)
        ]),
    ], "/handle-submit").add(
        attr("method", "post"),
        attr("accept-charset", "utf-8")
    ).setClass(classCenter)])

proc htmlSubmitSuccess*(word: string): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Successful submit", "", @[], false, "definition_submit_success.js")
    result.addContentBox(@[
        p(
            "Successfully added new definition for word '" & $b(word.replaceAllSussyCharacters()) & "'!" & $br() &
            "You will be redirected in " & $b("3 seconds") & "!"
        ).setClass(classCenterAll)
    ])

proc htmlDisplaySingleDefinition*(id: int): Future[HtmlDocument] {.async.} =
    result = newPage("TheDictionary - Definition", "", @[toIndex], false)
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
    result = newPage("TheDictionary - Definitions", "", @[toIndex], false)
    let definitions: seq[Definition] = (
        if query != "": getDefinitionsByName(query)
        else: getAllDefinitions()
    )
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
    result = newPage("TheDictionary - Error", "", @[toIndex], false)
    result.add(
        p(details).setClass(classCenterAll)
    )
