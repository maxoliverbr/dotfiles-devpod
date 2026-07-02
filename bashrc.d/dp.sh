dp() {
  local target="${1:-$(basename "$PWD")}"

  if ! devpod list --output json 2>/dev/null | jq -e --arg p "$PWD" '[.[] | select(.source.localFolder == $p)] | length > 0' >/dev/null; then
    devpod up . --id "$target"
  fi

  devpod ssh "$target"
}