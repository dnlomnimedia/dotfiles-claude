#!/bin/bash
# Dotfiles install script — runs automatically via VS Code dotfiles feature on container creation.
# Safe to re-run: symlinks are force-updated, git config only written if env vars are set.
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"

echo "→ Setting up dotfiles from $DOTFILES_DIR"

# --- Shell config symlinks ---
for file in .zshrc .aliases .functions .exports .vimrc .global-gitignore; do
    src="$DOTFILES_DIR/home/$file"
    dest="$HOME/$file"
    if [ -f "$src" ]; then
        ln -sf "$src" "$dest"
        echo "  linked $file"
    fi
done

# --- Git config ---
# Symlink the base config (no user info), then inject identity from env vars.
ln -sf "$DOTFILES_DIR/home/.gitconfig" "$HOME/.gitconfig"
echo "  linked .gitconfig"

if [ -n "${GIT_USER_NAME:-}" ]; then
    git config --global user.name "$GIT_USER_NAME"
    echo "  git user.name set to: $GIT_USER_NAME"
fi

if [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
    echo "  git user.email set to: $GIT_USER_EMAIL"
fi

# --- Claude Code config ---
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

# CLAUDE.md — global guidelines loaded every session
if [ -f "$DOTFILES_DIR/config/claude/CLAUDE.md" ]; then
    ln -sf "$DOTFILES_DIR/config/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "  linked CLAUDE.md"
fi

# settings.json — only write if not already present, to preserve any session-specific settings
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    ln -sf "$DOTFILES_DIR/config/claude/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  linked settings.json"
else
    echo "  settings.json already exists — skipping (delete to reset)"
fi

# statusline.sh — must be executable
if [ -f "$DOTFILES_DIR/config/claude/statusline.sh" ]; then
    cp "$DOTFILES_DIR/config/claude/statusline.sh" "$CLAUDE_DIR/statusline.sh"
    chmod +x "$CLAUDE_DIR/statusline.sh"
    echo "  installed statusline.sh"
fi

# Agents
for agent in "$DOTFILES_DIR/config/claude/agents/"*.md; do
    [ -f "$agent" ] || continue
    ln -sf "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
    echo "  linked agent: $(basename "$agent")"
done

# Skills
for skill_dir in "$DOTFILES_DIR/config/claude/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    ln -sf "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
    echo "  linked skill: $skill_name"
done

echo ""
echo "✓ Dotfiles setup complete."
echo ""
echo "Note: restart your shell or run 'source ~/.zshrc' to apply shell changes."

if [ -z "${GIT_USER_NAME:-}" ] || [ -z "${GIT_USER_EMAIL:-}" ]; then
    echo ""
    echo "⚠ Git identity not set. Add to devcontainer.json containerEnv:"
    echo '    "GIT_USER_NAME": "Your Name"'
    echo '    "GIT_USER_EMAIL": "you@example.com"'
fi
