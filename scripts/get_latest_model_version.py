import mlflow
from mlflow.tracking import MlflowClient

model_name = "workspace.default.iris-classifier"

client = MlflowClient()

versions = client.search_model_versions(f"name='{model_name}'")

if not versions:
    raise Exception("No model versions found in registry")

latest = max(int(v.version) for v in versions)

print(latest)
