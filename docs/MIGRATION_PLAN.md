# Migration Plan

## Baseline

The committed Flutter app is the existing working baseline. It currently stores two SQLite tables and local image paths, and it has no application-level network client. The migration must preserve this behavior.

## Safe sequence

1. Add audit and canonical data-contract documents.
2. Add `backend/` as isolated future infrastructure. It will not be imported by Flutter and will not be started by Flutter.
3. Add typed contract models and serializers in a new frontend data layer while retaining the existing `CaptureRecord` reader for backward compatibility.
4. Extend the SQLite schema with versioned migrations. Do not delete or rename the current `sessions` or `captures` columns until an explicit migration has copied them into canonical entities.
5. Move the existing Flutter project into `frontend/` only after Git records the move and both old/new paths are buildable. Prefer `git mv` so history is retained.
6. Route new services through repositories and adapters, then migrate screens one slice at a time.
7. Add tests at each boundary before changing the next one.

## Risks

- Existing app-relative imports and Flutter tooling assume the current root; moving the project changes commands and CI paths.
- Existing SQLite databases on phones have version 1 and only two tables. A destructive schema replacement would lose captures.
- The existing metadata map contains hard-coded values and a raw accelerometer-axis interpretation for pitch/roll. The new model must preserve nullability and must not fabricate corrected values.
- The current export uses only keys present in each map. Canonical export must emit stable all-field columns while preserving unknown legacy keys where possible.
- Android profile manifest contains Flutter development INTERNET permission. This is not application network behavior, but release packaging should be checked separately if a strict no-network manifest is required.
- `share_plus`, camera, and sensor plugins have platform-specific behavior. Platform tests must remain separate from pure serialization/validation tests.

## Discriminating checks

- `flutter analyze` and `flutter test` before and after each Flutter move.
- A migration test opening a version-1 database and asserting old session/capture rows remain readable.
- Contract round-trip tests asserting JSON and CSV field names equal the documented schema.
- `pytest` for backend health/schema routes with no dependency from frontend code.
