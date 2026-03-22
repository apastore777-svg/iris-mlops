import os
import subprocess

print("🔍 Running model validation pipeline...")

# Compare models
subprocess.run(["python", "src/evaluation/compare_models.py"], check=True)

# Test endpoint
subprocess.run(["python", "tests/serving/test_candidate.py"], check=True)
