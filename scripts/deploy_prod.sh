#!/bin/bash

echo "🚀 Promoting model to production..."

python src/deployment/promote_model.py

MODEL_VERSION=$(python src/deployment/get_latest_model_version.py)

echo "Deploying version: $MODEL_VERSION"

bash scripts/build_and_push.sh

kubectl apply -f infra/kubernetes/prod/
