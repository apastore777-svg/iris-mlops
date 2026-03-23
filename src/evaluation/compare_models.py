import mlflow
from mlflow.tracking import MlflowClient
from databricks.sdk.runtime import dbutils

# ---------------------------------------------------
# Configuração do MLflow no Databricks
# ---------------------------------------------------

mlflow.set_tracking_uri("databricks")
mlflow.set_registry_uri("databricks-uc")

MODEL_NAME = "workspace.default.iris-classifier"
METRIC_NAME = "accuracy"

client = MlflowClient()

# ---------------------------------------------------
# Funções auxiliares
# ---------------------------------------------------

def get_metric_for_version(model_name, version, metric_name):
    mv = client.get_model_version(model_name, version)
    run_id = mv.run_id
    run = client.get_run(run_id)

    metric = run.data.metrics.get(metric_name)

    if metric is None:
        raise ValueError(f"Metric {metric_name} not found for version {version}")

    return metric


def get_version_by_alias(model_name, alias):
    try:
        mv = client.get_model_version_by_alias(model_name, alias)
        return mv.version
    except Exception:
        return None


# ---------------------------------------------------
# Recebe versão do challenger do step anterior
# ---------------------------------------------------

challenger_version = dbutils.jobs.taskValues.get(
    taskKey="train-model",
    key="model_version",
    debugValue="1"
)

print("------------------------------------------------")
print(f"Challenger version received: {challenger_version}")
print("------------------------------------------------")


# ---------------------------------------------------
# Métrica do challenger
# ---------------------------------------------------

challenger_metric = get_metric_for_version(
    MODEL_NAME,
    challenger_version,
    METRIC_NAME
)

print(f"Challenger {METRIC_NAME}: {challenger_metric}")


# ---------------------------------------------------
# Busca champion atual
# ---------------------------------------------------

champion_version = get_version_by_alias(MODEL_NAME, "champion")


# ---------------------------------------------------
# Caso NÃO exista champion
# ---------------------------------------------------

if champion_version is None:

    print("No champion model found.")
    print("Promoting challenger automatically.")

    decision = "promote"
    champion_metric = None


# ---------------------------------------------------
# Caso exista champion
# ---------------------------------------------------

else:

    champion_metric = get_metric_for_version(
        MODEL_NAME,
        champion_version,
        METRIC_NAME
    )

    print(f"Champion version: {champion_version}")
    print(f"Champion {METRIC_NAME}: {champion_metric}")

    IMPROVEMENT_THRESHOLD = 0.01  # 1%

    if challenger_metric > champion_metric + IMPROVEMENT_THRESHOLD:
        decision = "promote"
    else:
        decision = "skip"


# ---------------------------------------------------
# Log de governança no MLflow
# ---------------------------------------------------

mlflow.set_experiment("/Shared/model-governance")

with mlflow.start_run(run_name="model-comparison"):

    mlflow.log_param("model_name", MODEL_NAME)
    mlflow.log_param("challenger_version", challenger_version)
    mlflow.log_param("champion_version", champion_version)

    mlflow.log_metric("challenger_accuracy", challenger_metric)

    if champion_metric is not None:
        mlflow.log_metric("champion_accuracy", champion_metric)

    mlflow.log_param("promotion_decision", decision)


print("------------------------------------------------")
print(f"PROMOTE_DECISION={decision}")
print("------------------------------------------------")

import json

decision = "promote"  # usar sua lógica existente

with open("artifacts/decision.json", "w") as f:
    json.dump({"decision": decision}, f)

print(f"Decision: {decision}")

from mlflow.tracking import MlflowClient

client = MlflowClient()

MODEL_NAME = "iris-classifier"

# pegar última versão
versions = client.get_latest_versions(MODEL_NAME)
latest = sorted(versions, key=lambda x: int(x.version))[-1]

model_version = latest.version

if decision == "promote":
    print(f"Promoting model {model_version} to STAGING")

    client.transition_model_version_stage(
        name=MODEL_NAME,
        version=model_version,
        stage="Staging"
    )
else:
    print(f"Model {model_version} rejected")
