import std/[strutils, tables, uri]

const
    keyValueSeparator: char = '&'
    keyValueAssign: char = '='

type
    ParsedSubmitField* = tuple[word, definition, author: string] ## Valid fields for submissions

proc parseHtmlBody*(body: string): Table[string, string] =
    ## Parses html body and turns it into a Table of key -> value pairs
    let pairs: seq[string] = body.split(keyValueSeparator)
    for pair in pairs:
        let
            split: seq[string] = pair.split(keyValueAssign)
            key = split[0]
            value = split[1]
        result[key] = value

proc parseHtmlBodySubmit*(body: string): ParsedSubmitField =
    ## Parses html body for the submit page
    let parsed: Table[string, string] = body.parseHtmlBody()
    result = (
        word: parsed.getOrDefault("word", ""),
        definition: parsed.getOrDefault("definition", ""),
        author: parsed.getOrDefault("author", "")
    )

proc decode*(encoded: string): string =
    ## Decodes stored data to utf-8 (i think...)
    result = encoded.decodeUrl(decodePlus = true)

    # Voodoo magic to not have every line end with a `\n`
    var lines: seq[string] = result.split("\n")
    for i, line in lines:
        lines[i] = line.strip()
    result = lines.join("<br />")
