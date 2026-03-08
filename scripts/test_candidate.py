import os
import requests
import json

DATABRICKS_HOST = os.environ.get("DATABRICKS_HOST")
DATABRICKS_TOKEN = os.environ.get("DATABRICKS_TOKEN")

ENDPOINT = "iris-serving-endpoint"

url = f"{DATABRICKS_HOST}/serving-endpoints/{ENDPOINT}/invocations"

headers = {
    "Authorization": f"Bearer {DATABRICKS_TOKEN}",
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

print("Testing candidate model...")

response = requests.post(
    url,
    headers=headers,
    data=json.dumps(payload)
)

print("Status:", response.status_code)
print("Response:", response.text)

if response.status_code != 200:
    raise Exception("Model test failed")

result = response.json()

if "predictions" not in result:
    raise Exception("Invalid response format")

print("Model test PASSED")
