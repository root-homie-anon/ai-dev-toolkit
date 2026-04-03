# ai-dev-toolkit — bashrc additions
# Sourced by initial-setup.sh. Appended to ~/.bashrc idempotently.

# PATH — ensure ~/bin and ~/.local/bin are available
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Claude Code quick-launch aliases
alias cc='bash ~/.claude/hooks/session-start.sh "$(basename $(pwd))" "$(pwd)" && claude'
alias ccnew='bash ~/.claude/hooks/session-start.sh "$(basename $(pwd))" "$(pwd)" && claude'
