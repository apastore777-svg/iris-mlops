FROM python:3.11-slim

WORKDIR /app

COPY models/iris-classifier/v1 /app
COPY serving/iris/serve.sh /app/serve.sh

RUN pip install --no-cache-dir -r /app/requirements.txt && \
    pip install mlflow boto3 gunicorn

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/app/serve.sh"]
