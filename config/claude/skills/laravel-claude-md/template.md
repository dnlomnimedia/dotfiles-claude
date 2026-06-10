# {Project Name}

{2–3 sentences: what the app does, the business domain in plain language, who
consumes it. Claude cannot infer "LOM = Luminate Online Middleware" from code.}

## Stack

- PHP {8.3+}, Laravel {12.x} (conventions forward-compatible with 13.x)
- {MySQL 8 / Postgres}, cache: {database/redis}, queue: {database/redis}
- Frontend: {none — API only / Inertia + Vue / Livewire / Blade}
- Local dev: {Lando/Herd/Docker} — ALL php/composer/artisan commands run as `{lando} php ...`

## Commands

- Test (filtered): `{lando} php artisan test --compact --filter={name}` — full suite only on request
- Format: `vendor/bin/pint --dirty` (Pint is the source of truth for style; never hand-fix formatting)
- Static analysis: `vendor/bin/phpstan analyse`
- Dev server: `composer run dev`

## Architecture

- Request lifecycle: Route → FormRequest → thin Controller → Action/Service → Eloquent
- {Project-specific decisions only, e.g.: "Sky API routes registered by the
  dnl-omnimedia package; middleware attached post-boot in AppServiceProvider"}
- Slim skeleton: middleware/exceptions in `bootstrap/app.php`, providers in
  `bootstrap/providers.php`, scheduling in `routes/console.php`. No Http/Console Kernels.

## Conventions

- Follow Spatie PHP/Laravel guidelines (activate `php-guidelines-from-spatie`).
  Where Spatie and Laravel/Boost conventions conflict, follow the Laravel
  convention (singular controllers, dot-notation route names).
- Generate files with `php artisan make:* --no-interaction`; every new model gets a factory
- Models: `casts()` method over `$casts` property; always set `$fillable` or `$guarded`
- Validation in Form Request classes; consume only `$request->validated()`, never `$request->all()`
- Authorize every action via policies; `config()` never `env()` outside config files
- Eloquent over `DB::`; eager load (`with()`, `withCount()`); no queries in Blade
- APIs: Eloquent API Resources + named routes + implicit route model binding
- Cache plain arrays/scalars, not objects (Laravel 13 refuses to unserialize objects by
  default); `Cache::remember()` over get/put; `Cache::lock()` for races
- Queues: every job defines `failed()`; `ShouldDispatchAfterCommit` when dispatching inside
  transactions; explicit `timeout`/`retry` config
- HTTP client: always set `timeout`; `Http::preventStrayRequests()` in tests
- Use `Arr::`/`Str::` support classes, never global `array_*`/`str_*` helpers
- Migrations: `constrained()` for FKs; when modifying a column, restate ALL prior attributes;
  never edit a migration that has run in production

## Testing

- Every change must be programmatically tested — write or update a test, run the affected
  tests, and do not report done until they pass
- Pest feature tests by default; use factories (check for existing states before manual setup)
- `LazilyRefreshDatabase` over `RefreshDatabase`; fakes set up after factories
- Never delete, skip, or weaken a failing test to get green

## Feature flags

- Laravel Pennant, class-based features in `app/Features/`, named after the ticket
  (`tw-12345678-feature-name`); flag checks at the boundary (route/controller/binding) only;
  delete after release

## Don't

- Don't add or change composer/npm dependencies without asking
- Don't run destructive DB operations (migrate:fresh, db:wipe) without explicit consent
- Don't create docs/README files unless asked
- {Project gotchas, e.g.: "phpunit.xml sets RESPONSE_CACHE_ENABLED=false — leave it"}
