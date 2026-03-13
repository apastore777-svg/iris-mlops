# scripts/test_candidate.py

import os
import json
import requests
import pytest
from unittest.mock import patch
import mlflow

# -----------------------------
# Função que executa o teste de qualquer endpoint
# -----------------------------
def run_test_candidate(databricks_host, databricks_token, endpoint):
    url = f"{databricks_host}/serving-endpoints/{endpoint}/invocations"

    headers = {
        "Authorization": f"Bearer {databricks_token}",
        "Content-Type": "application/json"
    }

    payload = {
        "dataframe_records": [
            {
                "sepal length (cm)": 5.1,
                "sepal width (cm)": 3.5,
                "petal length (cm)": 1.4,
                "petal width (cm)": 0.2
            }
        ]
    }

    response = requests.post(url, headers=headers, data=json.dumps(payload))

    if response.status_code != 200:
        raise Exception(f"Model test failed for {endpoint}")

    result = response.json()
    if "predictions" not in result:
        raise Exception(f"Invalid response format for {endpoint}")

    return result

# -----------------------------
# Descoberta automática de modelos no MLflow
# -----------------------------
def get_registered_models():
    # Retorna lista de nomes de modelos registrados no MLflow
    try:
        client = mlflow.tracking.MlflowClient()
        return [m.name for m in client.list_registered_models()]
    except Exception:
        # Se MLflow não estiver configurado (CI/CD), retorna lista de teste mock
        return ["iris-serving-endpoint", "wine-serving-endpoint"]

# -----------------------------
# Test real: roda apenas se variáveis de ambiente estiverem definidas
# -----------------------------
@pytest.mark.skipif(
    not os.environ.get("DATABRICKS_HOST") or not os.environ.get("DATABRICKS_TOKEN"),
    reason="Databricks environment not configured"
)
@pytest.mark.parametrize("endpoint", get_registered_models())
def test_candidate_model_real(endpoint):
    host = os.environ.get("DATABRICKS_HOST")
    token = os.environ.get("DATABRICKS_TOKEN")
    result = run_test_candidate(host, token, endpoint)
    assert "predictions" in result

# -----------------------------
# Test mock: sempre roda no CI/CD
# -----------------------------
@pytest.mark.parametrize("endpoint", get_registered_models())
def test_candidate_model_mock(endpoint):
    mock_host = "http://mock-host"
    mock_token = "mock-token"

    with patch("requests.post") as mock_post:
        # Simula resposta genérica para qualquer modelo
        mock_post.return_value.status_code = 200
        mock_post.return_value.json.return_value = {"predictions": ["mocked"]}

        result = run_test_candidate(mock_host, mock_token, endpoint)
        assert "predictions" in result
        assert result["predictions"][0] == "mocked"
