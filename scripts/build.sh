#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "data.stack:proxy :: Building UI Author using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-author

docker build -t data.stack.ui-author:$TAG .


echo "****************************************************"
echo "data.stack:proxy :: UI Author Built using TAG :: $TAG"
echo "****************************************************"

echo "****************************************************"
echo "data.stack:proxy :: Building UI Appcenter using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-appcenter

docker build -t data.stack.ui-appcenter:$TAG .


echo "****************************************************"
echo "data.stack:proxy :: UI Appcenter Built using TAG :: $TAG"
echo "****************************************************"


echo "****************************************************"
echo "data.stack:proxy :: Building UI SwaggerUI using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-swagger

docker build -t data.stack.ui-swagger:$TAG .


echo "****************************************************"
echo "data.stack:proxy :: UI SwaggerUI Built using TAG :: $TAG"
echo "****************************************************"


echo "****************************************************"
echo "data.stack:proxy :: Building PROXY using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE

docker build -t data.stack.proxy:$TAG --build-arg LATEST_APPCENTER=$TAG --build-arg LATEST_AUTHOR=$TAG --build-arg LATEST_SWAGGER=$TAG .


echo "****************************************************"
echo "data.stack:proxy :: PROXY Built using TAG :: $TAG"
echo "****************************************************"

echo $TAG > LATEST_PROXY