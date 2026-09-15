# FastAPI Backend

This backend is optional synchronization infrastructure. Flutter saves locally first and only then attempts HTTPS upload. Render free-tier filesystem storage is temporary; it is not the permanent dataset repository.

## Run locally

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Health check: `GET http://127.0.0.1:8000/health`

The service provides health, session/node registration, metadata routes, and `POST /api/v1/captures/upload` for multipart image plus JSON metadata. CV algorithms, authentication, and localization remain unimplemented.
