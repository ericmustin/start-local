#!/usr/bin/env sh
# start-local.sh
# Smart launcher: prefer Podman if available (with compose), else fall back to Docker.
# Passes all args through to the selected script.

set -eu

here="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

# Optional override:
#   ENGINE=podman ./start-local.sh ...
#   ENGINE=docker  ./start-local.sh ...
ENGINE="${ENGINE:-auto}"

use_podman() {
  # Podman must exist AND have a working "compose" (subcommand or legacy podman-compose)
  if command -v podman >/dev/null 2>&1; then
    if podman compose version >/dev/null 2>&1; then
      return 0
    fi
    if command -v podman-compose >/dev/null 2>&1; then
      # Some distros ship podman-compose separately; still good enough.
      return 0
    fi
  fi
  return 1
}

case "$ENGINE" in
  podman)
    target="${here}/start-local-podman.sh"
    ;;
  docker)
    target="${here}/start-local-docker.sh"
    ;;
  auto)
    if use_podman; then
      target="${here}/start-local-podman.sh"
    else
      target="${here}/start-local-docker.sh"
    fi
    ;;
  *)
    echo "Unknown ENGINE='$ENGINE' (use podman|docker|auto)" >&2
    exit 1
    ;;
esac

if [ ! -x "$target" ]; then
  echo "Error: cannot execute $target" >&2
  echo "Make sure both scripts exist and are executable:" >&2
  echo "  chmod +x start-local-podman.sh start-local-docker.sh start-local.sh" >&2
  exit 1
fi

exec "$target" "$@"
