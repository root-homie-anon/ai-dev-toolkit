#!/usr/bin/env bash
# ============================================================
# KeyMaster — migrate-vault.sh
# Migrates vault.json and config.json from another machine.
# Usage:
#   Option A (SCP):   bash migrate-vault.sh scp user@old-machine
#   Option B (file):  bash migrate-vault.sh file /path/to/vault.json
#   Option C (USB):   bash migrate-vault.sh file /media/usb/.keys/vault.json
# ============================================================

set -euo pipefail

KEYS_DIR="${HOME}/.keys"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

success() { echo -e "${GREEN}[ok]${RESET}    $1"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}  $1"; }

echo ""
echo -e "${BOLD}KeyMaster — Vault Migration${RESET}"
echo ""

mkdir -p "$KEYS_DIR"

MODE="${1:-}"
SOURCE="${2:-}"

if [[ -z "$MODE" ]]; then
  echo "Usage:"
  echo "  bash migrate-vault.sh scp user@old-machine    # Pull via SSH"
  echo "  bash migrate-vault.sh file /path/to/vault.json # Copy from local path"
  echo ""
  echo "Examples:"
  echo "  bash migrate-vault.sh scp me@192.168.1.50"
  echo "  bash migrate-vault.sh file /media/usb/.keys/vault.json"
  echo "  bash migrate-vault.sh file ~/Downloads/vault.json"
  exit 1
fi

# Back up existing vault if present
if [[ -f "${KEYS_DIR}/vault.json" ]]; then
  BACKUP="${KEYS_DIR}/vault.json.bak.$(date +%s)"
  cp "${KEYS_DIR}/vault.json" "$BACKUP"
  warn "Existing vault backed up to: $BACKUP"
fi

case "$MODE" in
  scp)
    if [[ -z "$SOURCE" ]]; then
      echo "Error: provide user@host, e.g.: bash migrate-vault.sh scp me@old-machine"
      exit 1
    fi
    echo "Pulling vault from ${SOURCE}..."
    scp "${SOURCE}:~/.keys/vault.json" "${KEYS_DIR}/vault.json"
    scp "${SOURCE}:~/.keys/config.json" "${KEYS_DIR}/config.json" 2>/dev/null || true
    ;;
  file)
    if [[ -z "$SOURCE" || ! -f "$SOURCE" ]]; then
      echo "Error: file not found: ${SOURCE}"
      exit 1
    fi
    cp "$SOURCE" "${KEYS_DIR}/vault.json"
    # Try to grab config.json from same directory
    SRCDIR="$(dirname "$SOURCE")"
    if [[ -f "${SRCDIR}/config.json" ]]; then
      cp "${SRCDIR}/config.json" "${KEYS_DIR}/config.json"
    fi
    ;;
  *)
    echo "Unknown mode: $MODE (use 'scp' or 'file')"
    exit 1
    ;;
esac

chmod 600 "${KEYS_DIR}/vault.json"
chmod 600 "${KEYS_DIR}/config.json" 2>/dev/null || true

success "Vault migrated to ${KEYS_DIR}/vault.json"

# Count keys
if command -v jq &>/dev/null; then
  KEY_COUNT=$(jq 'length' "${KEYS_DIR}/vault.json" 2>/dev/null || echo "?")
  echo ""
  echo "  Keys in vault: ${KEY_COUNT}"
fi

echo ""
echo "  Next: run 'keymaster status' to verify"
echo "  Then: run 'keymaster sync' to generate .env files for your projects"
echo ""
