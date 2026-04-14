#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This setup script is for macOS only."
    exit 0
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
    cat <<'EOF'
Homebrew is required before Conductor can bootstrap this workspace.
Install it once, then recreate the workspace:
  https://brew.sh
EOF
    exit 1
fi

export HOMEBREW_NO_AUTO_UPDATE="${HOMEBREW_NO_AUTO_UPDATE:-1}"

required_formulae=(
    colima
    docker
    docker-buildx
    gh
    hadolint
    jq
    ripgrep
    shellcheck
)

missing_formulae=()
for formula in "${required_formulae[@]}"; do
    if ! brew list --formula "$formula" >/dev/null 2>&1; then
        missing_formulae+=("$formula")
    fi
done

if ((${#missing_formulae[@]} > 0)); then
    echo "Installing Homebrew formulae: ${missing_formulae[*]}"
    brew install "${missing_formulae[@]}"
fi

mkdir -p "$HOME/.docker"

python3 <<'PY'
import json
from pathlib import Path

config_path = Path.home() / ".docker" / "config.json"
data = {}

if config_path.exists():
    try:
        data = json.loads(config_path.read_text())
    except json.JSONDecodeError:
        data = {}

plugin_dir = "/opt/homebrew/lib/docker/cli-plugins"
extra_dirs = data.get("cliPluginsExtraDirs", [])
if plugin_dir not in extra_dirs:
    extra_dirs.append(plugin_dir)
data["cliPluginsExtraDirs"] = extra_dirs

config_path.write_text(json.dumps(data, indent=2) + "\n")
PY

if ! colima status >/dev/null 2>&1; then
    echo "Starting Colima"
    colima start \
        --cpu "${CONDUCTOR_COLIMA_CPU:-4}" \
        --memory "${CONDUCTOR_COLIMA_MEMORY:-8}" \
        --disk "${CONDUCTOR_COLIMA_DISK:-60}"
fi

docker context use colima >/dev/null 2>&1 || true

echo "Tooling ready:"
echo "  brew:    $(brew --version | head -n 1)"
echo "  docker:  $(docker --version)"
echo "  buildx:  $(docker buildx version)"
echo "  colima:  $(colima version | head -n 1)"
echo "  rg:      $(rg --version | head -n 1)"
echo "  jq:      $(jq --version)"
echo "  gh:      $(gh --version | head -n 1)"
echo "  hadolint:$(hadolint --version | head -n 1)"
echo "  shellcheck: $(shellcheck --version | awk '/^version:/ {print $2}')"
