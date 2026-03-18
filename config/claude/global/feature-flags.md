# Feature Flags (Laravel Pennant)

When managing multiple in-progress features where some get approved before others:

- **New routes/endpoints** → Pennant + environment-scoped defaults. Sandbox = on, prod = off by default. Releasing = flip the flag, no redeploy needed.
- **Code changes/enhancements** → Strategy pattern. Bind an interface to old vs new implementation at the service provider level. Keep the flag check at the entry point, not scattered through logic.
- **Pure refactors with no user-visible surface** → Just ship them, no flag needed.

**Key rule:** Flags belong at the boundary (route, controller, service binding) — one check at the entry point, not ten checks deep in the code.

## Partial Refactors (Long Approval Cycles)

Extract the existing behavior behind an interface *first* (safe, ships immediately), then build the new implementation alongside it. The flag just swaps the binding in the service provider. Old code stays untouched and always runnable until the flag is flipped.

Ask: "Can I build the new behavior as a parallel implementation without modifying existing code?" If yes → strategy pattern. If no → restructure the refactor or accept branch management.

## Lifecycle & Hygiene

**Flags are intentional technical debt — delete them after release.**
Lifecycle: defined → sandbox → approved → prod → stable → deleted. Run `php artisan pennant:purge flag-name` to clean DB rows.

- Use **class-based features** (`app/Features/`) instead of closures in a service provider — each flag is its own file, grouped by domain (Billing/, Donations/, Admin/)
- Use a dedicated `FeatureFlagServiceProvider` if not using class-based features — never AppServiceProvider
- Name flags after the ticket: `tw-26191054-flagged-comments`
- Add `// @todo remove after release` near flag checks — keeps them searchable
- Review `app/Features/` each sprint — forces the "is this done?" conversation
- Add `pennant:prune` to the deployment pipeline
- Zombie flags (permanently true but never removed) are the main failure mode to avoid

## Flag Types

| Type | Example | Lifespan |
|---|---|---|
| Release flag | Approval workflow | Delete after release |
| Experiment flag | A/B test | Delete after experiment |
| Ops/kill switch | Disable 3rd party | Can be permanent |
| Entitlement flag | Premium features | Belongs in roles/permissions, not Pennant |
