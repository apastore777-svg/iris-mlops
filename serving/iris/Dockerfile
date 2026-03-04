FROM python:3.11-slim

WORKDIR /app

# Copiar requirements primeiro (melhora cache)
COPY serving/iris/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r /app/requirements.txt \
    && pip install mlflow boto3 gunicorn

# Copiar modelo e script depois
COPY models/iris-classifier/v1 /app/model
COPY serving/iris/serve.sh /app/serve.sh

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/app/serve.sh"]
