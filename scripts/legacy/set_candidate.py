import mlflow
import sys

model_name = "workspace.default.iris-classifier"
version = sys.argv[1]

mlflow.set_tracking_uri("databricks")

client = mlflow.MlflowClient()

print(f"Setting version {version} as candidate...")

client.set_registered_model_alias(
    name=model_name,
    alias="candidate",
    version=version
)

print("Alias candidate updated successfully.")
