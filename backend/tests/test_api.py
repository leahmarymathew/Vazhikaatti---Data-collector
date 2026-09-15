from fastapi.testclient import TestClient
from app.main import app
from app.schemas.contract import CaptureCreate

client = TestClient(app)

def test_health():
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] == 'ok'

def test_route_availability():
    assert client.get('/api/v1/sessions').status_code == 200
    assert client.get('/api/v1/captures').status_code == 200
    assert client.get('/api/v1/nodes').status_code == 200
    assert client.get('/api/v1/datasets/summary').status_code == 200

def test_capture_schema_preserves_contract_fields():
    capture = CaptureCreate(image_id='img-1', ISO=100, view_direction='Front', connected_nodes=['node-2'])
    payload = capture.model_dump(exclude_none=True)
    assert payload['image_id'] == 'img-1'
    assert payload['ISO'] == 100
    assert payload['connected_nodes'] == ['node-2']
