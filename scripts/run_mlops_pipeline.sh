#!/bin/bash

echo "🚀 Training..."
python pipelines/training_pipeline.py

echo "🔍 Validation..."
python pipelines/model_validation_pipeline.py
