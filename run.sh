#!/usr/bin/env sh

set -xe

lachesis \
  --port ${LACHESIS_PORT} \
  --http \
  --http.addr "0.0.0.0" \
  --http.port ${LACHESIS_HTTP} \
  --http.api "${LACHESIS_API}" \
  --nousb \
  --verbosity ${LACHESIS_VERBOSITY}
