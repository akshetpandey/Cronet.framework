#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function build_static_framework() {
    cp -r "Release-iphoneos/cronet/Static/Cronet.framework" Cronet.framework
    cp "Release-iphoneos/cronet/Cronet.framework/Info.plist" Cronet.framework
    cp -r "Release-iphoneos/cronet/Cronet.framework/Modules" Cronet.framework

    lipo -create -output Cronet.framework/Cronet Release-iphoneos/cronet/Static/Cronet.framework/Cronet Release-iphonesimulator/cronet/Static/Cronet.framework/Cronet

    rm -f "$__dir/Cronet-Static.framework.tar.bz2" || true
    tar cjf Cronet-Static.framework.tar.bz2 Cronet.framework
    mv Cronet-Static.framework.tar.bz2 "$__dir"

    rm -rf Cronet.framework
}

function build_dynamic_framework() {
    cp -r "Release-iphoneos/cronet/Cronet.framework" Cronet.framework

    lipo -create -output Cronet.framework/Cronet Release-iphoneos/cronet/Cronet.framework/Cronet Release-iphonesimulator/cronet/Cronet.framework/Cronet

    rm -rf "$__dir/Frameworks/Cronet.framework" || true
    cp -r Cronet.framework "$__dir/Frameworks"

    rm -f "$__dir/Cronet-Dynamic.framework.tar.bz2" || true
    tar cjf Cronet-Dynamic.framework.tar.bz2 Cronet.framework
    mv Cronet-Dynamic.framework.tar.bz2 "$__dir"

    rm -rf Cronet.framework
}

function build_dsym() {
    cp "Release-iphoneos/cronet/Cronet.dSYM.tar.bz2" .
    tar xf Cronet.dSYM.tar.bz2
    mv Cronet.dSYM Cronet-iphoneos.dSYM

    cp "Release-iphonesimulator/cronet/Cronet.dSYM.tar.bz2" .
    tar xf Cronet.dSYM.tar.bz2
    mv Cronet.dSYM Cronet-iphonesimulator.dSYM

    cp -r Cronet-iphoneos.dSYM Cronet.framework.dSYM

    lipo -create -output Cronet.framework.dSYM/Contents/Resources/DWARF/Cronet Cronet-iphoneos.dSYM/Contents/Resources/DWARF/Cronet Cronet-iphonesimulator.dSYM/Contents/Resources/DWARF/Cronet

    rm -f "$__dir/Cronet.framework.dSYM.tar.bz2" || true
    tar cjf Cronet.framework.dSYM.tar.bz2 Cronet.framework.dSYM
    cp Cronet.framework.dSYM.tar.bz2 "$__dir"
}

function build_framework() {
    local CRONET_VERSION=$1
    if [ -z "$CRONET_VERSION" ]; then
        echo "Empty framework version. Check passed in argument"
        return 1
    fi

    if ! gsutil -q stat "gs://chromium-cronet/ios/${CRONET_VERSION}/Release-iphoneos/VERSION" ; then
        echo "Invalid framework version $CRONET_VERSION. Build Release-iphoneos build does not exist on gs://chromium-cronet"
        return 2
    fi

    if ! gsutil -q stat "gs://chromium-cronet/ios/${CRONET_VERSION}/Release-iphonesimulator/VERSION" ; then
        echo "Invalid framework version $CRONET_VERSION. Release-iphonesimulator build does not exist on gs://chromium-cronet"
        return 3
    fi

    local OLD_PWD=$PWD
    rm -rf "$__dir/tmp" || true
    mkdir -p "$__dir/tmp"
    cd "$__dir/tmp"

    gsutil -q -m cp -r  "gs://chromium-cronet/ios/${CRONET_VERSION}/Release-*" .

    build_static_framework
    build_dynamic_framework
    build_dsym

    cd "$OLD_PWD"
}

if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f build_framework
else
  # Exit on error. Append "|| true" if you expect an error.
  set -o errexit
  # Exit on error inside any functions or subshells.
  set -o errtrace
  # Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
  set -o nounset
  # Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
  set -o pipefail
  # Turn on traces, useful while debugging but commented out by default
  # set -o xtrace

  build_framework "${@}"
  exit $?
fi
