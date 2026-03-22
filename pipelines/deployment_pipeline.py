import subprocess
import sys

print("🚀 Running deployment pipeline...")

# pegar decisão do compare (simples via arquivo ou env)
decision_file = "promote_decision.txt"

try:
    with open(decision_file, "r") as f:
        decision = f.read().strip()
except FileNotFoundError:
    print("❌ No promotion decision found. Aborting.")
    sys.exit(1)

print(f"Promotion decision received: {decision}")

if decision != "promote":
    print("⛔ Model will NOT be promoted. Stopping pipeline.")
    sys.exit(0)

print("✅ Model approved for deployment")

# Promote model
subprocess.run(["python", "src/deployment/promote_model.py"], check=True)

# Build + push container
subprocess.run(["bash", "scripts/build_and_push.sh"], check=True)

# Deploy
subprocess.run(["bash", "scripts/deploy_from_mlflow.sh", "Production"], check=True)
