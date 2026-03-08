#!/bin/bash

set -e

echo "-------------------------------------"
echo "STEP 1 - Training model"
echo "-------------------------------------"

python training/train_iris_mlflow.py


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
echo "STEP 4 - Testing endpoint"
echo "-------------------------------------"

python scripts/test_candidate.py


echo "-------------------------------------"
echo "STEP 5 - Awaiting approval"
echo "-------------------------------------"

echo "To promote model run:"
echo "./scripts/approve_candidate.sh $VERSION"
echo "./scripts/update_serving_endpoint.sh $VERSION"
