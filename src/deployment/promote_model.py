from mlflow.tracking import MlflowClient

MODEL_NAME = "iris-classifier"

client = MlflowClient()

try:
    # pega o modelo candidate
    candidate = client.get_model_version_by_alias(MODEL_NAME, "candidate")

    # promove para champion
    client.set_registered_model_alias(
        name=MODEL_NAME,
        alias="champion",
        version=candidate.version
    )

    print(f"🚀 Promoted version {candidate.version} to champion")

except Exception as e:
    print(f"❌ Error promoting model: {e}")
    exit(1)
