{.define: ssl.}
import std/[]
import sequel

initDatabaseTables()

newEntry("sus", "impostor", "not impostor")
newEntry("among us", "among us is a great game lol because sussy wussy", "crewmate")
newEntry("cum", "a refreshing beverage")

while true:
    proc readInput(question: string): string =
        stdout.write(question & ": ")
        result = stdin.readLine()
    var
        word: string
        definition: string
        author: string

    echo "--- Prompting new entry ---"
    word = readInput("Word")
    definition = readInput("Definition for '" & word & "'")
    author = readInput("Your name (optional)")

    newEntry(word, definition, author)
    echo "Adding new definition for '" & word & "' by '" & (if author != "": author else: "Anonymous") & "'!"
