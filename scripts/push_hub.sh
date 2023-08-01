#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`

echo "****************************************************"
echo "datanimbus.io.proxy :: Pushing Image to Docker Hub :: appveen/datanimbus.io.proxy:$TAG"
echo "****************************************************"

docker tag datanimbus.io.proxy:$TAG appveen/datanimbus.io.proxy:$TAG
docker push appveen/datanimbus.io.proxy:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS appveen/datanimbus.io.proxy:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-author:$TAG appveen/datanimbus.io.ui-author:$TAG
docker push appveen/datanimbus.io.ui-author:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS appveen/datanimbus.io.ui-author:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-appcenter:$TAG appveen/datanimbus.io.ui-appcenter:$TAG
docker push appveen/datanimbus.io.ui-appcenter:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS appveen/datanimbus.io.ui-appcenter:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-swagger:$TAG appveen/datanimbus.io.ui-swagger:$TAG
docker push appveen/datanimbus.io.ui-swagger:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS appveen/datanimbus.io.ui-swagger:$TAG"
echo "****************************************************"