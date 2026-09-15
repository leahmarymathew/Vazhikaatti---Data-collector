# Implementation Audit

Audited from the committed repository at `62632aa` before migration. Existing Flutter source remains unchanged by this audit.

| Requirement | Existing implementation | Status | File(s) | Missing work |
|---|---|---|---|---|
| Offline-only Flutter operation | Uses SQLite, app documents directory, local ZIP/share; no HTTP/Firebase/login code found | Partial | `lib/data/database.dart`, `lib/services/storage_service.dart`, `pubspec.yaml` | Keep network-free after migration; document dev-only Android INTERNET profile permission |
| Capture sessions | Creates and stores sessions with id/name/time/status | Partial | `lib/main.dart`, `lib/data/models.dart`, `lib/data/database.dart` | Session edit/completion/statistics and dedicated repository layer |
| SQLite persistence | `sessions` and `captures` tables; images stored by filesystem path | Partial | `lib/data/database.dart` | Add Campus, Building, Wing, Floor, Area, Room, NavigationNode, PanoramaSequence; migrations and CRUD |
| Canonical metadata model | Capture metadata is an untyped `Map<String,dynamic>` with a small subset of fields | Missing | `lib/data/models.dart`, `lib/main.dart` | Add typed nullable model containing all contract fields and stable JSON keys |
| Campus/building/wing/floor/area/room selection | UI hard-codes Engineering Block, Ground Floor, North Wing, Corridor | Partial | `lib/main.dart` | Seed hierarchy entities and explicit selectors/forms |
| Navigation node metadata | Node dropdown uses three sample maps; no coordinate fields or node table | Partial | `lib/data/models.dart`, `lib/main.dart` | Persist node entities, local coordinates, graph links, and inheritance |
| Camera preview/capture | Camera plugin initializes first available camera and captures JPEG | Implemented | `lib/main.dart` | Move into camera service; store dimensions/camera id and improve permission/error handling |
| GPS | Geolocator position stream and one current position are displayed/stored | Partial | `lib/main.dart` | Location service abstraction, stability checks, source metadata, test seam |
| Heading/compass | `flutter_compass` heading stream is displayed/stored | Partial | `lib/main.dart` | Sensor availability/stability engine and platform permission handling |
| Pitch/roll | Accelerometer x/y are used directly as pitch/roll | Partial | `lib/main.dart` | Do not label raw axes as angles; add orientation service/fusion or explicitly preserve unavailable values |
| EXIF/camera metadata | None collected | Missing | `pubspec.yaml`, `lib/main.dart` | Add EXIF reader and device/camera metadata service without fabrication |
| Metadata validation | Required checklist validates image, GPS, accuracy <=30m, heading, pitch/roll, hierarchy, node, direction, split | Implemented | `lib/services/validation.dart` | Add stability/duplicate/corruption/availability rules and typed validation result |
| Reject invalid captures | Invalid capture is not inserted into SQLite, but copied photo is left in storage | Partial | `lib/main.dart`, `lib/services/storage_service.dart` | Explicit temporary/quarantine lifecycle and recapture/delete action |
| Multi-angle/panorama flow | Direction dropdown supports Front/Right/Back/Left/Custom only | Partial | `lib/main.dart` | Panorama sequence entity, ordered guide, overlap config, completion tracking |
| Retake/delete/edit/mark unusable | No persistence/UI for these actions | Missing | `lib/main.dart`, `lib/data/database.dart` | CRUD commands and metadata edit without deleting original image |
| Duplicate detection | SHA-256 is computed but never checked against existing captures | Partial | `lib/services/storage_service.dart` | Repository checksum lookup and duplicate UX |
| Corruption detection | No image decode/verification before persistence | Missing | `lib/services/storage_service.dart` | Decode/check image and report corruption |
| Organized storage | `VazhikattiDataset/images/<session>/` and `exports/` are created | Partial | `lib/services/storage_service.dart` | Add metadata/sessions directories and campus/building/floor/session path scheme |
| Export ZIP | ZIP includes images, metadata JSON/CSV, sessions, sample nodes, README | Partial | `lib/services/storage_service.dart` | Canonical all-field JSON/CSV, nodes entity export, stable schema and report |
| Share/file transfer | Uses `share_plus` after writing local ZIP | Implemented | `lib/services/storage_service.dart` | File picker optional; preserve offline share behavior |
| Statistics/history | Dashboard only counts sessions/images and lists captures | Partial | `lib/main.dart`, `lib/data/database.dart` | Counts by campus/building/floor/node/session, missing metadata report, completion percentage, storage warning |
| Device info | `device_info_plus` declared but not used | Missing | `pubspec.yaml`, `lib/main.dart` | Device service and model fields |
| Offline map preview | No maps or offline map data | Missing | `lib/main.dart` | Coordinate/compass fallback; optional offline map provider must not require tiles |
| Permissions | Android camera/fine/coarse location manifest; runtime location request | Partial | `android/app/src/main/AndroidManifest.xml`, `lib/main.dart` | Camera/runtime permission abstraction, iOS permission strings, sensor availability handling |
| Future CV fields | A few null placeholders only | Missing | `lib/main.dart` | Add all future CV/localization fields to canonical model, without algorithms |
| Future FastAPI compatibility | No backend or shared schema | Missing | Repository root | Add conceptual shared contract and separate FastAPI skeleton; Flutter must not call it |
| Tests | Two validation unit tests | Partial | `test/widget_test.dart` | Serialization, database CRUD, checksum/duplicate, panorama, JSON/CSV, backend tests |
| Documentation | README has brief offline/run/export notes plus generated starter text | Partial | `README.md` | Root architecture guide, data contract, audit, migration plan, backend README |

## Audit conclusion

The existing implementation is a useful offline vertical slice, but it is not safe to move blindly into a new architecture yet. The safest migration is additive: preserve the current Flutter project as `frontend/`, add canonical models and repositories beside it, introduce a schema version/migration path, and only then route screens/services through the new abstractions. The current hard-coded hierarchy and untyped metadata are the highest-risk boundaries.
