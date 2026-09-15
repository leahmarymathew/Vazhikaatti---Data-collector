from fastapi.testclient import TestClient
from app.main import app
from app.schemas.contract import CaptureCreate
from io import BytesIO

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

def test_session_and_node_creation():
    session = client.post('/api/v1/sessions', json={'id': 'session-test', 'name': 'Test session'})
    node = client.post('/api/v1/nodes', json={'id': 'node-test', 'node_id': 'NODE-1', 'node_name': 'Test node'})
    assert session.status_code == 200
    assert session.json()['id'] == 'session-test'
    assert node.status_code == 200
    assert node.json()['node_id'] == 'NODE-1'

def test_capture_upload_and_duplicate_detection(tmp_path):
    image = b'fake-jpeg-bytes'
    metadata = {'image_id': 'upload-test', 'filename': 'upload-test.jpg', 'capture_session_id': 'session-test', 'view_direction': 'Front'}
    first = client.post('/api/v1/captures/upload', files={'image': ('upload-test.jpg', BytesIO(image), 'image/jpeg')}, data={'metadata': __import__('json').dumps(metadata)})
    second = client.post('/api/v1/captures/upload', files={'image': ('upload-test.jpg', BytesIO(image), 'image/jpeg')}, data={'metadata': __import__('json').dumps(metadata)})
    assert first.status_code == 200
    assert first.json()['duplicate'] is False
    assert second.status_code == 200
    assert second.json()['duplicate'] is True

def test_upload_rejects_malformed_metadata():
    response = client.post('/api/v1/captures/upload', files={'image': ('bad.jpg', b'bytes', 'image/jpeg')}, data={'metadata': '{bad'})
    assert response.status_code == 422

def test_capture_schema_preserves_ground_truth_fields():
    capture = CaptureCreate(
        ground_truth_campus='IIIT K',
        ground_truth_building='New Academic Block',
        ground_truth_floor='Ground',
        ground_truth_node_name='Main Entrance',
    )
    payload = capture.model_dump(exclude_none=True)
    assert payload['ground_truth_campus'] == 'IIIT K'
    assert payload['ground_truth_building'] == 'New Academic Block'
    assert payload['ground_truth_floor'] == 'Ground'
    assert payload['ground_truth_node_name'] == 'Main Entrance'

def test_ground_truth_survives_upload_and_response():
    image = b'ground-truth-jpeg-bytes'
    metadata = {
        'image_id': 'ground-truth-upload-test',
        'filename': 'ground-truth-upload-test.jpg',
        'capture_session_id': 'session-test',
        'view_direction': 'Front',
        'ground_truth_campus': 'IIIT K',
        'ground_truth_building': 'Admin Block',
        'ground_truth_floor': '1',
        'ground_truth_node_name': 'Corridor Junction',
    }
    upload = client.post(
        '/api/v1/captures/upload',
        files={'image': ('ground-truth-upload-test.jpg', BytesIO(image), 'image/jpeg')},
        data={'metadata': __import__('json').dumps(metadata)},
    )
    assert upload.status_code == 200
    captures = client.get('/api/v1/captures').json()
    match = next(c for c in captures if c['image_id'] == 'ground-truth-upload-test')
    assert match['ground_truth_campus'] == 'IIIT K'
    assert match['ground_truth_building'] == 'Admin Block'
    assert match['ground_truth_floor'] == '1'
    assert match['ground_truth_node_name'] == 'Corridor Junction'
