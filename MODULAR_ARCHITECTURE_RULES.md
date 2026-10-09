# Modular Architecture Rules

## 1. A module must justify its boundary

**Why**
A boundary is only useful if it changes ownership, dependency direction, or build scope in a meaningful way.

**Evidence from this course**
- `CatalogFeature`, `DesignSystem`, `ItemDomain`, and `Networking` each became useful because they owned distinct responsibilities.
- The early `ModuleBoundaryLab` experiment showed that folders alone do not create compile-time boundaries.

**Trade-off**
More boundaries mean more manifests, more API decisions, and more wiring.

**When to reconsider**
If a module cannot explain what it owns in one sentence, it probably should not exist as a separate boundary.

## 2. Features should not import sibling features for application workflows

**Why**
Cross-feature flows belong to application composition, not feature internals.

**Evidence from this course**
- `CatalogFeature` and `FavoritesFeature` communicate through app-owned state and actions.
- `SearchFeature` emits `addToFavorites` actions instead of importing favorites navigation directly.

**Trade-off**
The app becomes more responsible for orchestration, so composition code gets a little more complex.

**When to reconsider**
If orchestration becomes a large switchboard, a dedicated coordinator or routing layer may be justified.

## 3. Feature inputs should describe UI needs, not infrastructure

**Why**
UI code should request what it needs in domain-shaped terms, not force preview and composition code to assemble the entire dependency graph.

**Evidence from this course**
- `CatalogInput` replaced the earlier infrastructure-heavy constructor shape.
- `CatalogInputFixture` enabled deterministic previews without networking or analytics setup.

**Trade-off**
You may need one extra input type and one or two lightweight protocols or adapters.

**When to reconsider**
If the input type grows into a large grab-bag of services, the feature is probably too broad or the seam is wrong.

## 4. Public API is architectural surface area

**Why**
Every `public` symbol becomes part of the cost of change for consumers.

**Evidence from this course**
- `CatalogView`, `SearchView`, `FavoritesView`, and `Item` expose only the minimum needed surface.
- Stage 2 showed how even a public default argument can accidentally leak internal dependencies.

**Trade-off**
Smaller public APIs can make module design more deliberate and sometimes slightly more verbose.

**When to reconsider**
If consumers keep needing internal details, the boundary may be wrong or the module may own too much.

## 5. Keep shared modules narrow and stable

**Why**
High-fan-in modules amplify tiny API changes across many consumers.

**Evidence from this course**
- `ItemDomain` became the highest fan-in module once multiple features shared `Item`.
- The rebuild experiments showed that an API change in `ItemDomain` rippled farther than implementation-only edits in feature modules.

**Trade-off**
Shared modules are convenient, but they make volatility expensive.

**When to reconsider**
If a shared type changes frequently or different features start needing different versions of the concept, duplication or anti-corruption mapping may be cheaper.

## 6. Keep `DesignSystem` presentation-only

**Why**
A shared UI foundation should remain stable and reusable.

**Evidence from this course**
- `DesignSystem` stayed focused on `AppButton`, `Card`, `Badge`, and spacing tokens.
- The course repeatedly treated feature logic, domain models, and infrastructure as out of scope for `DesignSystem`.

**Trade-off**
A strict boundary can require some duplicated styling in features.

**When to reconsider**
If a component needs feature-specific behavior or business logic, it probably does not belong in `DesignSystem`.

## 7. The app is the composition root

**Why**
Live implementations, app-specific policy, and dependency assembly naturally belong to the executable target.

**Evidence from this course**
- `AppComposition` assembled `HTTPClient`, `LiveCatalogRepository`, and `LiveAnalyticsTracker`.
- The app target injected `CatalogInput`, `FavoritesInput`, `SearchInput`, and `CatalogWidgetsInput` into features.

**Trade-off**
The app target stays thin, but it is still responsible for orchestration and wiring.

**When to reconsider**
If composition logic starts to contain business rules, extract a coordinator or app-service layer.

## 8. Contain third-party SDKs behind a narrow adapter

**Why**
SDK imports spread quickly and are hard to undo once they leak into feature code.

**Evidence from this course**
- `AnalyticsAPI` defined the contract.
- `AnalyticsLive` held the third-party analytics dependency.
- `CatalogFeature` depended only on the API, not the SDK.

**Trade-off**
You add a small amount of adapter code and one more target.

**When to reconsider**
If the third-party dependency is trivial, transient, or only used in one place, a separate adapter may not be worth it.

## 9. Previews should be owned by the module they exercise

**Why**
A preview is most useful when it compiles the smallest practical graph.

**Evidence from this course**
- `DesignSystem` previews compiled only the UI foundation module.
- `CatalogFeature`, `SearchFeature`, and `FavoritesFeature` previews stayed module-local through lightweight inputs and fixtures.

**Trade-off**
Module-local previews can require extra fixture types or mock inputs.

**When to reconsider**
If a preview needs app-level orchestration to be meaningful, that preview may belong in the app target instead.

## 10. Package count and target count are separate decisions

**Why**
A package is a distribution/organization boundary; a target is a compile-time module boundary.

**Evidence from this course**
- The one-package-per-module layout worked for the main app graph.
- `ModuleBoundaryLab` showed that multiple targets can live inside one package and still have intentional `package` access.

**Trade-off**
More packages improve explicitness; fewer packages can reduce manifest overhead.

**When to reconsider**
If modules always evolve together, a multi-target package may be simpler than many tiny packages.

## 11. Do not abstract away concrete dependencies until you need the abstraction

**Why**
A protocol is only valuable if it buys testability, preview isolation, replacement, or containment.

**Evidence from this course**
- `CatalogRepository` and `AnalyticsTracking` were worth it because they supported previews, tests, and live composition.
- The direct networking experiment showed that extra abstraction has a real cost.

**Trade-off**
Concrete dependencies are often simpler; abstractions add indirection and surface area.

**When to reconsider**
If a dependency has only one implementation and no meaningful replacement/test/preview pressure, keep it concrete.

## 12. Measure rebuild behavior instead of assuming modularization is faster

**Why**
A cleaner graph does not automatically mean a faster build; module volatility matters.

**Evidence from this course**
- The app build succeeded with a 19-target graph.
- The rebuild experiments showed different blast radii for `CatalogFeature`, `ItemDomain`, and `Networking` edits.
- Shared API changes were more expensive than implementation-only changes.

**Trade-off**
Measurement takes time, but it prevents architecture folklore from driving decisions.

**When to reconsider**
If the measured rebuild cost is not meaningfully affecting iteration, optimize for clarity and ownership first.

## 13. Keep the laboratory intentionally incomplete until evidence justifies more structure

**Why**
Premature symmetry often creates more architecture than the product needs.

**Evidence from this course**
- The course started small and only extracted boundaries after pressure appeared.
- `SearchFeature`, `FavoritesFeature`, and `ItemDomain` were introduced in response to concrete reuse and sharing pressure, not because a diagram demanded them.

**Trade-off**
The codebase may look less “finished” early on, but it becomes easier to reason about how and why boundaries appeared.

**When to reconsider**
If a repeated pattern emerges in multiple places and the duplication is hurting clarity or testing, that is the time to extract more structure.
