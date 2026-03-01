#!/bin/bash

set -e

MODEL_NAME="iris-classifier"
STAGE=$1

ACCOUNT=494722910828
REGION=us-east-2
ECR=$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/iris-model

echo "Using MLflow stage: $STAGE"

export MLFLOW_TRACKING_URI=http://SEU_LOAD_BALANCER:5000

rm -rf build
mkdir build

echo "Downloading model from MLflow Registry..."

mlflow artifacts download \
--artifact-uri models:/$MODEL_NAME/$STAGE \
--dst-path build/

echo "Building Docker image..."

docker build \
-t iris-model \
-f serving/iris/Dockerfile \
.

echo "Logging into ECR..."

aws ecr get-login-password \
--region $REGION | docker login \
--username AWS \
--password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

echo "Tagging image..."

docker tag iris-model:latest $ECR:latest

echo "Pushing image..."

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

echo "Done."
