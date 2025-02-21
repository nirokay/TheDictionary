#!/usr/bin/env bash

BIN="dictionaryserver"

# Build native (linux):
nimble build -d:release && mv "$BIN" "${BIN}_${OSTYPE}-${HOSTTYPE}"

# Build windows:
nimble build -d:release -d:mingw && mv "$BIN.exe" "${BIN}_windows-${HOSTTYPE}.exe"
