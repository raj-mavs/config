#!/usr/bin/env bash

set -euo pipefail

SESSION="logs"

# Create session if it doesn't exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION"
fi

DIR=$(realpath "${1:-.}")
EXT="${2:-log}"

for file in "$DIR"/*."$EXT"; do

  if [[ ! -f "$file" ]]; then
    continue
  fi

  base_file=$(basename "$file" ".$EXT")

  name=$(echo $base_file | sed -E "s|.+/(.*)$|\1|")

  tmux new-window -t "$SESSION" -n "$name" \
    "watch -c -n 1 -- tail -n 40 \"$file\""
done

tmux attach -t "$SESSION"
