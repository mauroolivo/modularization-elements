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

## Finding

### Context
Stage 4: Preview Isolation as an Architectural Signal

We introduced `CatalogRepository` protocol and `Item` to the app target to simulate realistic infrastructure concerns (future Networking, Persistence, Analytics dependencies). We kept DesignSystem primitives (Badge, Card, AppButton) completely isolated with no infrastructure imports.

### Decision / observation
Preview isolation is not automatic from package structure. It is a **direct consequence of the dependency graph**.

A `Badge` preview in DesignSystem compiles only DesignSystem, SwiftUI, and Foundation. A `CatalogView` preview in the app compiles the entire app target including Item, CatalogState, CatalogRepository, and all DesignSystem dependencies.

The architectural boundary is not "package = fast, app = slow." The boundary is "what does this module's import graph require."

### Benefits
- Preview build time directly reflects architectural decisions.
- A slow preview is a signal: the module has too many dependencies for its responsibility.
- Fast, isolated previews become an architectural constraint: keep primitives truly primitive.
- We can measure whether modularization actually improves preview performance (empirically, not by assumption).

### Costs
- A module that appears isolated (lives in Packages/) can still have a slow preview if its internal dependencies are heavy.
- Requires discipline to keep low-level modules truly low-level.
- If feature modules import infrastructure, preview isolation is lost immediately.

### Reconsider when
- A supposedly-isolated module's preview becomes slow (signals hidden dependencies).
- A feature preview requires booting unrelated infrastructure (signals coupling).
- Build times suggest the dependency graph has drifted from intention.

### Publication candidate
**"Preview performance as an architectural signal"** — The observation that preview compile time directly reveals module dependencies. A comparison before/after adding infrastructure to a module demonstrates this. This is useful teaching material because it's measurable and intuitive.


## Finding

### Context
Stage 5 extracted the catalog screen into a real vertical feature module: `CatalogFeature`.

### Decision / observation
We moved `CatalogView`, catalog state, `Item`, repository abstractions, and feature-local preview fixtures into `Packages/CatalogFeature`. The app target now imports `CatalogFeature` and hosts only composition (`ContentView`), while the feature module owns the screen, loading flow, and previews.

Current dependency diagram:
```text
modularization-elements app target
└── imports CatalogFeature
    └── CatalogFeature
        ├── CatalogView (public entry point)
        ├── Item / CatalogState / CatalogRepository (internal)
        └── imports DesignSystem
```

The public surface stays intentionally small: the app uses `CatalogView()` and the module keeps helpers and state private/internal. Feature previews now live directly in `CatalogFeature` and can be built without importing the executable app target.

### Benefits
- Creates the first real reusable feature boundary in the app graph.
- Separates app composition from feature ownership.
- Lets the feature develop and preview independently of the executable target.
- Keeps the module API minimal while preserving preview flexibility inside the package.

### Costs
- Adds one more package to resolve and maintain.
- Moves the feature boundary into package/module wiring rather than a single app target.
- Requires discipline to keep the public API narrow as inputs grow later.

### Reconsider when
- Catalog needs richer inputs that cannot stay internal to the module.
- The feature starts depending on app-only concepts again.
- Shared UI primitives or infrastructure concerns begin to blur the boundary.

### Publication candidate
A vertical feature extraction is compelling when the app target becomes mostly composition and the feature module owns its own previewable screen, state, and internal helpers with a tiny public entry point.

## Finding

### Context
Stage 6: Preview Dependencies and Feature Inputs

Infrastructure needs (Networking, session, analytics) arrive naturally as features become realistic. The question is: do feature UIs need to know about that infrastructure to be previewed?

### Decision / observation

We created two versions of CatalogView:

**CatalogViewProblematic:** Feature view requires HTTPClient, SessionManager, AnalyticsTracker as constructor parameters.
- Previews must construct all infrastructure to render the UI
- Adding infrastructure concerns requires changing preview code
- Preview compilation scope expands to include Networking and its dependencies

**CatalogView (refactored):** Feature view accepts lightweight `CatalogInput` struct containing only what the UI needs (a repository).
- Previews express fixture behavior without mentioning infrastructure
- CatalogInputFixture provides named fixture builders
- Production assembly (app layer) creates real infrastructure and passes via CatalogInput
- Preview compilation scope stays bounded: CatalogFeature → DesignSystem only

The architectural separation works like this:

```
Production assembly (app knows about)          Feature (knows about)
    HTTPClient                                 ↓
    SessionManager                          CatalogInput
    AnalyticsTracker                           ↓
        ↓                                   CatalogView
    LiveCatalogRepository                      ↓
        ↓                                   CatalogRepository
    CatalogInput                               (protocol)

Preview fixture                             Feature (knows about)
    MockCatalogRepository                   ↓
        ↓                                   CatalogInput
    CatalogInput                               ↓
        ↓                                   CatalogView
    CatalogView
```

