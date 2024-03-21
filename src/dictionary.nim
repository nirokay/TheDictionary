import std/[asyncdispatch, base64, json, options]
import sequel

type
    ValidationResponse* = tuple[success: bool, details: string]
    SubmitRequest* = object
        word, definition: string
        author: Option[string]

proc validateNewEntryAndCommit*(encoded: string): Future[ValidationResponse] {.async.} =
    ## Validates base64 encoded JSON, if it passes it hits the database with
    ## a new commit
    try:
        # Parsing:
        let
            rawJson: string = encoded.decode() # Blindly decode base64, trust me, this is fine (i think)
            json: JsonNode = rawJson.parseJson() # This will fail when parsing invalid base64
            request: SubmitRequest = json.to(SubmitRequest) # This wil fail, if garbage json is received

        # Adding to database:
        newDefinition(request.word, request.definition, request.author.get(""))
        return (true, "Submitted new definition for the word '" & request.word & "'!")
    except InvalidData as e:
        return (false, e.msg)
    except JsonParsingError:
        return (false, "Incorrect base64 data received, could not parse JSON.")
