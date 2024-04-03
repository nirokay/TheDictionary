import std/[asyncdispatch, json, options, strutils]
import sequel
import checksums/sha3

type
    ValidationResponse* = tuple[success: bool, details: string]
    SubmitRequest* = object
        word, definition: string
        author: Option[string]

const
    replaceCharacters: seq[array[2, string]] = @[
        ["<", "&lt;"],
        [">", "&gt;"]
    ]

proc replaceAllSussyCharacters*(json: string): string =
    result = json
    for operation in replaceCharacters:
        let
            toReplace: string = operation[0]
            replaceWith: string = operation[1]
        result = result.replace(toReplace, replaceWith)

proc constructHash*(word, definition: string): string =
    var hasher: Sha3StateStatic[Sha3_512] = initSha3_512()
    hasher.update(word)
    hasher.update(definition)
    let digest: Sha3Digest_512 = hasher.digest()
    result = $digest

proc validateNewEntryAndCommit*(word, definition, author: string): Future[ValidationResponse] {.async.} =
    let
        word = word.strip()
        definition = definition.strip()
        author = author.strip()
        hash: string = constructHash(word, definition)
    newDefinition(word, definition, author, hash)
