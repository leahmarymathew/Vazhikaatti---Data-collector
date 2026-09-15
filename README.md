# Vazhikatti: Visual Campus Navigator

Offline-first campus image collection for the CSE411 Computer Vision project.

## Repository architecture

- `frontend/`: the preserved Flutter application, including Android, iOS, desktop targets, local SQLite, camera/sensor capture, filesystem storage, validation, and export.
- `backend/`: isolated FastAPI schemas, optional sync routes, and temporary development storage. The current Flutter app can call it only after local persistence.
- `docs/`: implementation audit, migration plan, and canonical data contract.

## Current version: completely offline

The collector stores photos on the phone filesystem and metadata in SQLite. Local storage is always the source of truth. Optional HTTPS synchronization runs after local save and never blocks capture. There is no login, Firebase, cloud storage, or required internet connection. GPS is global/rough positioning only; floor and node are explicit collection metadata. Missing sensor or EXIF values remain null and are never fabricated.

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

The backend provides health, contract validation, session/node registration, metadata routes, and multipart image upload. Render free-tier filesystem storage is temporary and non-persistent; the phone copy remains authoritative. It has no CV algorithms, authentication, or localization.

See [docs/IMPLEMENTATION_AUDIT.md](docs/IMPLEMENTATION_AUDIT.md), [docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md), and [docs/DATA_CONTRACT.md](docs/DATA_CONTRACT.md).
