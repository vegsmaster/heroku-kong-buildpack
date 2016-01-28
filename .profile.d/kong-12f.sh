#!/usr/bin/env bash

# Fail immediately on non-zero exit code.
set -e
# Fail immediately on non-zero exit code within a pipeline.
set -o pipefail
# Fail on undeclared variables.
set -u
# Debug, echo every command
#set -x

echo "Starting Kong 12-factor config"

SRC_DIR=$(pwd)
BIN_DIR=$(cd "$(dirname "$0")"; pwd)

# Get the private IP of the dyno.
# Fallback to localhost for the common runtime.
export KONG_CLUSTER_PRIVATE_IP=$(ip -4 -o addr show dev eth1)
if [ "$KONG_CLUSTER_PRIVATE_IP" ]
then
  KONG_CLUSTER_PRIVATE_IP=$(echo $KONG_CLUSTER_PRIVATE_IP | awk '{print $4}' | cut -d/ -f1)
else
  KONG_CLUSTER_PRIVATE_IP='127.0.0.1'
fi
echo "Kong cluster private IP: $KONG_CLUSTER_PRIVATE_IP"

luajit $SRC_DIR/config/kong-12f.lua $SRC_DIR/config/kong.yml.etlua $SRC_DIR

# export the variables generated by `kong-12f.lua`
source $SRC_DIR/.profile.d/kong-env
echo "Configured Kong environment: KONG_CONF=$KONG_CONF"
