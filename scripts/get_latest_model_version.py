import mlflow
from mlflow.tracking import MlflowClient

mlflow.set_tracking_uri("databricks")
mlflow.set_registry_uri("databricks-uc")

model_name = "workspace.default.iris-classifier"

client = MlflowClient()

versions = list(client.search_model_versions(f"name='{model_name}'"))

if not versions:
    raise Exception(f"No versions found for model {model_name}")

latest = max(versions, key=lambda v: int(v.version)).version

print(latest)
