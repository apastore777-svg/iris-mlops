#!/bin/bash

REGION=us-east-2

aws sagemaker delete-endpoint \
--endpoint-name iris-endpoint \
--region $REGION 2>/dev/null

aws sagemaker create-endpoint \
--endpoint-name iris-endpoint \
--endpoint-config-name iris-config \
--region $REGION
