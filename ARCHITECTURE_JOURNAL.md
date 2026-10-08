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


## Finding

### Context
Stage 7 introduced a focused infrastructure boundary in `Packages/Networking` and tested whether `CatalogFeature` should depend on it directly.

### Decision / observation
`Networking` now owns HTTP infrastructure primitives (`HTTPClient`, `HTTPRequest`, `HTTPResponse`, `HTTPMethod`, `HTTPError`) and nothing feature-specific. The `CatalogFeature` package no longer depends on `Networking`; it owns only feature models, repository protocol, and preview mock data.

The app target now assembles the live path:
- `ContentView` imports `CatalogFeature` and `Networking`
- `LiveCatalogRepository` lives in the app layer
- `LiveCatalogRepository` uses `HTTPClient` through an app-owned endpoint/fallback path
- `CatalogView` still receives a lightweight `CatalogInput`

Validated dependency shape:
```text
App target
├── imports CatalogFeature
├── imports Networking
└── owns LiveCatalogRepository

CatalogFeature
├── owns CatalogView / CatalogInput / CatalogRepository / MockCatalogRepository
└── imports DesignSystem only

Networking
└── owns HTTP infrastructure types only
```

### Benefits
- Keeps feature modules free of direct infrastructure dependencies.
- Makes the app composition boundary explicit: the executable assembles live infrastructure.
- Preserves preview-friendly feature inputs while allowing app-level networking integration.
- Tightens the `Networking` package to a reusable transport layer instead of a mixed infrastructure grab bag.

### Costs
- The app layer now owns more composition code and fallback behavior.
- `LiveCatalogRepository` needs app-owned fixture data or real decoding logic to stay buildable.
- The architecture still has a live app preview path that compiles the full graph, which is useful for this stage but not ideal for every feature preview.

### Reconsider when
- A feature truly needs first-class networking control as part of its own domain responsibility.
- `Networking` starts accumulating auth/session/cache/analytics concerns again.
- The app-layer repository grows into a large orchestration object instead of a thin adapter.

### Publication candidate
The failed build caused by referencing `Item.sampleItems` from the app layer was a useful boundary check: it showed how quickly a supposedly internal feature fixture can leak across module lines and force an explicit ownership decision.

## Finding

### Context
Stage 8 compared two dependency structures for the catalog screen:
1. `CatalogFeature → Networking` directly
2. `CatalogFeature → CatalogRepository` with the app composing `LiveCatalogRepository → Networking`

### Decision / observation
The codebase now contains both shapes for comparison:
- `CatalogView` continues to use the lightweight `CatalogInput` / `CatalogRepository` boundary.
- `CatalogViewDirect` was added as an alternative that imports `Networking` and talks to `HTTPClient` directly.
- `CatalogViewDirect` needed extra preview machinery (`URLProtocol` + session fixture) to stay deterministic in previews.
- The app still uses the inverted path for its actual composition (`ContentView` → `CatalogView`), while the direct version remains an experiment inside the feature package.

What the comparison showed:
- Direct dependency path:
  - fewer types and less composition code
  - feature owns its transport dependency explicitly
  - previews require a custom transport harness instead of a simple fixture object
  - feature API now knows about HTTP concerns
- Repository inversion path:
  - one extra abstraction and a live repository type
  - app owns composition and infrastructure wiring
  - preview setup stays simpler and more domain-shaped
  - feature stays reusable without transport knowledge

### Benefits
- Makes the trade-off tangible instead of theoretical.
- Shows that direct dependency can be simpler locally but more expensive for previews and test seams.
- Confirms that dependency inversion is justified here mainly by composition/preview ownership, not by generic doctrine.
- Keeps the feature module honest about what it owns versus what the app assembles.

### Costs
- Two parallel entry points now exist in the feature package, which adds some learning noise.
- The direct preview path needs `URLProtocol` plumbing and `HTTPClient` setup.
- The feature package still carries a `Networking` dependency because of the direct experiment, even though the app does not need it for the main path.

