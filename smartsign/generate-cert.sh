#!/bin/bash
set -e

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"

PROJPATH=${PWD}
ARTIFPATH=$PROJPATH/artifacts
CAPATH=$ARTIFPATH/crypto-config

rm -rf $CAPATH
cryptogen generate --config=$ARTIFPATH/crypto-config.yaml --output=$CAPATH

sh generate-cx.sh