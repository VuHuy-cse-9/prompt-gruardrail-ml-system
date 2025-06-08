from fastapi import APIRouter, Request
from monitor import trace
from opentelemetry.trace import get_tracer_provider

router = APIRouter()

@router.post("/predict")
async def predict(request: Request, text: str):
    tracer = get_tracer_provider().get_tracer(__name__)
    with tracer.start_as_current_span("core_service_predict", attributes={"service": "core_service"}):
        pipeline = request.app.state.pipeline
        result = pipeline(text)
    return result