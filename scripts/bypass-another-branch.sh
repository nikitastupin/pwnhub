#!/bin/bash

info() {
  echo "info: $1" >&2
}

error() {
  echo "error: $1" >&2
}

help() {
  echo "$1" >&2
}


if [[ $# -ne 1 ]]; then
  help "usage: $0 repo"
  help "  repo    path to local git repository"
  help
  help "outputs list of *unique* workflow files found in all *remote* branches of the repo"
  exit 1
fi

LOCAL_REPO="$1"

if [[ ! -d "$LOCAL_REPO/.git" ]]; then
  error "$LOCAL_REPO is not git repository"
  exit 2
fi

OUTPUT_DIR="$(mktemp -d)"
HASH_DIR="$(mktemp -d)"

git -C "$LOCAL_REPO" branch --remotes | grep -vF 'HEAD ->' | cut -d ' ' -f 3 | while read branch; do
  mkdir -p "$OUTPUT_DIR/$branch/.github/workflows"

  git -C "$LOCAL_REPO" checkout --quiet "$branch"

  if ! test -d "$LOCAL_REPO/.github/workflows"; then
    continue
  fi

  find "$LOCAL_REPO/.github/workflows" -type f | grep -E '\.ya?ml$' | while read file; do
    cp "$file" "$OUTPUT_DIR/$branch/.github/workflows"
  done
done

find "$OUTPUT_DIR" -type f | grep -E '\.ya?ml$' | while read file; do
  hash="$HASH_DIR/$(shasum "$file" | cut -d ' ' -f 1)"
  if test -f "$hash"; then
    rm "$file"
  else
    touch "$hash"
  fi
done

find "$OUTPUT_DIR" -type f
