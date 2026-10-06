# Architecture Journal

## Finding

### Context
Stage 0 baseline for a new SwiftUI learning laboratory.

### Decision / observation
The project starts as a single app target with no package dependencies and no test targets. We introduced a minimal in-app `CatalogView` with local `Item` data, simple loading state, and an async loading path to create realistic pressure for future boundary decisions.

### Benefits
- Keeps initial complexity low while enabling immediate architectural experiments.
- Establishes a concrete feature surface (`Catalog`) for future extraction.
- Provides deterministic SwiftUI previews inside the app target.

### Costs
- No compile-time boundaries yet.
- Feature behavior, state, and view all live in the app module.
- No module-level test surface yet.

### Reconsider when
- Catalog gains dependencies that make previews or tests hard to run.
- Another feature appears and shared ownership questions become explicit.

### Publication candidate
A small, realistic feature baseline makes later dependency and rebuild observations easier to attribute than starting from either a toy screen or a heavily pre-modularized graph.

## Finding

### Context
Stage 1 focused on the compiler/build-system mental model: package, product, target, and Swift module.

### Decision / observation
We created folder-style feature paths inside the app target (`Features/Profile`) and confirmed `CatalogView` can use `ProfileMarketingCopy` with no import boundary. This demonstrates folders are organizational only when code still compiles in a single target/module.

We also added a tiny local Swift package at `Packages/ModuleBoundaryLab` with:
- package: `ModuleBoundaryLab`
- product: `BoundaryKit`
- targets: `BoundaryKit` depends on `BoundarySupport`

Inside that package, `BoundaryKit` imports `BoundarySupport`, making the dependency explicit in `Package.swift` and source imports.

### Benefits
- Clarifies that compile-time boundaries come from targets/modules, not folder names.
- Makes package/product/target/module roles concrete with a minimal manifest.
- Establishes a safe sandbox package for later access-control and API-surface experiments.

### Costs
- Introduces one extra manifest to maintain.
- Adds conceptual overhead before any production-value feature extraction.

### Reconsider when
- The package no longer serves learning experiments and becomes dead structure.
- We are ready to extract a real app-owned feature or UI boundary into a package target.

### Publication candidate
A side-by-side demonstration that `Features/*` folders do not create compiler boundaries, while a tiny multi-target package does, is a useful myth-busting section for architecture education.

## Finding

### Context
Stage 2 examined API boundaries and access control using the first local package (`ModuleBoundaryLab`) and a separate consumer package (`ModuleBoundaryClient`).

### Decision / observation
We moved `BadgeTemplate` into `BoundarySupport` and consumed it from `BoundaryKit`, forcing explicit cross-target visibility decisions.

Final access-level shape:
- `private`: implementation helper (`NameFormatting.normalize`) and stored property encapsulation (`CatalogBadgeBuilder.template`)
- `fileprivate`: file-local constants (`NameFormatting.trimmingSet`, `BadgeTemplate.separator`)
- `internal`: `CatalogBadgeDefaults` in `BoundaryKit` (module-only)
- `package`: `BoundarySupport` API used by `BoundaryKit` (`NameFormatting`, `BadgeTemplate`)
- `public`: only the consumer-facing `BoundaryKit` API (`CatalogBadgeBuilder` initializers and `badgeText`)

During the experiment, a `public init(prefix: String = CatalogBadgeDefaults.prefix)` failed to compile because a public default argument cannot reference internal symbols. We refactored to two public initializers (`init()` and `init(prefix:)`) so internal defaults stay internal.

The external consumer package (`ModuleBoundaryClient`) imports only `BoundaryKit` and runs successfully, proving the minimal public surface is sufficient.

### Benefits
- Makes boundary decisions explicit and compiler-enforced.
- Uses `package` to share implementation details across targets without leaking them as `public` API.
- Keeps external API intentionally small while preserving internal flexibility.

### Costs
- Requires deliberate API design even for tiny modules.
- Public signatures can accidentally leak lower-access symbols (for example via default arguments).
- Adds overhead to change API shape once other targets consume it.

### Reconsider when
- Multiple package-external consumers need additional API and current `public` surface is too narrow.
- `BoundarySupport` semantics need to be consumed directly outside the package (which may justify a new product or different ownership).

### Publication candidate
A concrete compile-time failure caused by referencing an internal symbol from a public default argument is a strong demonstration that modularization converts implicit assumptions into explicit, enforceable API contracts.

## Finding

### Context
Stage 3 introduced the first reusable UI boundary with a real module: `DesignSystem`.

### Decision / observation
We created a local package `Packages/DesignSystem` with a single `DesignSystem` target/product and added small UI primitives (`AppButton`, `Card`, `Badge`) plus spacing tokens (`AppSpacing`).

The app target now imports `DesignSystem` and uses these primitives in `CatalogView`. This moved reusable presentation details out of the app target while keeping feature state/loading behavior inside the feature screen.

We also added package-local previews inside `DesignSystem` for each primitive. This gives a module-scoped preview surface that does not require app composition.

Scope boundary captured for now:
- belongs in `DesignSystem`: reusable visual primitives, styling defaults, spacing tokens
- does not belong in `DesignSystem`: feature state, domain models, network/persistence concerns, feature workflows

### Benefits
- Establishes a genuine reusable compile-time boundary consumed by the app.
- Enables primitive-level previews in the module that owns the UI contracts.
- Reduces UI duplication pressure without prematurely creating large shared modules.

### Costs
- Adds package maintenance overhead and one extra dependency edge into the app.
- Introduces API surface decisions for even small UI components.
- Can drift into a dumping ground if ownership rules are not enforced.

### Reconsider when
- Feature-specific UI starts leaking into shared primitives.
- Tokens/components diverge by feature context and shared abstractions become constraining.
- Build or preview behavior indicates the module is accumulating unrelated dependencies.

### Publication candidate
A small, opinionated `DesignSystem` extracted early is useful when it stays primitive-focused; showing where we intentionally stop (no feature logic, no domain) is as important as showing what we extracted.
