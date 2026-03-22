#!/bin/bash

set -e

echo "=============================="
echo "Refactoring MLOps structure..."
echo "=============================="

# 1. Criar nova estrutura
echo "📁 Creating new folders..."

mkdir -p src/training
mkdir -p src/evaluation
mkdir -p src/deployment
mkdir -p pipelines

# 2. Mover training
echo "🔄 Moving training scripts..."

if [ -f src/training/train_iris_mlflow.py ]; then
  mv src/training/train_iris_mlflow.py src/training/train_model.py
fi

# 3. Mover scripts para src organizado
echo "🔄 Organizing scripts..."

if [ -f scripts/compare_models.py ]; then
  mv scripts/compare_models.py src/evaluation/
fi

if [ -f scripts/promote_model.py ]; then
  mv scripts/promote_model.py src/deployment/
fi

if [ -f scripts/get_latest_model_version.py ]; then
  mv scripts/get_latest_model_version.py src/deployment/
fi

# 4. Criar pipeline de training
echo "⚙️ Creating training pipeline..."

cat <<EOF > pipelines/training_pipeline.py
from src.training.train_model import main as train

if __name__ == "__main__":
    print("🚀 Running training pipeline...")
    train()
EOF

# 5. Criar pipeline de validação
echo "⚙️ Creating validation pipeline..."

cat <<EOF > pipelines/model_validation_pipeline.py
import os
import subprocess

print("🔍 Running model validation pipeline...")

# Compare models
subprocess.run(["python", "src/evaluation/compare_models.py"], check=True)

# Test endpoint
subprocess.run(["python", "tests/serving/test_candidate.py"], check=True)
EOF

# 6. Criar pipeline de deploy
echo "⚙️ Creating deployment pipeline..."

cat <<EOF > pipelines/deployment_pipeline.py
import subprocess

print("🚀 Running deployment pipeline...")

# Promote model
subprocess.run(["python", "src/deployment/promote_model.py"], check=True)

# Build + push container
subprocess.run(["bash", "scripts/build_and_push.sh"], check=True)

# Deploy
subprocess.run(["bash", "scripts/deploy_from_mlflow.sh", "Production"], check=True)
EOF

# 7. Ajustar script principal local
echo "⚙️ Updating local pipeline script..."

cat <<EOF > scripts/run_local_pipeline.sh
#!/bin/bash

set -e

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
EOF

chmod +x scripts/run_local_pipeline.sh

# 8. Backup scripts antigos (opcional)
echo "📦 Backing up old scripts..."

mkdir -p scripts/legacy

mv scripts/set_candidate.py scripts/legacy/ 2>/dev/null || true
mv scripts/update_serving_endpoint.sh scripts/legacy/ 2>/dev/null || true
mv scripts/test_endpoint.sh scripts/legacy/ 2>/dev/null || true

echo "=============================="
echo "✅ Refactor DONE!"
echo "=============================="

echo ""
echo "👉 Now run:"
echo "bash scripts/run_local_pipeline.sh"
