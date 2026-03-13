#!/bin/bash

set -e

echo "-------------------------------------"
echo "STEP 1 - Training model"
echo "-------------------------------------"

python src/training/train_iris_mlflow.py


echo "-------------------------------------"
echo "STEP 2 - Getting latest model version"
echo "-------------------------------------"

VERSION=$(python scripts/get_latest_model_version.py)

echo "Latest version detected: $VERSION"


echo "-------------------------------------"
echo "STEP 3 - Setting candidate"
echo "-------------------------------------"

python scripts/set_candidate.py $VERSION


echo "-------------------------------------"
echo "STEP 4 - Running tests"
echo "-------------------------------------"

pytest


echo "-------------------------------------"
echo "STEP 5 - Promoting model"
echo "-------------------------------------"

python scripts/promote_model.py $VERSION


echo "-------------------------------------"
echo "STEP 6 - Building Docker image"
echo "-------------------------------------"

bash scripts/build_and_push.sh


echo "-------------------------------------"
echo "STEP 7 - Deploying model"
echo "-------------------------------------"

bash scripts/deploy_from_mlflow.sh Production


echo "-------------------------------------"
echo "PIPELINE COMPLETE"
echo "-------------------------------------"
