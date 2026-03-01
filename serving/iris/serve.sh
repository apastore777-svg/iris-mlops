#!/bin/sh
set -e

echo "Container started with args: $@"
echo "Starting MLflow scoring server..."

mlflow models serve \
    --model-uri /app \
    --host 0.0.0.0 \
    --port 8080 \
    --no-conda
