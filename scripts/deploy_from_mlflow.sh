#!/bin/bash

set -e

MODEL_NAME="iris-classifier"
STAGE=$1

ACCOUNT=494722910828
REGION=us-east-2
ECR=$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/iris-model

TAG=$(date +%s)

echo "Using MLflow stage: $STAGE"

export MLFLOW_TRACKING_URI=${MLFLOW_TRACKING_URI:-http://localhost:5000}

rm -rf build
mkdir build

echo "Downloading model from MLflow Registry..."

mlflow artifacts download \
--artifact-uri models:/$MODEL_NAME/$STAGE \
--dst-path build/

echo "Preparing model for container..."

rm -rf serving/api/model
mkdir -p serving/api/model

cp -r build/* serving/api/model/

echo "Building Docker image..."

docker build \
-t iris-model \
-f serving/api/Dockerfile \
.

echo "Logging into ECR..."

aws ecr get-login-password \
--region $REGION | docker login \
--username AWS \
--password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

echo "Tagging image..."

docker tag iris-model $ECR:$TAG
docker tag iris-model $ECR:latest

echo "Pushing image..."

docker push $ECR:$TAG
docker push $ECR:latest

echo "Deploying..."

if [ "$STAGE" == "Staging" ]; then

  echo "Deploying to EKS DEV..."

  kubectl apply -f infra/kubernetes/dev/

elif [ "$STAGE" == "Production" ]; then

  echo "Deploying to SageMaker PROD..."

  aws sagemaker update-endpoint \
  --endpoint-name iris-endpoint \
  --endpoint-config-name iris-config \
  --region $REGION

fi

echo "Deployment complete."
