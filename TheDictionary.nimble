# Package

version       = "1.1.2"
author        = "nirokay"
description   = "THE only, best and worst urban dictionary style server."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["dictionaryserver"]


# Dependencies

requires "nim >= 2.0.0"
requires "db_connector", "checksums", "websitegenerator >= 1.0.9"
