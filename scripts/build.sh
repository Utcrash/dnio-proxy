#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`


echo "****************************************************"
echo "datanimbus.io.proxy :: Building UI Author using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-author

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t datanimbus.io.ui-author:$TAG .
else 
    docker build -t datanimbus.io.ui-author:$TAG .
fi


echo "****************************************************"
echo "datanimbus.io.proxy :: UI Author Built using TAG :: $TAG"
echo "****************************************************"

echo "****************************************************"
echo "datanimbus.io.proxy :: Building UI Appcenter using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-appcenter

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t datanimbus.io.ui-appcenter:$TAG .
else 
    docker build -t datanimbus.io.ui-appcenter:$TAG .
fi


echo "****************************************************"
echo "datanimbus.io.proxy :: UI Appcenter Built using TAG :: $TAG"
echo "****************************************************"


echo "****************************************************"
echo "datanimbus.io.proxy :: Building UI SwaggerUI using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE/ds-ui-swagger

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t datanimbus.io.ui-swagger:$TAG .
else 
    docker build -t datanimbus.io.ui-swagger:$TAG .
fi


echo "****************************************************"
echo "datanimbus.io.proxy :: UI SwaggerUI Built using TAG :: $TAG"
echo "****************************************************"


echo "****************************************************"
echo "datanimbus.io.proxy :: Building PROXY using TAG :: $TAG"
echo "****************************************************"

cd $WORKSPACE

sed -i.bak s#__image_tag__#$TAG# Dockerfile

if $cleanBuild ; then
    docker build --no-cache -t datanimbus.io.proxy:$TAG --build-arg LATEST_APPCENTER=$TAG --build-arg LATEST_AUTHOR=$TAG --build-arg LATEST_SWAGGER=$TAG .
else 
    docker build -t datanimbus.io.proxy:$TAG --build-arg LATEST_APPCENTER=$TAG --build-arg LATEST_AUTHOR=$TAG --build-arg LATEST_SWAGGER=$TAG .
fi


echo "****************************************************"
echo "datanimbus.io.proxy :: PROXY Built using TAG :: $TAG"
echo "****************************************************"

echo $TAG > LATEST_PROXY