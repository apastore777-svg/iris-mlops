import mlflow
from mlflow.tracking import MlflowClient
from databricks.sdk.runtime import dbutils

mlflow.set_tracking_uri("databricks")
mlflow.set_registry_uri("databricks-uc")

MODEL_NAME = "workspace.default.iris-classifier"

client = MlflowClient()

# ---------------------------------------------
# Pega versão do modelo treinado
# ---------------------------------------------

model_version = dbutils.jobs.taskValues.get(
    taskKey="train-model",
    key="model_version",
    debugValue="1"
)

print(f"Promoting model version: {model_version}")

# ---------------------------------------------
# Promove para champion
# ---------------------------------------------

client.set_registered_model_alias(
    name=MODEL_NAME,
    alias="champion",
    version=model_version
)

print(f"Model version {model_version} promoted to champion")
