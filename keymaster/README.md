# KeyMaster

Centralized API key management for local development. Single vault, per-project `.env` file generation.

## Install

The `initial-setup.sh` script installs KeyMaster to `~/bin/keymaster` automatically.

## Migrating from Another Machine

Your vault contains all your API keys — it doesn't go in the public repo. To move it to a new machine:

```bash
# Option A: Pull from old machine via SSH
bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine

# Option B: Copy from a file (USB, download, etc.)
bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh file /path/to/vault.json
```

After migration, sync your project `.env` files:
```bash
keymaster sync
```

## Quick Reference

| Task | Command |
|---|---|
| Dashboard | `keymaster status` |
| List all keys | `keymaster list` (add `--project X` or `--shared` to filter) |
| Show a key value | `keymaster get KEY_NAME --unmask` |
| Add a key | `keymaster add KEY_NAME` (interactive) |
| Rotate a key | `keymaster rotate KEY_NAME` |
| Sync .env files | `keymaster sync [PROJECT]` |
| Security audit | `keymaster audit` |
| Rotation history | `keymaster history [KEY]` |
| Project needs keys | `keymaster require PROJECT KEY1 KEY2...` |
| Check requirements | `keymaster check [PROJECT]` |
| Key alias | `keymaster alias VAULT_KEY ALIAS_NAME PROJECT` |

## How It Works

- `~/.keys/vault.json` is the single source of truth for all API keys
- `keymaster sync` generates `.env` files for each project from the vault
- `keys.json` in a project root declares which keys it needs (safe to commit)
- Never edit `.env` files directly — always go through keymaster

## Rules

- Run `keymaster audit` after any key changes
- Never commit vault.json or .env files
- Use `keymaster require` when a project needs a shared key
- Use `keymaster alias` when a project expects a different env var name
