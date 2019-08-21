#!/usr/bin/env bash

# shellcheck disable=SC1091
source build_framework.sh

function create_release() {
    local CRONET_VERSION=$1
    local BRANCH_NAME=$2

    if [ -z "$CRONET_VERSION" ]; then
        echo "Empty cronet version. Check passed in argument"
        return 1
    fi

    if [ -z "$BRANCH_NAME" ]; then
        echo "Empty branch name. Check passed in argument"
        return 1
    fi

    local CURRENT_BRANCH_NAME
    CURRENT_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

    git checkout -b "$BRANCH_NAME"

    build_framework "$CRONET_VERSION"

    sed -i "" "s/MASTER_BRANCH/$BRANCH_NAME/" Cronet.podspec

    git add .
    git commit -m  "Build $BRANCH_NAME"

    git tag "v$BRANCH_NAME"
    git push origin "$BRANCH_NAME"
    git push origin --tags

    if [[ $BRANCH_NAME == *"dev" || $BRANCH_NAME == *"beta" ]]; then
        hub release create --draft=false -p -a Cronet-Static.framework.tar.bz2 -a Cronet-Dynamic.framework.tar.bz2 -a Cronet.framework.dSYM.tar.bz2 -m "$BRANCH_NAME" "v$BRANCH_NAME"
    else
        hub release create --draft=false -a Cronet-Static.framework.tar.bz2 -a Cronet-Dynamic.framework.tar.bz2 -a Cronet.framework.dSYM.tar.bz2 -m "$BRANCH_NAME" "v$BRANCH_NAME"
    fi

    git checkout "$CURRENT_BRANCH_NAME"
}

if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f create_release
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

  create_release "${@}"
  exit $?
fi
