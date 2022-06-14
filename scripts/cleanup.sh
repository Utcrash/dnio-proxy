#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "data.stack:proxy :: Cleaning Up Local Images :: $TAG"
echo "****************************************************"


docker rmi data.stack.ui-author:$TAG -f
docker rmi data.stack.ui-appcenter:$TAG -f
docker rmi data.stack.ui-swagger:$TAG -f
docker rmi data.stack.proxy:$TAG -f