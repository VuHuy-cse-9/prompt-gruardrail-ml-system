from fastapi import APIRouter, Request

router = APIRouter()


@router.post("/predict")
async def predict(request: Request, text: str):
    pipeline = request.app.state.pipeline
    result = pipeline(text)
    return result