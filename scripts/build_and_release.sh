#!/bin/bash

set -euox pipefail

export CGO_ENABLED=0
gox -parallel 5 -osarch="darwin/amd64 linux/386 linux/amd64 linux/arm linux/arm64" -ldflags="-s -w " -output="bin/{{.Dir}}_{{.OS}}_{{.Arch}}" ./cmd/cdk/
gox -parallel 5 -osarch="linux/386 linux/amd64 linux/arm64" -ldflags="-s -w " -tags="thin" -output="bin/{{.Dir}}_{{.OS}}_{{.Arch}}_thin" ./cmd/cdk/

# cdk_linux_386 cdk_linux_amd64 cdk_linux_arm cdk_linux_arm64
cp bin/cdk_linux_amd64 bin/cdk_linux_amd64_upx
upx bin/cdk_linux_amd64_upx

cp bin/cdk_linux_386 bin/cdk_linux_386_upx
upx bin/cdk_linux_386_upx

cp bin/cdk_linux_amd64_thin bin/cdk_linux_amd64_thin_upx
upx bin/cdk_linux_amd64_thin_upx

cp bin/cdk_linux_386_thin bin/cdk_linux_386_thin_upx
upx bin/cdk_linux_386_thin_upx

# get bin sha256
sha256_text_body=`cd bin/ && shasum -a 256 * | tr -s '  ' '|'`
release_body=$(cat <<- EOF
|sha256|exectue file|
|---|---|
|$sha256_text_body|
EOF
)

date_string=`date -u +"%Y-%m-%d"`
title="New release and version in $date_string"

ghr -n "$title" -b "$release_body" "refs/tags/v0.1.16" "bin/"

