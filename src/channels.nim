import std/[asyncdispatch]

type
    DatabaseCommand* = enum
        commandDatabaseNewEntry,
        commandDatabaseViewEntry,
        commandDatabaseDisplayAllEntries
    DatabaseMessage* = object
        command: DatabaseCommand
        definition: string

var channelDatabase*: Channel[DatabaseMessage]

proc sendToChannelDatabase*(message: DatabaseMessage) {.async.} =
    channelDatabase.send(message)
