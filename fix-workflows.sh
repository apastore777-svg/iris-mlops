#!/bin/bash

set -e

echo "Creating .github/workflows..."

mkdir -p .github/workflows


echo "Creating deploy-dev.yml..."

cat > .github/workflows/deploy-dev.yml <<EOF
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


echo "Creating deploy-qa.yml..."

cat > .github/workflows/deploy-qa.yml <<EOF
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


echo "Creating deploy-prod.yml..."

cat > .github/workflows/deploy-prod.yml <<EOF
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


echo "Commit..."

git add .github/workflows || true
git commit -m "fix workflows naming" || true

echo "Push..."

git push origin dev || true
git push origin qa || true
git push origin main || true

echo "DONE"
