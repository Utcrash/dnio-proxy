#!/bin/bash

set -e

TAG=`cat CURRENT_PROXY`

echo "****************************************************"
echo "data.stack:proxy :: Saving Image to AWS S3 :: $S3_BUCKET/stable-builds"
echo "****************************************************"

TODAY_FOLDER=`date ++%Y_%m_%d`

docker save -o data.stack.proxy_$TAG.tar data.stack.proxy:$TAG
bzip2 data.stack.proxy_$TAG.tar
aws s3 cp data.stack.proxy_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/data.stack.proxy_$TAG.tar.bz2
rm data.stack.proxy_$TAG.tar.bz2

echo "****************************************************"
echo "data.stack:proxy :: Image Saved to AWS S3 AS data.stack.proxy_$TAG.tar.bz2"
echo "****************************************************"

docker save -o data.stack.ui-author_$TAG.tar data.stack.ui-author:$TAG
bzip2 data.stack.ui-author_$TAG.tar
aws s3 cp data.stack.ui-author_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/data.stack.ui-author_$TAG.tar.bz2
rm data.stack.ui-author_$TAG.tar.bz2

echo "****************************************************"
echo "data.stack:proxy :: Image Saved to AWS S3 AS data.stack.ui-author_$TAG.tar.bz2"
echo "****************************************************"

docker save -o data.stack.ui-appcenter_$TAG.tar data.stack.ui-appcenter:$TAG
bzip2 data.stack.ui-appcenter_$TAG.tar
aws s3 cp data.stack.ui-appcenter_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/data.stack.ui-appcenter_$TAG.tar.bz2
rm data.stack.ui-appcenter_$TAG.tar.bz2

echo "****************************************************"
echo "data.stack:proxy :: Image Saved to AWS S3 AS data.stack.ui-appcenter_$TAG.tar.bz2"
echo "****************************************************"


docker save -o data.stack.ui-swagger_$TAG.tar data.stack.ui-swagger:$TAG
bzip2 data.stack.ui-swagger_$TAG.tar
aws s3 cp data.stack.ui-swagger_$TAG.tar.bz2 s3://$S3_BUCKET/stable-builds/$TODAY_FOLDER/data.stack.ui-swagger_$TAG.tar.bz2
rm data.stack.ui-swagger_$TAG.tar.bz2

echo "****************************************************"
echo "data.stack:proxy :: Image Saved to AWS S3 AS data.stack.ui-swagger_$TAG.tar.bz2"
echo "****************************************************"