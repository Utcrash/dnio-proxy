#!/bin/bash

cd $WORKSPACE
echo "****************************************************"
echo "data.stack:proxy :: Fetching dependencies"
echo "****************************************************"
go get -u github.com/bradfitz/gomemcache/memcache
go get -u github.com/NYTimes/gziphandler
go get -u github.com/gorilla/mux