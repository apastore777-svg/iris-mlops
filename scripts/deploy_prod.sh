#!/bin/bash

echo "🚀 Deploy PROD..."

python src/deployment/promote_model.py

bash scripts/build_and_push.sh

kubectl apply -f infra/kubernetes/prod/
