#!/bin/sh
set -ex
docker build --no-cache --progress=plain -t krautsalad/dehydrated:latest -f Dockerfile .
