
#!/bin/bash
set -e
if [ -f $WORKSPACE/../TOGGLE ]; then
    echo "****************************************************"
    echo "datanimbus.io.proxy :: Toggle mode is on, terminating build"
    echo "datanimbus.io.proxy :: BUILD CANCLED"
    echo "****************************************************"
    exit 0
fi

# sh $WORKSPACE/scripts/setup.sh

cDate=`date +%Y.%m.%d.%H.%M` #Current date and time

if [ -f $WORKSPACE/../CICD ]; then
    CICD=`cat $WORKSPACE/../CICD`
fi
if [ -f $WORKSPACE/../DATA_STACK_RELEASE ]; then
    REL=`cat $WORKSPACE/../DATA_STACK_RELEASE`
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
    echo "datanimbus.io.proxy :: Please Create file DATA_STACK_RELEASE with the releaese at $WORKSPACE or provide it as 1st argument of this script."
    echo "datanimbus.io.proxy :: BUILD FAILED"
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
    echo "datanimbus.io.proxy :: CICI env found"
    echo "****************************************************"
    TAG=$TAG"_"$cDate
    if [ ! -f $WORKSPACE/../DATA_STACK_NAMESPACE ]; then
        echo "****************************************************"
        echo "datanimbus.io.proxy :: Please Create file DATA_STACK_NAMESPACE with the namespace at $WORKSPACE"
        echo "datanimbus.io.proxy :: BUILD FAILED"
        echo "****************************************************"
        exit 0
    fi
    DATA_STACK_NS=`cat $WORKSPACE/../DATA_STACK_NAMESPACE`
fi
cd $WORKSPACE
# echo "****************************************************"
# echo "datanimbus.io.proxy :: Copying ds-ui-author files"
# echo "****************************************************"
# if [ ! -d author ]; then
#     mkdir author
# else
#     rm -rf author/*
# fi
# cp -r $WORKSPACE/../ds-ui-author/dist/* author/
# echo "****************************************************"
# echo "datanimbus.io.proxy :: Copying ds-ui-appcenter files"
# echo "****************************************************"
# if [ ! -d appcenter ]; then
#     mkdir appcenter
# else
#     rm -rf appcenter/*
# fi
# cp -r $WORKSPACE/../ds-ui-appcenter/dist/* appcenter/
# echo "****************************************************"
# echo "datanimbus.io.proxy :: Copying ds-ui-swagger files"
# echo "****************************************************"
# if [ ! -d swaggerUI ]; then
#     mkdir swaggerUI
# else
#     rm -rf swaggerUI/*
# fi
# cp -r $WORKSPACE/../ds-ui-swagger/* swaggerUI/

echo "****************************************************"
echo "datanimbus.io.proxy :: using build :: "$TAG
echo "****************************************************"

sh $WORKSPACE/scripts/prepare_yaml.sh $REL $2

# env GOOS=linux GOARCH=386 go build -ldflags="-s -w" -o goroute .

if [ -f $WORKSPACE/../CLEAN_BUILD_PROXY ]; then
    echo "****************************************************"
    echo "datanimbus.io.proxy :: Doing a clean build"
    echo "****************************************************"
    echo "****************************************************"
    echo " Generating key and cert to package"
    echo "****************************************************"
    openssl req -out data_stack_server.csr -new -newkey rsa:2048 -nodes -keyout data_stack_server.key  -subj "/C=US/ST=California/L=PaloAlto/O=CAPIOT/OU=Engineering/CN=it@capiot.com"
    openssl x509 -signkey data_stack_server.key -in data_stack_server.csr -req -days 365 -out data_stack_server.crt
    
    docker build --no-cache -t datanimbus.io.proxy:$TAG --build-arg TAG=$HOTFIX --build-arg LATEST_APPCENTER=$LATEST_APPCENTER --build-arg LATEST_AUTHOR=$LATEST_AUTHOR --build-arg LATEST_SWAGGER=$LATEST_SWAGGER .
    rm $WORKSPACE/../CLEAN_BUILD_PROXY

    echo "****************************************************"
    echo "datanimbus.io.proxy :: Copying deployment files"
    echo "****************************************************"

    if [ $CICD ]; then
        sed -i.bak s#__docker_registry_server__#$DOCKER_REG# proxy.yaml
        sed -i.bak s/__release_tag__/"'$REL'"/ proxy.yaml
        sed -i.bak s#__release__#$TAG# proxy.yaml
        sed -i.bak s#__namespace__#$DATA_STACK_NS# proxy.yaml
        sed -i.bak '/imagePullSecrets/d' proxy.yaml
        sed -i.bak '/- name: regsecret/d' proxy.yaml

        kubectl delete deploy proxy -n $DATA_STACK_NS || true # deleting old deployement
        kubectl delete service proxy -n $DATA_STACK_NS || true # deleting old service
        #creating pmw deployment
        kubectl create -f proxy.yaml
    fi

else
    echo "****************************************************"
    echo "datanimbus.io.proxy :: Doing a normal build"
    echo "****************************************************"
    docker build -t datanimbus.io.proxy:$TAG --build-arg TAG=$HOTFIX --build-arg LATEST_APPCENTER=$LATEST_APPCENTER --build-arg LATEST_AUTHOR=$LATEST_AUTHOR --build-arg LATEST_SWAGGER=$LATEST_SWAGGER .
    if [ $CICD ]; then
        if [ $DOCKER_REG ]; then
            kubectl set image deployment/proxy proxy=$DOCKER_REG/datanimbus.io.proxy:$TAG -n $DATA_STACK_NS --record=true
        else 
            kubectl set image deployment/proxy proxy=datanimbus.io.proxy:$TAG -n $DATA_STACK_NS --record=true
        fi
    fi
fi
if [ $DOCKER_REG ]; then
    echo "****************************************************"
    echo "datanimbus.io.proxy :: Docker Registry found, pushing image"
    echo "****************************************************"

    docker tag datanimbus.io.proxy:$TAG $DOCKER_REG/datanimbus.io.proxy:$TAG
    docker push $DOCKER_REG/datanimbus.io.proxy:$TAG
fi
echo "****************************************************"
echo "datanimbus.io.proxy :: BUILD SUCCESS :: datanimbus.io.proxy:$TAG"
echo "****************************************************"
echo $TAG > $WORKSPACE/../LATEST_PROXY