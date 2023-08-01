#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "datanimbus.io.proxy :: Cleaning Up Local Images :: $TAG"
echo "****************************************************"


docker rmi datanimbus.io.ui-author:$TAG -f
docker rmi datanimbus.io.ui-appcenter:$TAG -f
docker rmi datanimbus.io.ui-swagger:$TAG -f
docker rmi datanimbus.io.proxy:$TAG -f