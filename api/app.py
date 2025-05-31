from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from router.core_service import router as CoreRouter
from transformers import pipeline
import torch
import os

classifer = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load the ML model
    # TODO: Load ML Model
    model_id = 'VuHuy/prompt-guardrail-bert-based-uncased'
    classifier = pipeline('text-classification', model=model_id, device='cpu')
    app.state.pipeline = classifier
    yield
    # Release ML Model
    del classifier
    # Release GPU
    torch.cuda.empty_cache()

app = FastAPI(title="Prompt Guardrail Service", lifespan=lifespan)

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