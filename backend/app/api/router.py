import json
from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from app.schemas.contract import CaptureCreate, CaptureResponse, DatasetSummary, NodeCreate, NodeResponse, SessionCreate, SessionResponse, UploadResponse
from app.services import dataset_store

api_router = APIRouter()

@api_router.get('/sessions', response_model=list[SessionResponse])
def list_sessions() -> list[SessionResponse]:
    return [SessionResponse(**item) for item in dataset_store._sessions.values()]

@api_router.post('/sessions', response_model=SessionResponse)
def create_session(payload: SessionCreate) -> SessionResponse:
    record = dataset_store.register_session(payload.model_dump(exclude_none=True))
    return SessionResponse(**record)

@api_router.get('/captures', response_model=list[CaptureResponse])
def list_captures() -> list[CaptureResponse]:
    return [CaptureResponse(**item['metadata']) for item in dataset_store.captures()]

@api_router.post('/captures', response_model=CaptureResponse)
def create_capture(payload: CaptureCreate) -> CaptureResponse:
    return CaptureResponse(**payload.model_dump())

@api_router.post('/captures/upload', response_model=UploadResponse)
async def upload_capture(image: UploadFile = File(...), metadata: str = Form(...)) -> UploadResponse:
    try:
        payload = CaptureCreate.model_validate(json.loads(metadata))
        image_bytes = await image.read()
        if not image_bytes:
            raise ValueError('image is empty')
        result = dataset_store.upload_capture(payload.image_id, payload.filename or image.filename, payload.checksum, payload.model_dump(exclude_none=True), image_bytes)
        return UploadResponse(**result)
    except (ValueError, json.JSONDecodeError) as error:
        raise HTTPException(status_code=422, detail=str(error)) from error

@api_router.get('/nodes', response_model=list[NodeResponse])
def list_nodes() -> list[NodeResponse]:
    return []

@api_router.post('/nodes', response_model=NodeResponse)
def create_node(payload: NodeCreate) -> NodeResponse:
    return NodeResponse(**dataset_store.register_node(payload.model_dump()))

@api_router.get('/datasets/summary', response_model=DatasetSummary)
def dataset_summary() -> DatasetSummary:
    return DatasetSummary(**dataset_store.summary())
