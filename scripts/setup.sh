#!/usr/bin/env bash
# Builds and runs Bull from source: install, build, test, check the example app and start it.
#
#   ./scripts/setup.sh --repo ../bull            # a local clone
#   ./scripts/setup.sh --repo https://github.com/<you>/bull.git
#   ./scripts/setup.sh --repo ../bull --e2e --no-dev
#   ./scripts/setup.sh --help

set -euo pipefail

REPO="${BULL_REPO:-}"
E2E=0
DEV=1
DRY_RUN=0
CLONE_DIR=".bull"

usage() {
  cat <<'EOF'
Usage: scripts/setup.sh --repo <path-or-git-url> [options]

Builds the Bull monorepo, runs its tests, checks the example app and starts it.

Options:
  --repo <path|url>   Local path to the Bull repository, or a git URL to clone
                      (also read from the BULL_REPO environment variable)
  --dir <path>        Where to clone a git URL (default: .bull)
  --e2e               Also run the end-to-end tests of the CLI binary
  --no-dev            Do not start the example app's dev server at the end
  --dry-run           Print the commands without running them
  -h, --help          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --dir) CLONE_DIR="${2:-}"; shift 2 ;;
    --e2e) E2E=1; shift ;;
    --no-dev) DEV=0; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "✗ Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\n\033[35m♉\033[0m \033[1m%s\033[0m\n' "$*"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  printf '  \033[2m$ %s\033[0m\n' "$*"
  if [[ "$DRY_RUN" -eq 0 ]]; then "$@"; fi
}

run_in() {
  local dir="$1"; shift
  printf '  \033[2m$ (cd %s && %s)\033[0m\n' "$dir" "$*"
  if [[ "$DRY_RUN" -eq 0 ]]; then (cd "$dir" && "$@"); fi
}

[[ -n "$REPO" ]] || { usage >&2; echo >&2; fail "Pass --repo <path-or-git-url> (or set BULL_REPO)."; }

bold "Bull setup"

step "Checking the toolchain"
command -v node >/dev/null 2>&1 || fail "Node.js is not installed. Install Node.js 20 or newer."
command -v npm >/dev/null 2>&1 || fail "npm is not installed."
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[[ "$NODE_MAJOR" -ge 20 ]] || fail "Node.js $(node -v) is too old. Bull needs Node.js 20 or newer."
echo "  ✓ node $(node -v), npm $(npm -v)"

step "Locating the Bull repository"
if [[ "$REPO" =~ ^(https?://|git@|ssh://) ]]; then
  if [[ -d "$CLONE_DIR/.git" ]]; then
    echo "  ✓ already cloned in $CLONE_DIR"
  else
    command -v git >/dev/null 2>&1 || fail "git is needed to clone $REPO."
    run git clone --depth 1 "$REPO" "$CLONE_DIR"
  fi
  ROOT="$CLONE_DIR"
else
  [[ -d "$REPO" ]] || fail "$REPO does not exist."
  ROOT="$REPO"
fi
if [[ "$DRY_RUN" -eq 0 ]]; then
  [[ -f "$ROOT/packages/cli/package.json" ]] || fail "$ROOT does not look like the Bull repository (packages/cli is missing)."
fi
echo "  ✓ $ROOT"

step "Installing dependencies"
if [[ -f "$ROOT/package-lock.json" ]]; then run_in "$ROOT" npm ci; else run_in "$ROOT" npm install; fi

step "Building the packages"
run_in "$ROOT" npm run build

step "Running the unit tests"
run_in "$ROOT" npm test

if [[ "$E2E" -eq 1 ]]; then
  step "Running the end-to-end tests"
  run_in "$ROOT" npx vitest run -c vitest.e2e.config.ts
fi

step "Checking the example app's architecture"
run_in "$ROOT" node packages/cli/dist/bin.js check examples/todo-app

if [[ "$DEV" -eq 1 ]]; then
  step "Starting the example app (Ctrl+C to stop)"
  run_in "$ROOT/examples/todo-app" npm run dev
else
  printf '\n\033[32m✓\033[0m Done. Start the example with: (cd %s/examples/todo-app && npm run dev)\n' "$ROOT"
fi
