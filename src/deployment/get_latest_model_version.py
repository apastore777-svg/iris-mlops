from mlflow.tracking import MlflowClient

client = MlflowClient()

MODEL_NAME = "iris-classifier"

versions = client.get_latest_versions(MODEL_NAME, stages=["Staging"])

if not versions:
    raise Exception("No model in STAGING")

model_version = versions[0].version

print(model_version)
