#!/bin/sh
set -euxo pipefail

DEHYDRATED_VERSION=0.7.2

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
VERSION=$(git describe --tags "$(git rev-list --tags --max-count=1)")

BUILD_CONTEXT="${SCRIPT_DIR}/"

docker buildx build \
--build-arg DEHYDRATED_VERSION=${DEHYDRATED_VERSION} \
--no-cache \
--platform linux/amd64,linux/arm64 \
--progress=plain \
-f "${SCRIPT_DIR}/docker/Dockerfile" \
-t krautsalad/dehydrated:latest \
-t krautsalad/dehydrated:${VERSION} \
"${BUILD_CONTEXT}"

until docker buildx build \
    --build-arg DEHYDRATED_VERSION=${DEHYDRATED_VERSION} \
    --platform linux/amd64,linux/arm64 \
    --push \
    -f "${SCRIPT_DIR}/docker/Dockerfile" \
    -t krautsalad/dehydrated:latest \
    -t krautsalad/dehydrated:${VERSION} \
    "${BUILD_CONTEXT}"; do
    echo "Retrying push for ${image}-dev…" ; sleep 2
done
