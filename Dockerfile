ARG TAG=latest
ARG LATEST_APPCENTER=dev
ARG LATEST_AUTHOR=dev
ARG LATEST_SWAGGER=dev
###############################################################################################
# Go building
###############################################################################################
FROM golang:1.19.2-alpine3.16 AS build

WORKDIR /app

COPY go.mod /app

COPY go.sum /app

COPY main.go /app

COPY fs-cache.go /app

COPY structs.go /app

COPY reverseproxy.go /app

RUN ls -l && go get

RUN env GOOS=linux GOARCH=386 go build -ldflags="-s -w" -o goroute .

###############################################################################################
# data.stack Proxy build
###############################################################################################

FROM datanimbus.io.ui-author:$LATEST_APPCENTER AS author
FROM datanimbus.io.ui-appcenter:$LATEST_AUTHOR AS appcenter
FROM datanimbus.io.ui-swagger:$LATEST_SWAGGER AS swaggerUI

FROM alpine:latest

RUN apk update
RUN apk upgrade

WORKDIR /app

COPY --from=build /app/goroute /app/

COPY --from=author /app/dist/ /app/author/

COPY --from=appcenter /app/dist/ /app/appcenter/

COPY --from=swaggerUI /app/ /app/swaggerUI

COPY goroute.json /app

COPY goroute-env.json /app

COPY odp_server.crt /app/keys/odp_server.crt

COPY odp_server.key /app/keys/odp_server.key

EXPOSE 32001

ENTRYPOINT ["./goroute","-config","goroute.json","-env","goroute-env.json"]
