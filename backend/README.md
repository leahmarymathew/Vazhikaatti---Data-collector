# Future FastAPI Backend

This backend is infrastructure for a later phase. The Flutter application is currently 100% offline and does not import, start, or communicate with this service.

## Run locally

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Health check: `GET http://127.0.0.1:8000/health`

The initial routes are structural only. CV algorithms, persistence, authentication, image upload, and Flutter integration are intentionally not implemented.
