#!/bin/bash

PATH_TO_REPO="$1"
PATH_TO_LOG="$(mktemp)"
OUTPUT_DIR="$(mktemp -d)"


info() {
    echo "info: $1" >&2
}


if [[ $# -ne 1 ]]; then
  echo "usage: $0 repo" >&2
  echo "  repo  local path to git repository" >&2
  exit 1
fi

info "logging to $PATH_TO_LOG"
info "output directory: $OUTPUT_DIR"

git -C "$PATH_TO_REPO" branch --all | grep -F 'remotes/origin' | cut -d ' ' -f 3 | while read branch; do
  git -C "$PATH_TO_REPO" checkout "$branch" &> /dev/null
  echo "$branch" >> "$PATH_TO_LOG"

  ls "$PATH_TO_REPO/.github/workflows" | while read workflow; do
    workflow_path="$PATH_TO_REPO/.github/workflows/$workflow"
    shasum "$workflow_path" >> "$PATH_TO_LOG"
    cat "$workflow_path" > "$OUTPUT_DIR/$(shasum "$workflow_path" | cut -f 1 -d ' ')"
  done
done

