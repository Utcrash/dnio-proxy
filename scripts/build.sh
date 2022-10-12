#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "data.stack:proxy :: Building UI Author using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-author

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t data.stack.ui-author:$TAG .
else 
    docker build -t data.stack.ui-author:$TAG .
fi


echo "****************************************************"
echo "data.stack:proxy :: UI Author Built using TAG :: $TAG"
echo "****************************************************"

echo "****************************************************"
echo "data.stack:proxy :: Building UI Appcenter using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-appcenter

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t data.stack.ui-appcenter:$TAG .
else 
    docker build -t data.stack.ui-appcenter:$TAG .
fi


echo "****************************************************"
echo "data.stack:proxy :: UI Appcenter Built using TAG :: $TAG"
echo "****************************************************"


echo "****************************************************"
echo "data.stack:proxy :: Building UI SwaggerUI using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-swagger

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t data.stack.ui-swagger:$TAG .
else 
    docker build -t data.stack.ui-swagger:$TAG .
fi


echo "****************************************************"
echo "data.stack:proxy :: UI SwaggerUI Built using TAG :: $TAG"
echo "****************************************************"


echo "****************************************************"
echo "data.stack:proxy :: Building PROXY using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t data.stack.proxy:$TAG --build-arg LATEST_APPCENTER=$TAG --build-arg LATEST_AUTHOR=$TAG --build-arg LATEST_SWAGGER=$TAG .
else 
    docker build -t data.stack.proxy:$TAG --build-arg LATEST_APPCENTER=$TAG --build-arg LATEST_AUTHOR=$TAG --build-arg LATEST_SWAGGER=$TAG .
fi


echo "****************************************************"
echo "data.stack:proxy :: PROXY Built using TAG :: $TAG"
echo "****************************************************"

echo $TAG > LATEST_PROXY