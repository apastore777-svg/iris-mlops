#!/bin/bash

set -e

echo "======================================"
echo "Fixing iris-mlops project structure"
echo "======================================"

ROOT=$(pwd)

echo ""
echo "Project root:"
echo $ROOT

############################################
echo ""
echo "1. Removing unnecessary files..."

rm -f structure.txt || true
rm -rf training/mlruns || true

echo "OK"


############################################
echo ""
echo "2. Creating config directory..."

mkdir -p config

touch config/dev.env
touch config/prod.env
touch config/mlflow.env

echo "OK"


############################################
echo ""
echo "3. Creating build directory..."

mkdir -p build

echo "OK"


############################################
echo ""
echo "4. Creating .gitignore..."

cat <<EOF > .gitignore
venv/
mlruns/
training/mlruns/
__pycache__/
*.pyc
.env
build/
structure.txt
EOF

echo "OK"


############################################
echo ""
echo "5. Ensuring scripts are executable..."

chmod +x scripts/*.sh || true

echo "OK"


############################################
echo ""
echo "6. Validating serving directory..."

if [ ! -f serving/iris/Dockerfile ]; then
    echo "ERROR: serving/iris/Dockerfile not found"
    exit 1
fi

if [ ! -f serving/iris/serve.sh ]; then
    echo "ERROR: serving/iris/serve.sh not found"
    exit 1
fi

chmod +x serving/iris/serve.sh

echo "OK"


############################################
echo ""
echo "7. Creating SageMaker infra templates..."

mkdir -p infra/aws/sagemaker

cat <<EOF > infra/aws/sagemaker/model.json
{
  "ModelName": "iris-model",
  "PrimaryContainer": {
    "Image": "ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/iris-model:latest"
  },
  "ExecutionRoleArn": "SAGEMAKER_ROLE"
}
EOF


cat <<EOF > infra/aws/sagemaker/endpoint-config.json
{
  "EndpointConfigName": "iris-config",
  "ProductionVariants": [
    {
      "VariantName": "AllTraffic",
      "ModelName": "iris-model",
      "InstanceType": "ml.t2.medium",
      "InitialInstanceCount": 1
    }
  ]
}
EOF


cat <<EOF > infra/aws/sagemaker/endpoint.json
{
  "EndpointName": "iris-endpoint",
  "EndpointConfigName": "iris-config"
}
EOF

echo "OK"


############################################
echo ""
echo "8. Validating directories..."

dirs=(
infra
models
serving
scripts
training
.github
)

for d in "${dirs[@]}"
do
    if [ -d "$d" ]; then
        echo "$d OK"
    else
        echo "$d MISSING"
    fi
done


############################################
echo ""
echo "======================================"
echo "Structure fixed successfully"
echo "======================================"
