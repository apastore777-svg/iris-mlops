#!/bin/bash

echo "🚀 Deploy STAGING..."

bash scripts/build_and_push.sh

kubectl apply -f infra/kubernetes/qa/

echo "🧪 Testing..."

bash scripts/legacy/test_endpoint.sh
