FROM alpine:latest as build-stage

ARG LACHESIS_VERSION=release/1.0.0-rc.0

ENV GOROOT=/usr/lib/go 
ENV GOPATH=/go 
ENV PATH=$GOROOT/bin:$GOPATH/bin:/build:$PATH

RUN set -xe; \
  apk add --no-cache --virtual .build-deps \
  # get the build dependencies for go
  git make musl-dev go linux-headers; \
  # install fantom lachesis from github
  mkdir -p ${GOPATH}; cd ${GOPATH}; \
  git clone --single-branch --branch ${LACHESIS_VERSION} https://github.com/Fantom-foundation/go-lachesis.git; \
  cd go-lachesis; \
  make build -j$(nproc); \
  mv build/lachesis /usr/local/bin; \
  rm -rf /go; \
  # remove our build dependencies
  apk del .build-deps; 

FROM alpine:latest as lachesis

# copy the binary 
COPY --from=build-stage /usr/local/bin/lachesis /usr/local/bin/lachesis

COPY run.sh /usr/local/bin

WORKDIR /root

ENV LACHESIS_PORT=5050
ENV LACHESIS_HTTP=18545
ENV LACHESIS_API=eth,ftm,debug,admin,web3,personal,net,txpool

EXPOSE ${LACHESIS_PORT}
EXPOSE ${LACHESIS_HTTP}

VOLUME [ "/root/.lachesis" ]

CMD ["run.sh"]