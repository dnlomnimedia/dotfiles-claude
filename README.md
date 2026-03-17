# dotfiles-claude

Shell config, Claude Code settings, skills, and agents — optimized for Laravel/PHP/Vue development inside VS Code devcontainers.

Forked from [freekmurze/dotfiles](https://github.com/freekmurze/dotfiles), stripped of macOS-specific tooling, and adapted for Linux devcontainer use.

---

## What's Included

### Shell & Prompt

- **Oh My Zsh** with custom Agnoster theme (powerline prompt, `•` for unstaged changes)
- **zoxide** — smart `cd` with frecency-based directory jumping
- **fzf** — fuzzy finder for files and command history (`Ctrl+R`, `Ctrl+T`, `Alt+C`)
- **zsh-autosuggestions** — fish-style command suggestions

### Modern CLI Tools

- **bat** — `cat` with syntax highlighting (aliased as `cat`)
- **eza** — modern `ls` with git status and tree view
- **ripgrep** — fast grep, respects `.gitignore`
- **git-delta** — side-by-side diffs with syntax highlighting
- **jq** — JSON processor

> These are all installed in the base devcontainer image (`laravel-devcontainer`). The dotfiles just configure them.

### Claude Code

- `CLAUDE.md` — global coding guidelines loaded every session
- `settings.json` — pre-approved permissions, `acceptEdits` mode, thinking enabled
- `agents/` — version-controlled custom agents (laravel-feature-builder, etc.)
- `skills/` — version-controlled skills (php-guidelines-from-spatie, ray-skill, etc.)
- `statusline.sh` — custom status line script

---

## How It Works

The VS Code dotfiles feature clones this repo to `~/.dotfiles` inside the container and runs `install.sh` automatically on container creation.

`install.sh` symlinks shell config files from `~/.dotfiles/home/` to `~/` and copies Claude Code config to `~/.claude/`.

---

## Setup

### 1. VS Code User Settings

Add to your VS Code user `settings.json`:

```json
"dotfiles.repository": "https://github.com/dnlomnimedia/dotfiles-claude",
"dotfiles.installCommand": "install.sh",
"dotfiles.targetPath": "~/.dotfiles"
```

### 2. Git Identity via Host Environment

Set your identity once in `~/.zshenv` on your Mac (not `~/.zshrc` — VS Code reads the environment without a shell session):

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="you@example.com"
```

Then reference them in each project's `devcontainer.json` using `${localEnv:}`:

```json
"containerEnv": {
    "GIT_USER_NAME": "${localEnv:GIT_USER_NAME}",
    "GIT_USER_EMAIL": "${localEnv:GIT_USER_EMAIL}"
}
```

The values are defined once on the host — `devcontainer.json` never contains personal data. A warning is shown at install time if the variables aren't set.

### 3. Rebuild the Container

The dotfiles install runs automatically on the next `Rebuild Container`. No manual steps needed after that.

---

## What Gets Symlinked

| File | Source |
|------|--------|
| `~/.zshrc` | `home/.zshrc` |
| `~/.aliases` | `home/.aliases` |
| `~/.functions` | `home/.functions` |
| `~/.exports` | `home/.exports` |
| `~/.gitconfig` | `home/.gitconfig` |
| `~/.global-gitignore` | `home/.global-gitignore` |
| `~/.vimrc` | `home/.vimrc` |
| `~/.claude/CLAUDE.md` | `config/claude/CLAUDE.md` |
| `~/.claude/agents/*.md` | `config/claude/agents/` |
| `~/.claude/skills/*/` | `config/claude/skills/` |

`settings.json` is only written if it doesn't already exist (preserves any session-specific settings).

`statusline.sh` is copied (not symlinked) so it can be made executable without touching the repo.

---

## Local Overrides

Shell config that you don't want committed:

```bash
mkdir -p ~/.dotfiles-custom/shell
# Then create any of:
~/.dotfiles-custom/shell/.aliases
~/.dotfiles-custom/shell/.functions
~/.dotfiles-custom/shell/.exports
~/.dotfiles-custom/shell/.zshrc
```

These are sourced by `.zshrc` if they exist.

---

## Key Aliases

```bash
# Laravel
a           # php artisan
p           # ./vendor/bin/pest
c           # composer
mfs         # migrate:fresh --seed
tinker      # php artisan tinker

# npm / Vite
nr          # npm run
nrd         # npm run dev
nrb         # npm run build

# Git
nah         # git reset --hard; git clean -df
gst         # git status
gl          # git log (pretty)
```

---

## Daily Usage

### Laravel / PHP

```bash
a                           # php artisan
a migrate                   # php artisan migrate
a tinker                    # php artisan tinker
mfs                         # php artisan migrate:fresh --seed

p                           # run Pest or PHPUnit (auto-detects)
p --filter=UserTest         # run a specific test file
pf "creates a user"         # run tests matching a name

phpunit                     # vendor/bin/phpunit (explicit)
pp                          # php artisan test --parallel

ci                          # composer install
cu                          # composer update
cr vendor/package           # composer require
cda                         # composer dump-autoload -o

scheduler                   # run artisan schedule:run in a 60s loop
```

### Database (MySQL in container)

```bash
db list                     # show all databases
db create mydb              # create a database
db drop mydb                # drop a database
db refresh mydb             # drop + recreate in one step

flush-redis                 # redis-cli FLUSHALL
```

The `db` function connects to `$DB_HOST` (defaults to `db` — the Docker Compose service name).

### Git

```bash
commit                      # stage everything + generate commit message via Claude
commit "my message"         # stage everything + commit with given message
uncommit                    # undo last commit, keep changes staged (git reset --soft HEAD~1)
nah                         # nuclear reset — discard all uncommitted changes
gpo branch-name             # git push origin branch-name
git-prune-local             # delete local branches whose remote is gone
```

### JavaScript / npm

```bash
nr script-name              # npm run
nrd                         # npm run dev
nrb                         # npm run build
jest                        # ./node_modules/.bin/jest
```

### Claude Code

```bash
c                           # claude (standard mode)
cy                          # claude --dangerously-skip-permissions (skip all prompts)
```

### Navigation

```bash
z project-name              # jump to a frecently used directory
zi                          # interactive directory picker (fzf)
mkd new-dir                 # mkdir -p + cd in one step

Ctrl+R                      # fuzzy search command history
Ctrl+T                      # fuzzy find files in current directory
Alt+C                       # fuzzy change directory
```

Zoxide learns from your `cd` usage. The more you visit a directory, the higher it ranks. `z` matches against the full path, so `z mid` could jump to `~/projects/middleware` if you've been there recently.

### File Browsing

```bash
ls                          # eza with icons, directories first
ll                          # eza long list with icons
l                           # eza long list with hidden files and hyperlinks
lt                          # eza tree view, 2 levels deep
cat file.php                # bat with syntax highlighting (aliased)
grep pattern                # ripgrep (aliased, respects .gitignore)
```

### Utilities

```bash
clone owner/repo            # gh repo clone (shorthand)
digga example.com           # all DNS records for a domain
removehost hostname         # remove a host from ~/.ssh/known_hosts
ip                          # show your current public IP
```

### Zsh Autosuggestions

As you type, grey suggestions appear based on history. Press `→` (right arrow) to accept the full suggestion, or `Alt+→` to accept one word at a time.

### Local Overrides

Shell config you don't want committed:

```bash
mkdir -p ~/.dotfiles-custom/shell
# Create any of:
~/.dotfiles-custom/shell/.aliases
~/.dotfiles-custom/shell/.functions
~/.dotfiles-custom/shell/.exports
~/.dotfiles-custom/shell/.zshrc
```

These are sourced automatically by `.zshrc` if they exist.

---

## Agnoster Theme

Custom theme stored in `oh-my-zsh-custom/themes/agnoster.zsh-theme`.

**Git status symbols:**
- `✚` — staged changes
- `•` — unstaged changes
- Yellow background — uncommitted changes
- Green background — clean

Requires a font with Powerline glyphs (e.g. a Nerd Font). Set your terminal font in VS Code's `terminal.integrated.fontFamily`.

---

## Claude Code Skills

Stored in `config/claude/skills/` — available in every project automatically.

| Skill | Purpose |
|-------|---------|
| `php-guidelines-from-spatie` | Spatie PHP/Laravel coding standards |
| `ray-skill` | Ray debugging integration |
| `fix-github-issue` | GitHub issue automation |
| `context7-auto-research` | Auto-fetch library docs via Context7 |
| `agent-browser` | Browser automation |
| `review-pr` | PR review workflow |
| `frontend-design` | Frontend design patterns |
| `web-design-guidelines` | Web design best practices |
| `pdf` | PDF manipulation |
| `flare` | Flare error tracking integration |
| `spatie-package-skeleton` | Scaffold new Spatie packages |

---

## Claude Code Agents

Stored in `config/claude/agents/`:

| Agent | Purpose |
|-------|---------|
| `laravel-feature-builder` | Full feature implementation (models, controllers, migrations, views) |

---

## Credits

Original dotfiles by [Freek Van der Herten](https://github.com/freekmurze) / [Spatie](https://spatie.be).
