#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`

echo "****************************************************"
echo "datanimbus.io.proxy :: Pushing Image to Docker Hub :: datanimbus/datanimbus.io.proxy:$TAG"
echo "****************************************************"

docker tag datanimbus.io.proxy:$TAG datanimbus/datanimbus.io.proxy:$TAG
docker push datanimbus/datanimbus.io.proxy:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS datanimbus/datanimbus.io.proxy:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-author:$TAG datanimbus/datanimbus.io.ui-author:$TAG
docker push datanimbus/datanimbus.io.ui-author:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS datanimbus/datanimbus.io.ui-author:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-appcenter:$TAG datanimbus/datanimbus.io.ui-appcenter:$TAG
docker push datanimbus/datanimbus.io.ui-appcenter:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS datanimbus/datanimbus.io.ui-appcenter:$TAG"
echo "****************************************************"

docker tag datanimbus.io.ui-swagger:$TAG datanimbus/datanimbus.io.ui-swagger:$TAG
docker push datanimbus/datanimbus.io.ui-swagger:$TAG

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Pushed to Docker Hub AS datanimbus/datanimbus.io.ui-swagger:$TAG"
echo "****************************************************"