### Reconsider when
- A feature is truly transport-oriented and the transport dependency is part of its core responsibility.
- The repository abstraction starts mirroring `HTTPClient` too closely and becomes meaningless.
- Preview or testing needs become so simple that the extra abstraction is no longer pulling its weight.

### Publication candidate
"Dependency inversion is not free" — the direct `CatalogViewDirect` preview demonstrates how a seemingly simpler feature-to-networking coupling shifts complexity into preview setup and test isolation. This is a useful counterpoint to blanket abstraction advice.

## Finding

### Context
Stage 9 moved from comparing dependency shapes to defining the app as the composition boundary.

### Decision / observation
The app target now owns the live assembly path explicitly:
- `modularization_elementsApp` creates the window group with `ContentView(input: AppComposition.catalogInput())`
- `AppComposition` lives in the app target and constructs `HTTPClient`, `LiveCatalogRepository`, and `CatalogInput`
- `ContentView` is now input-driven and no longer responsible for choosing mock vs live wiring
- `CatalogFeature` remains unaware of app-specific composition details

Current ownership split:
```text
App target
├── app entry point
├── composition root (`AppComposition`)
├── live repository implementation (`LiveCatalogRepository`)
└── feature injection (`ContentView(input:)`)

CatalogFeature
├── feature UI/state/contracts
└── no app composition knowledge
```

### Benefits
- Makes dependency definition, implementation, and composition distinct concepts.
- Keeps the app thin while still making it the place where live implementations are assembled.
- Removes the ambiguity of a view quietly deciding whether it should be mock or live.
- Gives us a single place to inspect live infrastructure wiring.

### Costs
- One more explicit composition type to maintain.
- The app target still carries the responsibility of wiring feature inputs correctly.
- The current composition root is simple; it could become another orchestration layer if it starts accumulating too many responsibilities.

### Reconsider when
- Composition grows into a large, unstructured factory surface.
- The app target starts containing business logic rather than wiring.
- Feature setup becomes repetitive enough that a dedicated composition helper per flow would be clearer.

### Publication candidate
A thin `AppComposition` is a practical teaching example of the difference between “the app owns assembly” and “the app target should be empty.” The refactor shows that the app can stay thin without pretending it has no responsibilities.

## Finding

### Context
Stage 10 added the first second vertical feature: `FavoritesFeature`.

### Decision / observation
We intentionally made `FavoritesFeature` reuse `CatalogFeature.Item` rather than introduce a second, superficially similar item model. That made the shared-domain question visible immediately: the two features can share a concept for now, but the sharing currently travels through a feature package, not a dedicated domain module.

The app target now composes both vertical features via tabs:

```text
modularization-elements app target
├── imports CatalogFeature
├── imports FavoritesFeature
├── CatalogView(input: catalogInput)
└── FavoritesView(input: favoritesInput)
```

This keeps feature-to-feature communication out of the feature modules themselves while letting the app own cross-feature composition. It also makes the shared-item question visible without forcing a premature domain extraction.

### Benefits
- Demonstrates that a second feature can be added without creating feature-to-feature imports.
- Keeps app-level orchestration explicit and easy to inspect.
- Forces the shared-domain question to appear as an architectural decision instead of an accidental duplicate type.

### Costs
- `FavoritesFeature` is coupled to `CatalogFeature` for `Item`, so the shared concept is not yet independently owned.
- Reusing a feature-owned model across a sibling feature increases fan-out from that feature package.
- If more features need `Item`, `CatalogFeature` may become an accidental shared-domain module.

### Reconsider when
- Another feature needs `Item` and `CatalogFeature` starts looking like a shared dependency rather than a feature.
- We need feature-specific item variants and the reused model becomes too narrow.
- Cross-feature sharing becomes stable enough to justify a dedicated domain boundary.

