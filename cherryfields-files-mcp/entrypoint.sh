#!/bin/sh
set -eu
APP_DIR="${APP_DIR:-/app}"
DATA_DIR="${DATA_DIR:-/data}"
WANT="supergateway@4.2.2 @modelcontextprotocol/server-filesystem@2.3.0"
cd "$APP_DIR"
if [ "$(cat .installed 2>/dev/null || true)" != "$WANT" ]; then
  npm install --prefix "$APP_DIR" --no-audit --no-fund --omit=dev $WANT
  echo "$WANT" > .installed
fi
if [ ! -s api-key ]; then
  head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > api-key
  chmod 600 api-key
fi
export SUPERGATEWAY_API_KEY_FILE="$APP_DIR/api-key"
exec node "$APP_DIR/node_modules/supergateway/dist/index.js" \
  --stdio "node $APP_DIR/node_modules/@modelcontextprotocol/server-filesystem/dist/index.js $DATA_DIR" \
  --outputTransport streamableHttp --port 8000 --stateful --healthEndpoint /healthz
