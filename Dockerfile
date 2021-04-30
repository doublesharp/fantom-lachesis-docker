FROM alpine:latest

ARG LACHESIS_VERSION=release/1.0.0-rc.0

ENV GOROOT=/usr/lib/go 
ENV GOPATH=/go 
ENV PATH=$GOROOT/bin:$GOPATH/bin:$GOPATH/go-lachesis/build:$PATH

RUN set -xe; \
  apk add --no-cache --virtual .build-deps \
  # get the build dependencies for go
  git make musl-dev go linux-headers; \
  # install fantom lachesis from github
  mkdir -p ${GOPATH}; cd ${GOPATH}; \
  git clone --single-branch --branch ${LACHESIS_VERSION} https://github.com/Fantom-foundation/go-lachesis.git; \
  cd go-lachesis; \
  make build -j$(nproc); \
  # remove our build dependencies
  apk del .build-deps; 

WORKDIR /root

ENV LACHESIS_PORT=4000 
ENV LACHESIS_HTTP=5050

EXPOSE ${LACHESIS_PORT}
EXPOSE ${LACHESIS_HTTP}

VOLUME [ "/root/.lachesis" ]

CMD ["sh", "-c", "lachesis --nousb --port ${LACHESIS_PORT}  --http --http.port ${LACHESIS_HTTP} --verbosity 3"]