### Publication candidate
The first shared-domain question is best introduced by a second feature, not by inventing a domain module upfront. Showing the cost of reusing a feature-owned type is a good setup for later comparing against a real shared-domain extraction.


## Finding

### Context
Stage 10 added a second vertical feature (`FavoritesFeature`) to pressure-test boundaries after `CatalogFeature`.

### Decision / observation
We created `FavoritesFeature` as its own package/target and composed it in the app via a second tab. For this stage, `FavoritesFeature` intentionally reuses `CatalogFeature.Item` instead of introducing a duplicate item model.

This makes the shared-domain question explicit without prematurely creating a domain module:

```text
App
|- CatalogFeature
`- FavoritesFeature
   `- imports CatalogFeature (Item)
```

### Benefits
- Confirms a second feature can be added without feature-to-feature runtime orchestration.
- Keeps cross-feature composition in the app layer.
- Surfaces ownership pressure around shared models early and concretely.

### Costs
- `FavoritesFeature` now depends on `CatalogFeature` for `Item`.
- `CatalogFeature` risks becoming an accidental shared-domain module as fan-in grows.

### Reconsider when
- A third feature needs `Item`.
- `Item` changes independently from catalog-specific needs.
- Shared model volatility starts causing broad rebuild impact.

### Publication candidate
Introducing the second feature before creating a shared domain module is a useful teaching step: it shows when sharing looks convenient, and when it starts signaling a real domain boundary.


## Finding

### Context
Stage 11 extracted `ItemDomain` as a focused shared-domain module for `Item`.

### Decision / observation
We moved `Item` from `CatalogFeature` into a new package/target: `ItemDomain`.

Updated dependency shape:

```text
ItemDomain
  |- CatalogFeature
  `- FavoritesFeature

App
  |- CatalogFeature
  |- FavoritesFeature
  |- ItemDomain
  `- Networking
```

`FavoritesFeature` no longer imports `CatalogFeature` for shared model access. Both features now import `ItemDomain` directly.

### Benefits
- Shared model ownership is explicit and not hidden inside a feature module.
- Removes accidental feature-to-feature model coupling.
- Makes future shared-domain evolution discussable as a first-class boundary.

### Costs
- Adds one more package/target and dependency edge to maintain.
- `ItemDomain` now has fan-in from multiple features, so API changes can trigger broader rebuilds.

### Reconsider when
- `Item` diverges semantically across features (duplication may become cheaper than coupling).
- `ItemDomain` starts collecting unrelated types and trends toward a dumping-ground shared module.

### Publication candidate
A practical before/after showing `FavoritesFeature -> CatalogFeature` replaced by `FavoritesFeature -> ItemDomain` is a concrete demonstration of when a shared-domain extraction is justified.


## Finding

### Context
Stage 12 introduced cross-feature communication and navigation pressure: add from Catalog into Favorites, while keeping feature modules independent.

### Decision / observation
We split navigation ownership into two layers:

- Feature-local navigation remains inside each feature (`CatalogView` and `FavoritesView` present local item detail sheets).
- Application-level coordination happens in the app target (`ContentView` owns favorites state and tab selection).

Feature modules emit actions through input callbacks:

- `CatalogAction.addToFavorites(Item)`
- `FavoritesAction.removeFromFavorites(Item)`

The app layer handles these actions, updates shared state, and switches tabs when useful.

### Benefits
- Avoids feature-to-feature imports for cross-feature workflows.
- Keeps features previewable with deterministic inputs.
- Makes application orchestration explicit and testable at composition level.

### Costs
- Input models gain callback surface area that must be maintained.
- App composition/state handling becomes more complex as flows grow.

### Reconsider when
- App-level action handling turns into a large unstructured switchboard.
- A shared flow appears in many features and needs a more structured coordinator boundary.

### Publication candidate
Showing the same user flow split into feature-local navigation plus app-level orchestration is a strong example that "features should not import each other to navigate" can be enforced with lightweight output actions.
