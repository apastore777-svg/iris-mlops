#!/bin/bash

ACCOUNT=494722910828
REGION=us-east-2
IMAGE=iris-model

aws ecr get-login-password --region $REGION | \
docker login --username AWS \
--password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

docker build \
-t $IMAGE \
-f serving/iris/Dockerfile \
.

docker tag $IMAGE \
$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$IMAGE:latest

docker push \
$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$IMAGE:latest
