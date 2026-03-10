import sys
import mlflow
from mlflow.tracking import MlflowClient

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

# ---------------------------------------------------
# Busca champion atual
# ---------------------------------------------------

champion_version = get_version_by_alias(MODEL_NAME, "champion")

challenger_metric = get_metric_for_version(
    MODEL_NAME,
    challenger_version,
    METRIC_NAME
)

print(f"Challenger version: {challenger_version}")
print(f"Challenger {METRIC_NAME}: {challenger_metric}")

# ---------------------------------------------------
# Comparação Champion vs Challenger
# ---------------------------------------------------

if champion_version:

    champion_metric = get_metric_for_version(
        MODEL_NAME,
        champion_version,
        METRIC_NAME
    )

    print(f"Champion version: {champion_version}")
    print(f"Champion {METRIC_NAME}: {champion_metric}")

    if challenger_metric > champion_metric:
        print("RESULT=promote")
    else:
        print("RESULT=skip")

else:
    # primeiro modelo registrado
    print("No champion found")
    print("RESULT=promote")
```

