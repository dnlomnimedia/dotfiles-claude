---
name: laravel-claude-md
description: Scaffold project AI guidelines for a Laravel app from the personal template — writes CLAUDE.md, or .ai/guidelines/project.md when Laravel Boost is installed. Use when the user asks to set up, initialize, scaffold, or regenerate CLAUDE.md / AI guidelines in a Laravel project.
---

# Laravel CLAUDE.md Scaffold

Scaffold project guidelines from `template.md` in this skill's directory.
Defaults to Laravel 12 conventions that remain valid in Laravel 13.

## Steps

1. **Decide placement.** Check `composer.json` for `laravel/boost` (and whether
   a `.ai/` directory exists):
   - **Boost installed** → write the filled template to `.ai/guidelines/project.md`
     and run `php artisan boost:update` so it composes into the generated
     CLAUDE.md. Never hand-edit a Boost-generated CLAUDE.md.
   - **No Boost** → write the filled template to `CLAUDE.md` at the repo root.
     Suggest installing Boost (`composer require laravel/boost --dev &&
     php artisan boost:install`) but don't do it unprompted.

2. **Fill placeholders by inspecting the project — never invent facts:**
   - `composer.json`: PHP and Laravel version constraints, notable packages
     (Pennant, Horizon, Sanctum, vendor packages worth naming in Architecture)
   - `.lando.yml` / `docker-compose.yml` / Herd: dev environment and the
     command prefix for php/composer/artisan (e.g. `lando php artisan test`)
   - `config/database.php`, `config/cache.php`, `config/queue.php` + `.env.example`:
     DB engine, cache driver, queue driver
   - `package.json` / `composer.json`: frontend stack (Inertia, Livewire, none)
   - `phpunit.xml` / `tests/Pest.php`: Pest vs PHPUnit, env overrides worth
     listing as gotchas
   - `app/` and `routes/`: actual request lifecycle (Actions? Services?
     package-registered routes?) — describe what exists, not the template default

3. **Prune.** Delete sections that don't apply (e.g. Feature flags when Pennant
   isn't installed, frontend lines for API-only apps). Replace unresolvable
   placeholders with a `<!-- TODO: ... -->` comment rather than guessing.
   Target under 100 lines — adherence degrades past that.

4. **Existing CLAUDE.md?** Don't overwrite. Merge: keep existing
   project-specific facts, adopt the template's structure and rules, and show
   the user what changed.

## Rules baked into the template (don't remove)

- Boost/Laravel conventions win over Spatie where they conflict
- Every change must be programmatically tested before reporting done
- Pint owns formatting; `config()` not `env()`; Form Requests for validation
- Cache plain arrays, not objects (Laravel 13 default)
