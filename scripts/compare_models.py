import sys
import mlflow
from mlflow.tracking import MlflowClient

mlflow.set_tracking_uri("databricks")
mlflow.set_registry_uri("databricks-uc")

MODEL_NAME = "workspace.default.iris-classifier"
METRIC_NAME = "accuracy"

client = MlflowClient()


def get_metric_for_version(model_name, version, metric_name):
    mv = client.get_model_version(model_name, version)
    run_id = mv.run_id
    run = client.get_run(run_id)
    return run.data.metrics.get(metric_name)


def get_version_by_alias(model_name, alias):
    try:
        mv = client.get_model_version_by_alias(model_name, alias)
        return mv.version
    except Exception:
        return None


# ---------------------------------------------------
# Recebe versão do challenger via argumento
# ---------------------------------------------------

if len(sys.argv) < 2:
    raise ValueError("MODEL_VERSION não definido")

challenger_version = sys.argv[1]


champion_version = get_version_by_alias(MODEL_NAME, "champion")

challenger_metric = get_metric_for_version(
    MODEL_NAME,
    challenger_version,
    METRIC_NAME
)

print(f"Challenger version: {challenger_version}")
print(f"Challenger accuracy: {challenger_metric}")


if champion_version:

    champion_metric = get_metric_for_version(
        MODEL_NAME,
        champion_version,
        METRIC_NAME
    )

    print(f"Champion version: {champion_version}")
    print(f"Champion accuracy: {champion_metric}")

    if challenger_metric > champion_metric:
        decision = "promote"
    else:
        decision = "skip"

else:

    print("No champion found")
    decision = "promote"


print(f"PROMOTE_DECISION={decision}")
