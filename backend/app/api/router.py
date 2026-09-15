from fastapi import APIRouter
from app.schemas.contract import CaptureCreate, CaptureResponse, DatasetSummary, NodeCreate, NodeResponse, SessionCreate, SessionResponse

api_router = APIRouter()

@api_router.get('/sessions', response_model=list[SessionResponse])
def list_sessions() -> list[SessionResponse]:
    return []

@api_router.post('/sessions', response_model=SessionResponse, status_code=501)
def create_session(payload: SessionCreate) -> SessionResponse:
    raise NotImplementedError('Backend persistence is reserved for a future phase')

@api_router.get('/captures', response_model=list[CaptureResponse])
def list_captures() -> list[CaptureResponse]:
    return []

@api_router.post('/captures', response_model=CaptureResponse, status_code=501)
def create_capture(payload: CaptureCreate) -> CaptureResponse:
    raise NotImplementedError('Backend persistence is reserved for a future phase')

@api_router.get('/nodes', response_model=list[NodeResponse])
def list_nodes() -> list[NodeResponse]:
    return []

@api_router.post('/nodes', response_model=NodeResponse, status_code=501)
def create_node(payload: NodeCreate) -> NodeResponse:
    raise NotImplementedError('Backend persistence is reserved for a future phase')

@api_router.get('/datasets/summary', response_model=DatasetSummary)
def dataset_summary() -> DatasetSummary:
    return DatasetSummary()
