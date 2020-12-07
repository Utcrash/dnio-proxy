#!/bin/bash

echo "****************************************************"
echo "data.stack:proxy :: Copying yaml file "
echo "****************************************************"
if [ ! -d $WORKSPACE/../yamlFiles ]; then
    mkdir $WORKSPACE/../yamlFiles
fi

REL=$1
if [ $2 ]; then
    REL=$REL-$2
fi

rm -rf $WORKSPACE/../yamlFiles/nginx.*
cp $WORKSPACE/proxy.yaml $WORKSPACE/../yamlFiles/nginx.$REL.yaml
cd $WORKSPACE/../yamlFiles/
echo "****************************************************"
echo "data.stack:proxy :: Preparing yaml file "
echo "****************************************************"
sed -i.bak s/__release_tag__/"'$1'"/ nginx.$REL.yaml
sed -i.bak s/__release__/$REL/ nginx.$REL.yaml