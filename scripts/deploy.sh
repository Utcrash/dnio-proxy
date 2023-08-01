#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "datanimbus.io.proxy :: Deploying Image in K8S :: $NAMESPACE"
echo "****************************************************"

kubectl set image deployment/proxy proxy=$ECR_URL/datanimbus.io.proxy:$TAG -n $NAMESPACE --record=true


echo "****************************************************"
echo "datanimbus.io.proxy :: Image Deployed in K8S AS $ECR_URL/datanimbus.io.proxy:$TAG"
echo "****************************************************"