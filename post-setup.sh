#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — post-setup.sh
# Run INSIDE a Claude Code session after initial-setup.sh.
# Installs tools that require the CC plugin system.
# Usage: bash ~/ai-dev-toolkit/post-setup.sh
# ============================================================

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         ai-dev-toolkit  Post-Setup Instructions         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Run the following commands inside your Claude Code session:"
echo ""
echo "── 1. claude-mem (persistent memory) ────────────────────"
echo ""
echo "  /plugin marketplace add thedotmack/claude-mem"
echo "  /plugin install claude-mem"
echo ""
echo "── 2. everything-claude-code (ECC hooks + commands) ──────"
echo ""
echo "  /plugin marketplace add affaan-m/everything-claude-code"
echo "  /plugin install everything-claude-code@everything-claude-code"
echo ""
echo "── 3. Verify all plugins loaded ──────────────────────────"
echo ""
echo "  /plugin list"
echo ""
echo "── 4. Verify GSD installed ───────────────────────────────"
echo ""
echo "  /gsd:help"
echo ""
echo "─────────────────────────────────────────────────────────"
echo ""
echo "After completing the above, your toolkit is fully active."
echo ""
echo "Hook load order (all handled automatically):"
echo "  1. Agent Factory  → session-start, agent creation"
echo "  2. ECC            → code quality, security hooks"
echo "  3. GSD            → context engineering hooks"
echo "  4. claude-mem     → session memory capture"
echo ""
