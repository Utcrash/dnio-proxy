#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "data.stack:proxy :: Pushing Image to ECR :: $ECR_URL/data.stack.proxy:$TAG"
echo "****************************************************"

$(aws ecr get-login --no-include-email)
docker tag data.stack.proxy:$TAG $ECR_URL/data.stack.proxy:$TAG
docker push $ECR_URL/data.stack.proxy:$TAG


echo "****************************************************"
echo "data.stack:proxy :: Image pushed to ECR AS $ECR_URL/data.stack.proxy:$TAG"
echo "****************************************************"

docker tag data.stack.ui-author:$TAG $ECR_URL/data.stack.ui-author:$TAG
docker push $ECR_URL/data.stack.ui-author:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image pushed to ECR AS $ECR_URL/data.stack.ui-author:$TAG"
echo "****************************************************"

docker tag data.stack.ui-appcenter:$TAG $ECR_URL/data.stack.ui-appcenter:$TAG
docker push $ECR_URL/data.stack.ui-appcenter:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image pushed to ECR AS $ECR_URL/data.stack.ui-appcenter:$TAG"
echo "****************************************************"


docker tag data.stack.ui-swaggerUI:$TAG $ECR_URL/data.stack.ui-swaggerUI:$TAG
docker push $ECR_URL/data.stack.ui-swaggerUI:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image pushed to ECR AS $ECR_URL/data.stack.ui-swaggerUI:$TAG"
echo "****************************************************"