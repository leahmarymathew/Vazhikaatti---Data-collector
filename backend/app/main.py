from fastapi import FastAPI
from app.api.router import api_router

app = FastAPI(title='Vazhikatti Dataset API', version='0.1.0', description='Future backend contract for Vazhikatti. Flutter remains offline.')
app.include_router(api_router, prefix='/api/v1')

@app.get('/health', tags=['system'])
def health() -> dict[str, str]:
    return {'status': 'ok', 'service': 'vazhikatti-backend', 'mode': 'future-integration'}
