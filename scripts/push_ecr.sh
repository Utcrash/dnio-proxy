#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "datanimbus.io.proxy :: Pushing Image to ECR :: $ECR_URL/datanimbus.io.proxy:$TAG"
echo "****************************************************"

$(aws ecr get-login --no-include-email)
docker tag datanimbus.io.proxy:$TAG $ECR_URL/datanimbus.io.proxy:$TAG
docker push $ECR_URL/datanimbus.io.proxy:$TAG


echo "****************************************************"
echo "datanimbus.io.proxy :: Image pushed to ECR AS $ECR_URL/datanimbus.io.proxy:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-author:$TAG $ECR_URL/datanimbus.io.ui-author:$TAG
docker push $ECR_URL/datanimbus.io.ui-author:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image pushed to ECR AS $ECR_URL/datanimbus.io.ui-author:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-appcenter:$TAG $ECR_URL/datanimbus.io.ui-appcenter:$TAG
docker push $ECR_URL/datanimbus.io.ui-appcenter:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image pushed to ECR AS $ECR_URL/datanimbus.io.ui-appcenter:$TAG"
echo "****************************************************"


docker tag datanimbus.io.ui-swagger:$TAG $ECR_URL/datanimbus.io.ui-swagger:$TAG
docker push $ECR_URL/datanimbus.io.ui-swagger:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image pushed to ECR AS $ECR_URL/datanimbus.io.ui-swagger:$TAG"
echo "****************************************************"