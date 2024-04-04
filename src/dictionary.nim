## Dictionary module
## =================
##
## Generic procs to interface with the database/dictionary. Validates characters and replaces
## malicious ones (`<` and `>`).

import std/[asyncdispatch, options, strutils, uri]
import sequel
import checksums/sha3

type
    ValidationResponse* = tuple[success: bool, details: string]
    SubmitRequest* = object
        word, definition: string
        author: Option[string]

const
    replaceCharacters*: seq[array[2, string]] = @[
        ["<", "&lt;"],
        [">", "&gt;"]
    ] ## Suspicious characters with their not-sus counterparts

proc replaceAllSussyCharacters*(decoded: string): string =
    ## Replaces all *sus* characters using `replaceCharacters`
    result = decoded
    for operation in replaceCharacters:
        let
            toReplace: string = operation[0]
            replaceWith: string = operation[1]
        result = result.replace(toReplace, replaceWith)

proc replaceAllSussyCharactersDecodeEncode*(encoded: string): string =
    ## Replaces all *sus* characters using `replaceCharacters`
    ##
    ## Input is an encoded url string, which is also returned after completion
    result = encoded.decodeUrl()
    result = result.replaceAllSussyCharacters()
    result = result.encodeUrl()

proc constructHash*(word, definition: string): string =
    ## Constructs a hash for a definition
    var hasher: Sha3StateStatic[Sha3_512] = initSha3_512()
    hasher.update(word)
    hasher.update(definition)
    let digest: Sha3Digest_512 = hasher.digest()
    result = $digest

proc validateNewEntryAndCommit*(word, definition, author: string): Future[ValidationResponse] {.async.} =
    ## Validates, replaces sussy characters and finally commits new definition to the database if:
    ##
    ## * hash is known
    ## * non-optional fields are not empty
    let
        word = word.strip().replaceAllSussyCharacters()
        definition = definition.strip().replaceAllSussyCharacters()
        author = author.strip().replaceAllSussyCharacters()
        hash: string = constructHash(word, definition)
    try:
        newDefinition(word, definition, author, hash)
    except DuplicateHash:
        return (false, "Duplicate entry")
    except InvalidData:
        return (false, "Invalid data: Missing non-optional fields")
    return (true, word)
