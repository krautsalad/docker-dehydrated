#!/bin/sh
set -ex

docker build --no-cache --progress=plain -t krautsalad/dehydrated:latest -f docker/Dockerfile .
docker push krautsalad/dehydrated:latest

VERSION=$(git describe --tags "$(git rev-list --tags --max-count=1)")

docker tag krautsalad/dehydrated:latest krautsalad/dehydrated:${VERSION}
docker push krautsalad/dehydrated:${VERSION}
