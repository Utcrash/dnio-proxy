#!/bin/bash
set -e
if [ -f $WORKSPACE/../TOGGLE ]; then
    echo "****************************************************"
    echo "odp:proxy :: Toggle mode is on, terminating build"
    echo "odp:proxy :: BUILD CANCLED"
    echo "****************************************************"
    exit 0
fi

# sh $WORKSPACE/scripts/setup.sh

cDate=`date +%Y.%m.%d.%H.%M` #Current date and time

if [ -f $WORKSPACE/../CICD ]; then
    CICD=`cat $WORKSPACE/../CICD`
fi
if [ -f $WORKSPACE/../ODP_RELEASE ]; then
    REL=`cat $WORKSPACE/../ODP_RELEASE`
fi
if [ -f $WORKSPACE/../DOCKER_REGISTRY ]; then
    DOCKER_REG=`cat $WORKSPACE/../DOCKER_REGISTRY`
fi
BRANCH='dev'
if [ -f $WORKSPACE/../BRANCH ]; then
    BRANCH=`cat $WORKSPACE/../BRANCH`
fi
if [ -f $WORKSPACE/../LATEST_AUTHOR ]; then
    LATEST_AUTHOR=`cat $WORKSPACE/../LATEST_AUTHOR`
fi
if [ -f $WORKSPACE/../LATEST_APPCENTER ]; then
    LATEST_APPCENTER=`cat $WORKSPACE/../LATEST_APPCENTER`
fi
if [ -f $WORKSPACE/../LATEST_SWAGGER ]; then
    LATEST_SWAGGER=`cat $WORKSPACE/../LATEST_SWAGGER`
fi
if [ $1 ]; then
    REL=$1
fi
if [ ! $REL ]; then
    echo "****************************************************"
    echo "odp:proxy :: Please Create file ODP_RELEASE with the releaese at $WORKSPACE or provide it as 1st argument of this script."
    echo "odp:proxy :: BUILD FAILED"
    echo "****************************************************"
    exit 0
fi
TAG=$REL
if [ $2 ]; then
    TAG=$TAG"-"$2
fi
HOTFIX=$TAG
if [ $3 ]; then
    BRANCH=$3
fi
if [ $CICD ]; then
    echo "****************************************************"
    echo "odp:proxy :: CICI env found"
    echo "****************************************************"
    TAG=$TAG"_"$cDate
    if [ ! -f $WORKSPACE/../ODP_NAMESPACE ]; then
        echo "****************************************************"
        echo "odp:proxy :: Please Create file ODP_NAMESPACE with the namespace at $WORKSPACE"
        echo "odp:proxy :: BUILD FAILED"
        echo "****************************************************"
        exit 0
    fi
    ODP_NS=`cat $WORKSPACE/../ODP_NAMESPACE`
fi
cd $WORKSPACE
# echo "****************************************************"
# echo "odp:proxy :: Copying odp-ui-author files"
# echo "****************************************************"
# if [ ! -d author ]; then
#     mkdir author
# else
#     rm -rf author/*
# fi
# cp -r $WORKSPACE/../odp-ui-author/dist/* author/
# echo "****************************************************"
# echo "odp:proxy :: Copying odp-ui-appcenter files"
# echo "****************************************************"
# if [ ! -d appcenter ]; then
#     mkdir appcenter
# else
#     rm -rf appcenter/*
# fi
# cp -r $WORKSPACE/../odp-ui-appcenter/dist/* appcenter/
# echo "****************************************************"
# echo "odp:proxy :: Copying odp-ui-swagger files"
# echo "****************************************************"
# if [ ! -d swaggerUI ]; then
#     mkdir swaggerUI
# else
#     rm -rf swaggerUI/*
# fi
# cp -r $WORKSPACE/../odp-ui-swagger/* swaggerUI/

echo "****************************************************"
echo "odp:proxy :: using build :: "$TAG
echo "****************************************************"

sh $WORKSPACE/scripts/prepare_yaml.sh $REL $2

# env GOOS=linux GOARCH=386 go build -ldflags="-s -w" -o goroute .

if [ -f $WORKSPACE/../CLEAN_BUILD_PROXY ]; then
    echo "****************************************************"
    echo "odp:proxy :: Doing a clean build"
    echo "****************************************************"
    echo "****************************************************"
    echo " Generating key and cert to package"
    echo "****************************************************"
    openssl req -out odp_server.csr -new -newkey rsa:2048 -nodes -keyout odp_server.key  -subj "/C=US/ST=California/L=PaloAlto/O=CAPIOT/OU=Engineering/CN=it@capiot.com"
    openssl x509 -signkey odp_server.key -in odp_server.csr -req -days 365 -out odp_server.crt
    
    docker build --no-cache -t odp:proxy.$TAG --build-arg TAG=$HOTFIX --build-arg LATEST_APPCENTER=$LATEST_APPCENTER --build-arg LATEST_AUTHOR=$LATEST_AUTHOR --build-arg LATEST_SWAGGER=$LATEST_SWAGGER .
    rm $WORKSPACE/../CLEAN_BUILD_PROXY

    echo "****************************************************"
    echo "odp:proxy :: Copying deployment files"
    echo "****************************************************"

    if [ $CICD ]; then
        sed -i.bak s#__docker_registry_server__#$DOCKER_REG# proxy.yaml
        sed -i.bak s/__release_tag__/"'$REL'"/ proxy.yaml
        sed -i.bak s#__release__#$TAG# proxy.yaml
        sed -i.bak s#__namespace__#$ODP_NS# proxy.yaml
        sed -i.bak '/imagePullSecrets/d' proxy.yaml
        sed -i.bak '/- name: regsecret/d' proxy.yaml

        kubectl delete deploy proxy -n $ODP_NS || true # deleting old deployement
        kubectl delete service proxy -n $ODP_NS || true # deleting old service
        #creating pmw deployment
        kubectl create -f proxy.yaml
    fi

else
    echo "****************************************************"
    echo "odp:proxy :: Doing a normal build"
    echo "****************************************************"
    docker build -t odp:proxy.$TAG --build-arg TAG=$HOTFIX --build-arg LATEST_APPCENTER=$LATEST_APPCENTER --build-arg LATEST_AUTHOR=$LATEST_AUTHOR --build-arg LATEST_SWAGGER=$LATEST_SWAGGER .
    if [ $CICD ]; then
        kubectl set image deployment/proxy proxy=odp:proxy.$TAG -n $ODP_NS --record=true
    fi
fi
if [ $DOCKER_REG ]; then
    echo "****************************************************"
    echo "odp:proxy :: Docker Registry found, pushing image"
    echo "****************************************************"

    docker tag odp:proxy.$TAG $DOCKER_REG/odp:proxy.$TAG
    docker push $DOCKER_REG/odp:proxy.$TAG
fi
echo "****************************************************"
echo "odp:proxy :: BUILD SUCCESS :: odp:proxy.$TAG"
echo "****************************************************"
echo $TAG > $WORKSPACE/../LATEST_PROXY