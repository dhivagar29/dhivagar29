#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the dhivagar29 profile README repo.
# Installs the two external tools the CI pipeline uses (lychee + markdownlint-cli2)
# so the same checks can run locally.
set -euo pipefail

LYCHEE_VERSION="0.24.2"
INSTALL_DIR="/usr/local/bin"

current_lychee_version() {
  command -v lychee >/dev/null 2>&1 || return 1
  lychee --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}

if [ "$(current_lychee_version || true)" != "$LYCHEE_VERSION" ]; then
  echo "Installing lychee v${LYCHEE_VERSION}..."
  tmp="$(mktemp -d)"
  curl -fsSL \
    "https://github.com/lycheeverse/lychee/releases/download/lychee-v${LYCHEE_VERSION}/lychee-x86_64-unknown-linux-gnu.tar.gz" \
    -o "$tmp/lychee.tar.gz"
  tar -xzf "$tmp/lychee.tar.gz" -C "$tmp" --strip-components=1 "lychee-x86_64-unknown-linux-gnu/lychee"
  sudo install -m 0755 "$tmp/lychee" "$INSTALL_DIR/lychee"
  rm -rf "$tmp"
else
  echo "lychee v${LYCHEE_VERSION} already installed; skipping."
fi

echo "lychee: $(lychee --version)"

echo "Installing Node dependencies..."
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

echo "markdownlint-cli2: $(npx --no-install markdownlint-cli2 --version)"
echo "Bootstrap complete."
