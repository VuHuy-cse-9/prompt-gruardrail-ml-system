from fastapi import APIRouter, Request
from fastapi.exceptions import HTTPException
from monitor import trace

router = APIRouter()

@router.post("/predict")
@trace("core_service_predict")
async def predict(request: Request, text: str):
    try:
            pipeline = request.app.state.pipeline
            preds = pipeline(text)
            response = preds[0]
            return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))