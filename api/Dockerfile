FROM huggingface/transformers-torch-light:latest

LABEL AUTHOR=MINHHUY

RUN pip3 install --no-cache-dir fastapi uvicorn transformers

WORKDIR /app

COPY . .

EXPOSE 8000

CMD ["uvicorn","app:app","--workers", "1", "--host", "0.0.0.0", "--port", "8000"]