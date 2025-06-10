from fastapi import APIRouter, Request
from fastapi.exceptions import HTTPException
from opentelemetry.trace import get_tracer_provider

router = APIRouter()

@router.post("/predict")
async def predict(request: Request, text: str):
    tracer = get_tracer_provider().get_tracer(__name__)
    try:
        with tracer.start_as_current_span("core_service_predict", attributes={"service": "core_service"}):
            pipeline = request.app.state.pipeline
            preds = pipeline(text)
            response = preds[0]
            return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))