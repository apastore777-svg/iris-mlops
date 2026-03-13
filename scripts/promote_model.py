import mlflow
from mlflow.tracking import MlflowClient
from databricks.sdk.runtime import dbutils

# ---------------------------------------------------
# Configuração do MLflow
# ---------------------------------------------------

mlflow.set_tracking_uri("databricks")
mlflow.set_registry_uri("databricks-uc")

MODEL_NAME = "workspace.default.iris-classifier"

client = MlflowClient()

# ---------------------------------------------------
# Recupera decisão de promoção
# ---------------------------------------------------

decision = dbutils.jobs.taskValues.get(
    taskKey="compare-models",
    key="promotion_decision",
    debugValue="skip"
)

print(f"Promotion decision received: {decision}")

# ---------------------------------------------------
# Se decisão for SKIP, encerra o step
# ---------------------------------------------------

if decision != "promote":
    print("Model will NOT be promoted.")
    exit(0)

# ---------------------------------------------------
# Recupera versão do modelo treinado
# ---------------------------------------------------

model_version = dbutils.jobs.taskValues.get(
    taskKey="train-model",
    key="model_version",
    debugValue="1"
)

print(f"Promoting model version: {model_version}")

# ---------------------------------------------------
# Promove modelo para champion
# ---------------------------------------------------

client.set_registered_model_alias(
    name=MODEL_NAME,
    alias="champion",
    version=model_version
)

print(f"Model version {model_version} promoted to champion")
