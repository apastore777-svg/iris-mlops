#!/bin/bash

echo "🚀 Running training..."
python pipelines/training_pipeline.py

echo "🔍 Running validation..."
python pipelines/model_validation_pipeline.py

echo "📊 Checking decision..."

DECISION=$(cat artifacts/decision.json | jq -r '.decision')

echo "Decision: $DECISION"

if [ "$DECISION" == "promote" ]; then
    echo "✅ Model approved (candidate ready)"
else
    echo "❌ Model rejected"
fi
