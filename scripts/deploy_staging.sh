#!/bin/bash

echo "🚀 Deploying STAGING model..."

MODEL_VERSION=$(python src/deployment/get_latest_model_version.py)

echo "Using model version: $MODEL_VERSION"

bash scripts/build_and_push.sh

kubectl apply -f infra/kubernetes/qa/

echo "Testing endpoint..."

bash scripts/legacy/test_endpoint.sh
