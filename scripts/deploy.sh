#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "data.stack:proxy :: Deploying Image in K8S :: $NAMESPACE"
echo "****************************************************"

kubectl set image deployment/proxy proxy=$ECR_URL/data.stack.proxy:$TAG -n $NAMESPACE --record=true


echo "****************************************************"
echo "data.stack:proxy :: Image Deployed in K8S AS $ECR_URL/data.stack.proxy:$TAG"
echo "****************************************************"