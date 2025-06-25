#!/bin/sh
set -ex

DEHYDRATED_VERSION=0.7.2

docker build \
    --build-arg DEHYDRATED_VERSION=${DEHYDRATED_VERSION} \
    --no-cache --progress=plain -t krautsalad/dehydrated:latest -f docker/Dockerfile .
docker push krautsalad/dehydrated:latest

VERSION=$(git describe --tags "$(git rev-list --tags --max-count=1)")

docker tag krautsalad/dehydrated:latest krautsalad/dehydrated:${VERSION}
docker push krautsalad/dehydrated:${VERSION}
