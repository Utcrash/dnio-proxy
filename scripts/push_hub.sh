#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`

echo "****************************************************"
echo "data.stack:proxy :: Pushing Image to Docker Hub :: appveen/data.stack.proxy:$TAG"
echo "****************************************************"

docker tag data.stack.proxy:$TAG appveen/data.stack.proxy:$TAG
docker push appveen/data.stack.proxy:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image Pushed to Docker Hub AS appveen/data.stack.proxy:$TAG"
echo "****************************************************"

docker tag data.stack.ui-author:$TAG appveen/data.stack.ui-author:$TAG
docker push appveen/data.stack.ui-author:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image Pushed to Docker Hub AS appveen/data.stack.ui-author:$TAG"
echo "****************************************************"

docker tag data.stack.ui-appcenter:$TAG appveen/data.stack.ui-appcenter:$TAG
docker push appveen/data.stack.ui-appcenter:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image Pushed to Docker Hub AS appveen/data.stack.ui-appcenter:$TAG"
echo "****************************************************"

docker tag data.stack.ui-swagger:$TAG appveen/data.stack.ui-swagger:$TAG
docker push appveen/data.stack.ui-swagger:$TAG

echo "****************************************************"
echo "data.stack:proxy :: Image Pushed to Docker Hub AS appveen/data.stack.ui-swagger:$TAG"
echo "****************************************************"