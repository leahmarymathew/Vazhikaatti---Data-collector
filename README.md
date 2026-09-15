# Vazhikatti: Visual Campus Navigator

Offline-first campus image collection for the CSE411 Computer Vision project.

## Repository architecture

- `frontend/`: the preserved Flutter application, including Android, iOS, desktop targets, local SQLite, camera/sensor capture, filesystem storage, validation, and export.
- `backend/`: isolated future FastAPI schemas and placeholder routes. The current Flutter app does not import or communicate with it.
- `docs/`: implementation audit, migration plan, and canonical data contract.

## Current version: completely offline

The collector stores photos on the phone filesystem and metadata in SQLite. It has no login, Firebase, REST client, cloud storage, online synchronization, or internet requirement. GPS is global/rough positioning only; floor and node are explicit collection metadata. Missing sensor or EXIF values remain null and are never fabricated.

Dataset export is a local ZIP containing `images/`, `metadata.csv`, `metadata.json`, `sessions.json`, `nodes.json`, and `README.txt`.

## Flutter frontend

```powershell
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run
```

Use a USB-debugging Android phone or a booted Android emulator. Camera and location permissions are requested at runtime.

## Future backend

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Health check: `GET http://127.0.0.1:8000/health`.

The backend currently provides only health, contract validation, and placeholder versioned routes. It has no CV algorithms, image processing, persistence, authentication, or Flutter integration. A future phase may connect the exact JSON export contract to FastAPI without redesigning the data model.

See [docs/IMPLEMENTATION_AUDIT.md](docs/IMPLEMENTATION_AUDIT.md), [docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md), and [docs/DATA_CONTRACT.md](docs/DATA_CONTRACT.md).
