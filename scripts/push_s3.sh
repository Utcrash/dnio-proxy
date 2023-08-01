#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`

echo "****************************************************"
echo "datanimbus.io.proxy :: Saving Image to AWS S3 :: $S3_BUCKET/stable-builds"
echo "****************************************************"

TODAY_FOLDER=`date ++%Y_%m_%d`

docker save -o datanimbus.io.proxy_$TAG.tar datanimbus.io.proxy:$TAG
bzip2 datanimbus.io.proxy_$TAG.tar
aws s3 cp datanimbus.io.proxy_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/datanimbus.io.proxy_$TAG.tar.bz2
rm datanimbus.io.proxy_$TAG.tar.bz2

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Saved to AWS S3 AS datanimbus.io.proxy_$TAG.tar.bz2"
echo "****************************************************"

docker save -o datanimbus.io.ui-author_$TAG.tar datanimbus.io.ui-author:$TAG
bzip2 datanimbus.io.ui-author_$TAG.tar
aws s3 cp datanimbus.io.ui-author_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/datanimbus.io.ui-author_$TAG.tar.bz2
rm datanimbus.io.ui-author_$TAG.tar.bz2

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Saved to AWS S3 AS datanimbus.io.ui-author_$TAG.tar.bz2"
echo "****************************************************"

docker save -o datanimbus.io.ui-appcenter_$TAG.tar datanimbus.io.ui-appcenter:$TAG
bzip2 datanimbus.io.ui-appcenter_$TAG.tar
aws s3 cp datanimbus.io.ui-appcenter_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/datanimbus.io.ui-appcenter_$TAG.tar.bz2
rm datanimbus.io.ui-appcenter_$TAG.tar.bz2

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Saved to AWS S3 AS datanimbus.io.ui-appcenter_$TAG.tar.bz2"
echo "****************************************************"


docker save -o datanimbus.io.ui-swagger_$TAG.tar datanimbus.io.ui-swagger:$TAG
bzip2 datanimbus.io.ui-swagger_$TAG.tar
aws s3 cp datanimbus.io.ui-swagger_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/datanimbus.io.ui-swagger_$TAG.tar.bz2
rm datanimbus.io.ui-swagger_$TAG.tar.bz2

echo "****************************************************"
echo "datanimbus.io.proxy :: Image Saved to AWS S3 AS datanimbus.io.ui-swagger_$TAG.tar.bz2"
echo "****************************************************"