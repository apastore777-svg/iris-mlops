#!/bin/bash

set -e

echo "🚀 Starting build and push..."

# 🔧 CONFIG
ACCOUNT=${ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
REGION=${AWS_DEFAULT_REGION:-us-east-2}
IMAGE=iris-model
REPO=$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$IMAGE

# 🔥 TAG INTELIGENTE
TAG=${MODEL_VERSION:-$(date +%s)}

echo "🔐 Logging into AWS ECR..."
aws ecr get-login-password --region $REGION | \
docker login --username AWS \
--password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

echo "📦 Ensuring ECR repository exists..."

aws ecr describe-repositories \
--repository-names $IMAGE \
--region $REGION >/dev/null 2>&1 || \
aws ecr create-repository \
--repository-name $IMAGE \
--region $REGION

echo "🐳 Building Docker image..."

docker build \
-t $IMAGE \
-f serving/api/Dockerfile \
.

echo "🏷 Tagging image..."

docker tag $IMAGE $REPO:$TAG
docker tag $IMAGE $REPO:latest

echo "📤 Pushing image..."

docker push $REPO:$TAG
docker push $REPO:latest

echo "✅ Image pushed successfully:"
echo "$REPO:$TAG"
