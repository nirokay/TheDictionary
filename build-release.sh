#!/usr/bin/env bash

TASKS=(
    "nimble build -d:release"
    "nimble build -d:release -d:mingw"
)

echo "Starting build release script"
for task in "${TASKS[@]}"; do
    echo "Running: '$task'"
    $task
done
echo "Finished build release script"
