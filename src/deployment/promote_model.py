from mlflow.tracking import MlflowClient

client = MlflowClient()

MODEL_NAME = "iris-classifier"

# pega modelo em staging
staging_versions = client.get_latest_versions(MODEL_NAME, stages=["Staging"])

if not staging_versions:
    raise Exception("No model in STAGING")

model_version = staging_versions[0].version

print(f"Promoting model {model_version} to PRODUCTION")

# move para produção
client.transition_model_version_stage(
    name=MODEL_NAME,
    version=model_version,
    stage="Production"
)

# opcional: arquivar versões antigas
prod_versions = client.get_latest_versions(MODEL_NAME, stages=["Production"])

for v in prod_versions:
    if v.version != model_version:
        client.transition_model_version_stage(
            name=MODEL_NAME,
            version=v.version,
            stage="Archived"
        )
