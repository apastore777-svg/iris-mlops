#!/bin/bash

set -e

echo "Creating GitHub workflows..."

mkdir -p .github/workflows


cat > .github/workflows/deploy-dev.yml << 'EOF'
name: Deploy Dev

on:
  push:
    branches:
      - dev
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: dev

    steps:
      - uses: actions/checkout@v3
      - run: echo "Deploy DEV OK"
EOF


cat > .github/workflows/deploy-qa.yml << 'EOF'
name: Deploy QA

on:
  push:
    branches:
      - qa
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: qa

    steps:
      - uses: actions/checkout@v3
      - run: echo "Deploy QA OK"
EOF


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
      - run: echo "Deploy PROD OK"
EOF


echo "Checking branches..."

git fetch origin || true

git checkout main || git checkout -b main
git checkout dev || git checkout -b dev
git checkout qa || git checkout -b qa

git checkout main


echo "Committing workflows..."

git add .github/workflows

git commit -m "setup enterprise mlops workflows" || echo "Nothing to commit"


echo "Pushing branches..."

git push origin main
git push origin dev
git push origin qa


echo ""
echo "DONE"
echo ""
echo "Open GitHub → Actions"
echo "You will see:"
echo "Deploy Dev"
echo "Deploy QA"
echo "Deploy Production"
