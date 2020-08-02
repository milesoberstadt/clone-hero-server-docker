# Build OpenRCT2
FROM ubuntu:20.04 AS build-env
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates wget unzip curl jq

WORKDIR /clonehero
RUN chversion=$(curl -s https://dltest.b-cdn.net/linux-index.json | jq -r .[0].version | sed "s/v0/v/") \
 && wget -O chserver.zip https://dl.clonehero.net/chserver/ChStandaloneServer-$chversion.zip \
 && unzip chserver.zip \
 && rm ./chserver.zip \
 && mv ./ChStandaloneServer-* ./chserver \
 && mv ./chserver/linux-x64 ./chserver/linux-x86_64 \
 && mv ./chserver/linux-$(uname -i)/* . \
 && rm -rf ./chserver \
 && chmod +x ./Server

FROM ubuntu:20.04

RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates libicu66 \
 && useradd -m clonehero

WORKDIR /home/clonehero/server
COPY --from=build-env /clonehero .
RUN mkdir config \
 && chown -R 1000 .
USER clonehero

WORKDIR /home/clonehero/server/config
RUN ../Server & serverpid=$! \
 && sleep 3 \
 && kill "$serverpid" \
 && rm settings.ini

EXPOSE 14242
ENTRYPOINT ["../Server"]
