#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./approve_candidate.sh <version>"
  exit 1
fi

echo "Approving candidate version $VERSION..."

python scripts/promote_model.py $VERSION

echo "Model promoted to CHAMPION"
