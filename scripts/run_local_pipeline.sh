#!/bin/bash

set -e

# 👇 ESSA LINHA resolve o problema
export PYTHONPATH=$(pwd)

echo "-------------------------------------"
echo "STEP 1 - Training"
echo "-------------------------------------"
python pipelines/training_pipeline.py

echo "-------------------------------------"
echo "STEP 2 - Validation"
echo "-------------------------------------"
python pipelines/model_validation_pipeline.py

echo "-------------------------------------"
echo "STEP 3 - Deployment"
echo "-------------------------------------"
python pipelines/deployment_pipeline.py
