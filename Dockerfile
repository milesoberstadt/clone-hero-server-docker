FROM debian:buster-slim AS build-env
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /clonehero
RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates unzip curl jq libicu63 \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir config

#ARG BRANCH=test
ARG VERSION

COPY ./startup.sh .
COPY ./server-settings.ini ./config/

# TODO: apply BRANCH to this
# RUN if [ -z ${VERSION+x} ]; then VERSION=$(curl -s "https://api.github.com/repos/clonehero-game/releases/releases" | jq -r 'map(select(.prerelease == false)) | map(select(.draft == false)) | .[0].name' ); fi \
#  && curl -sL -o chserver.zip https://github.com/clonehero-game/releases/releases/download/$VERSION/CloneHero-standalone_server.zip
RUN echo "VERSION: $VERSION"
RUN if [ -z ${VERSION+x} ]; then VERSION=$(curl -sL "https://api.github.com/repos/clonehero-game/releases/releases" | jq -r 'map(select(.prerelease == false)) | map(select(.draft == false)) | .[0].name' ); fi \
 && DOWNLOAD_URL=$(curl -sL "https://api.github.com/repos/clonehero-game/releases/releases" | jq -r "map(select(.name == \"$VERSION\")) | .[0].assets[] | select(.name == \"CloneHero-standalone_server.zip\") | .browser_download_url") \
 && curl -sL -o chserver.zip ${DOWNLOAD_URL}
RUN wc -c chserver.zip
RUN unzip chserver.zip \
 && rm ./chserver.zip \
 && mv ./ChStandaloneServer-* ./chserver \
 && mv ./chserver/linux-x64 ./chserver/linux-x86_64 \
 && mv ./chserver/linux-arm64 ./chserver/linux-aarch64 \
 && mv ./chserver/linux-arm ./chserver/linux-armv7l \
 && mv ./chserver/linux-$(arch)/* . \
 && rm -rf ./chserver \
 && chmod +x ./Server \
 && chown -R 1000 ./config

FROM debian:buster-slim

RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates libicu63 libgssapi-krb5-2 \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/src/clonehero/Server /usr/bin/cloneheroserver \
 && useradd -m clonehero

WORKDIR /usr/src/clonehero
COPY --from=build-env /clonehero .
USER clonehero

WORKDIR /usr/src/clonehero/config

EXPOSE 14242/udp
ENTRYPOINT ["../startup.sh"]
