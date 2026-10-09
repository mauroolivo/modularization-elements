# SearchFeature

A vertical feature module for search UI and item filtering.

## Responsibility

- Own the search screen UI and filtering behavior.
- Emit user intent (`SearchAction`) to app-level composition.

## Dependencies

- `DesignSystem` for reusable UI primitives.
- `ItemDomain` for shared `Item` model.

## Does Not Own

- Networking, persistence, analytics initialization, or app navigation orchestration.
