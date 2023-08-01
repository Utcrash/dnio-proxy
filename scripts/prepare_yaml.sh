#!/bin/bash

set -e

echo "****************************************************"
echo "datanimbus.io.proxy :: Copying yaml file "
echo "****************************************************"
if [ ! -d yamlFiles ]; then
    mkdir yamlFiles
fi

TAG=`cat CURRENT_PROXY`

rm -rf yamlFiles/proxy.*
cp proxy.yaml yamlFiles/proxy.$TAG.yaml
cd yamlFiles/
echo "****************************************************"
echo "datanimbus.io.proxy :: Preparing yaml file "
echo "****************************************************"

sed -i.bak s/__release__/$TAG/ proxy.$TAG.yaml

echo "****************************************************"
echo "datanimbus.io.proxy :: yaml file saved"
echo "****************************************************"