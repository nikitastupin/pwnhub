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

REMOTE="$(git -C "$LOCAL_REPO" remote get-url origin)"

# https://github.com/dead-claudia/github-limits
if ! echo "$REMOTE" | grep -qE '^https://github\.com/[0-9A-Za-z-]+/[0-9A-Za-z_.-]+$'; then
  error "remote '$REMOTE' does not match regex"
  exit 1
fi

OWNER="$(echo "$REMOTE" | cut -d / -f 4)"
REPO="$(echo "$REMOTE" | cut -d / -f 5)"

git -C "$LOCAL_REPO" branch --remotes | grep -vF 'HEAD ->' | cut -d ' ' -f 3 | while read branch; do
  git -C "$LOCAL_REPO" checkout --quiet "$branch"

  if ! test -d "$LOCAL_REPO/.github/workflows"; then
    continue
  fi

  out="$OUTPUT_DIR/$OWNER/$REPO/$branch/.github/workflows"
  mkdir -p "$out"

  find "$LOCAL_REPO/.github/workflows" -type f | grep -E '\.ya?ml$' | while read file; do
    cp "$file" "$out"
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
