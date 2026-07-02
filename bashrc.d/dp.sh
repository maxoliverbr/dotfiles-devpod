dp() {
  if [[ -n "$1" && -d "$1" ]]; then
    cd "$1" || return 1
  fi
  local target="$(basename "$PWD")"

  if ! devpod list --output json 2>/dev/null | jq -e --arg p "$PWD" '[.[] | select(.source.localFolder == $p)] | length > 0' >/dev/null; then
    devpod up . --id "$target" --ide none --fallback-image mcr.microsoft.com/devcontainers/base:ubuntu
  fi

  devpod ssh "$target"
}
