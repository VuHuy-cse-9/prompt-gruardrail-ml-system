from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from router.core_service import router as CoreRouter
from transformers import pipeline
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
import torch
from monitor import setup_monitoring
from dotenv import load_dotenv
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

classifer = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load the ML model
    model_id = 'VuHuy/prompt-guardrail-bert-based-uncased'
    classifier = pipeline('text-classification', model=model_id, device='cpu')
    app.state.pipeline = classifier
    # Setup monitoring
    setup_monitoring()
    # Instrument FastAPI app
    FastAPIInstrumentor.instrument_app(app)
    yield
    # Release ML Model
    del classifier
    # Release GPU
    torch.cuda.empty_cache()
    # Uninstrument app
    FastAPIInstrumentor.uninstrument_app(app)
    yield

app = FastAPI(title="Prompt Guardrail Service", lifespan=lifespan)

# Add Middle core
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["Root"])
async def read_root():
    return {"message": "Welcome to Prompt Guardrail Service."}


app.include_router(CoreRouter, tags=["CoreService"], prefix="/core")