The `CatalogInput` struct is the boundary. It is not a protocol, not an abstraction layer, just a lightweight struct that says: "the feature UI needs a repository, nothing else."

### Benefits
- Feature previews remain decoupled from infrastructure initialization
- Adding infrastructure concerns (logger, cache, etc.) doesn't require changing feature preview code
- Production infrastructure assembly lives in one place (app layer)
- Preview fixture logic can be named and composed (`CatalogInputFixture.loaded()`, `CatalogInputFixture.empty()`)
- Feature UI surface stays intentional: feature.init(input:) clearly states what matters
- Testing feature behavior is simpler: construct CatalogInput with mock, test the view

### Costs
- One extra struct (CatalogInput) in the feature namespace
- Feature must maintain a protocol (CatalogRepository) that mirrors preview/production needs
- Feature UIs do need to know which repository/service interface they need (they just don't know HOW it's built)
- If a feature truly needs 5+ different services, this pattern can grow bulky (though it's still better than sprawling init parameters)

### Reconsider when
- Feature needs so many inputs that CatalogInput becomes a large struct with 5+ fields
- Feature needs to express complex conditional behavior based on which services are available
- Feature inputs don't align with test seams (which would indicate the feature was split incorrectly)

### Pattern name
This is lightweight **feature input modeling**. It is not dependency inversion (no reversed direction). It is not a service locator. It is explicit dependency declaration at feature boundaries with preview-friendly fixture builders.

### Publication candidate
**"Feature inputs vs. infrastructure assembly"** — The observation that UI layers should declare what they need (lightweight, named), not require consumers to assemble infrastructure. Shows concrete before/after and compile-time difference. Valuable because it contradicts both "inject everything" and "use a service locator."

Also: **"Preview isolation as a concrete architectural choice"** — CatalogInputFixture directly enables isolated previews. This is measurable: a CatalogView preview compiles quickly, a ContentView preview with full infrastructure takes longer. Shows that modularization + lightweight inputs improve day-to-day developer experience.

## Finding

### Context
Stage 6 Refactored: Dependency Injection Direction

The initial Stage 6 implementation placed `LiveCatalogRepository` inside `CatalogFeature` package, making the feature depend on Networking. A key architectural question was raised: **should features depend on infrastructure, or should the app layer assemble and inject infrastructure?**

### Decision / observation

The correct modular pattern is:

```text
❌ Wrong:     Feature → Infrastructure
✓ Correct:   Infrastructure ← Feature Input ← Feature
```

This means:
- **CatalogFeature** depends on: DesignSystem (only)
- **CatalogFeature** exports: CatalogRepository protocol, CatalogInput struct, CatalogView
- **App layer** depends on: Networking, CatalogFeature, DesignSystem
- **App layer** creates: HTTPClient, SessionManager, LiveCatalogRepository, injects via CatalogInput

### Changes made
1. Removed Networking from CatalogFeature's Package.swift dependencies
2. Moved LiveCatalogRepository implementation to app target (LiveCatalogRepository.swift)
3. Updated ContentView to assemble infrastructure: create HTTPClient → create LiveCatalogRepository → wrap in CatalogInput → pass to CatalogView
4. Deleted CatalogViewProblematic.swift (was demonstrating the antipattern)
5. Added Networking as dependency to app target in Xcode project

### Benefits
- **True modularity**: Feature has zero knowledge of Networking, HTTPClient, SessionManager
- **Reusability**: CatalogFeature can be embedded in any app context
- **Testability**: Tests construct CatalogInput with mock, no infrastructure ceremony
- **Preview simplicity**: Previews use fixtures (`CatalogInputFixture.loaded()`) without any infrastructure knowledge
- **Composition flexibility**: New infrastructure (Analytics, Database, Auth) arrives in app layer; feature code doesn't change
- **Dependency direction**: Always points inward (app → feature, never feature → app infrastructure)

### Costs
- Feature must know what protocol/interface it needs (it just doesn't know the implementation)
- Requires discipline at app composition to wire everything correctly
- If a feature needs 5+ different services, CatalogInput struct grows (though this is usually a signal to split the feature)

### Architectural insight

The question **"Inject from app to feature, or let feature depend on infrastructure?"** has a clear answer in modular architecture:

**Features should declare inputs (lightweight, named). The app layer assembles infrastructure.**

This pattern is not new, but it is often violated when features are directly packaged with dependencies. By keeping CatalogFeature focused on `CatalogRepository` protocol and CatalogInput boundary, and moving infrastructure assembly to the app layer, we preserve feature reusability and preview performance.

### Publication candidate
**"Dependency direction in modular architecture"** — A concrete example showing why features should not depend on infrastructure packages, and how to structure app-level assembly to inject infrastructure via lightweight feature inputs. Includes before/after code, dependency graphs, and measurements of preview compile time.

Also: **"The correct place for LiveCatalogRepository"** — Live implementations belong in the app layer, not feature packages. Features export protocols and receive implementations via lightweight input models.

