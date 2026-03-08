import mlflow
import sys

model_name = "workspace.default.iris-classifier"
version = sys.argv[1]

mlflow.set_tracking_uri("databricks")

client = mlflow.MlflowClient()

print(f"Promoting version {version} to champion...")

client.set_registered_model_alias(
    name=model_name,
    alias="champion",
    version=version
)

print("Alias champion updated successfully.")
