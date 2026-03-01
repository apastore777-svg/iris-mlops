#!/bin/bash

set -e

echo "Enabling enterprise MLOps pipeline..."

mkdir -p .github/workflows

############################
# DEV
############################

cat > .github/workflows/deploy-dev.yml << 'EOF'
name: Deploy Dev

on:
  push:
    branches:
      - dev
  workflow_dispatch:

env:
  MODEL_NAME: iris-classifier
  ECR_REPOSITORY: iris-model
  EKS_CLUSTER: iris-cluster
  NAMESPACE: dev
  DEPLOYMENT: iris-api-dev
  CONTAINER: iris-api
  AWS_REGION: ${{ secrets.AWS_REGION }}
  AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}

jobs:

  deploy:

    runs-on: ubuntu-latest
    environment: dev

    steps:

      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - run: pip install mlflow boto3 awscli

      - name: Get latest model version
        run: |
          python <<EOF > version.txt
from mlflow.tracking import MlflowClient
import os
client = MlflowClient()
v = client.get_latest_versions(os.environ["MODEL_NAME"])
print(v[0].version)
EOF
          echo "VERSION=$(cat version.txt)" >> $GITHUB_ENV

      - uses: aws-actions/configure-aws-credentials@v3
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - run: |
          aws ecr get-login-password \
          | docker login \
            --username AWS \
            --password-stdin \
            $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

      - run: |
          docker build -t $ECR_REPOSITORY:$VERSION .
          docker tag $ECR_REPOSITORY:$VERSION \
          $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$VERSION
          docker push \
          $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$VERSION

      - run: |
          aws eks update-kubeconfig \
          --name $EKS_CLUSTER \
          --region $AWS_REGION

          kubectl set image deployment/$DEPLOYMENT \
          $CONTAINER=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$VERSION \
          -n $NAMESPACE

EOF


############################
# QA
############################

cat > .github/workflows/deploy-qa.yml << 'EOF'
name: Deploy QA

on:
  push:
    branches:
      - qa
  workflow_dispatch:

env:
  MODEL_NAME: iris-classifier
  AWS_REGION: ${{ secrets.AWS_REGION }}
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}

jobs:

  deploy:

    runs-on: ubuntu-latest
    environment: qa

    steps:

      - uses: actions/checkout@v3

      - run: echo "Deploy QA ready"
EOF


############################
# PROD
############################

cat > .github/workflows/deploy-prod.yml << 'EOF'
name: Deploy Production

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:

  deploy:

    runs-on: ubuntu-latest
    environment: prod

    steps:

      - uses: actions/checkout@v3

      - run: echo "Deploy Production ready"
EOF


git add .github/workflows
git commit -m "enable enterprise mlops pipeline"
git push origin dev
git push origin qa
git push origin main

echo ""
echo "DONE"
echo ""
echo "Test with:"
echo "git commit --allow-empty -m test"
echo "git push origin dev"
