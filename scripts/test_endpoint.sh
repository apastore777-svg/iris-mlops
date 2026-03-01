#!/bin/bash

echo '{"inputs": [[5.1,3.5,1.4,0.2]]}' > request.json

aws sagemaker-runtime invoke-endpoint \
--endpoint-name iris-endpoint \
--body fileb://request.json \
--content-type application/json \
response.json \
--region us-east-2

cat response.json
