ARG TAG=latest
ARG LATEST_APPCENTER=dev
ARG LATEST_AUTHOR=dev
ARG LATEST_SWAGGER=dev
###############################################################################################
# Go building
###############################################################################################
FROM golang:1.13 AS build

WORKDIR /

COPY /scripts/setup.sh /

RUN chmod +x setup.sh \
  && sh setup.sh 

COPY /main.go /
COPY /fs-cache.go /
COPY /structs.go /
COPY /reverseproxy.go /

RUN env GOOS=linux GOARCH=386 go build -ldflags="-s -w" -o goroute .

###############################################################################################
# ODP Proxy build
###############################################################################################

FROM odp:ui-author.$LATEST_APPCENTER AS author
FROM odp:ui-appcenter.$LATEST_AUTHOR AS appcenter
FROM odp:ui-swaggerUI.$LATEST_SWAGGER AS swaggerUI

FROM alpine

WORKDIR /app

COPY --from=build /goroute /app/

COPY --from=author /app/dist/ /app/author/

COPY --from=appcenter /app/dist/ /app/appcenter/

COPY --from=swaggerUI /app/ /app/swaggerUI

COPY goroute.json /app

COPY goroute-env.json /app

COPY odp_server.crt /app/keys/odp_server.crt

COPY odp_server.key /app/keys/odp_server.key

EXPOSE 32001

ENTRYPOINT ["./goroute","-config","goroute.json","-env","goroute-env.json"]
