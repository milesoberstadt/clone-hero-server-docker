FROM debian:buster-slim AS build-env
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates wget unzip curl jq libicu63 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /clonehero
ARG BRANCH=test
RUN chversion=$(curl -s "https://dl$BRANCH.b-cdn.net/linux-index.json" | jq -r .[0].version | sed "s/v0/v/") \
 && wget -O chserver.zip https://dl.clonehero.net/chserver/ChStandaloneServer-$chversion.zip \
 && unzip chserver.zip \
 && rm ./chserver.zip \
 && mv ./ChStandaloneServer-* ./chserver \
 && mv ./chserver/linux-x64 ./chserver/linux-x86_64 \
 && mv ./chserver/linux-$(arch)/* . \
 && rm -rf ./chserver \
 && chmod +x ./Server \
 && mkdir config

WORKDIR /clonehero/config

RUN ../Server & serverpid=$! \
 && sleep 3 \
 && kill "$serverpid" \
 && sed -i "s/127.0.0.1/0.0.0.0/" settings.ini \
 && chown -R 1000 .

FROM debian:buster-slim

RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates libicu63 \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m clonehero

WORKDIR /usr/src
COPY --from=build-env /clonehero .
USER clonehero

WORKDIR /usr/src/config

EXPOSE 14242
ENTRYPOINT ["../Server"]
