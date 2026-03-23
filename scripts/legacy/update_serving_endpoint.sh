#!/bin/bash

VERSION=$1

echo "Updating endpoint to model version $VERSION..."

cat <<EOF > serving/api/update_endpoint.json
{
  "served_entities": [
    {
      "name": "iris-classifier",
      "entity_name": "workspace.default.iris-classifier",
      "entity_version": "$VERSION",
      "workload_size": "Small",
      "scale_to_zero_enabled": true
    }
  ],
  "traffic_config": {
    "routes": [
      {
        "served_model_name": "iris-classifier",
        "traffic_percentage": 100
      }
    ]
  }
}
EOF

curl -X PUT \
$DATABRICKS_HOST/api/2.0/serving-endpoints/iris-serving-endpoint/config \
-H "Authorization: Bearer $DATABRICKS_TOKEN" \
-H "Content-Type: application/json" \
-d @serving/api/update_endpoint.json
