#!/bin/sh

set -e

rm -f tmp/pids/server.pid

exec "$@"