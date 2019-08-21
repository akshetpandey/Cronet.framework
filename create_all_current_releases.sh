#!/usr/bin/env bash

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

# shellcheck disable=SC1091
source create_release.sh

rm -f current_chrome_versions.json || true
wget -q https://omahaproxy.appspot.com/all.json -O current_chrome_versions.json

DEV_VERSION=$(jq -r ".[] | select(.os | contains(\"ios\")) | .versions[] | select(.channel | contains(\"dev\")) | .version" current_chrome_versions.json)
BETA_VERSION=$(jq -r ".[] | select(.os | contains(\"ios\")) | .versions[] | select(.channel | contains(\"beta\")) | .version" current_chrome_versions.json)
STABLE_VERSION=$(jq -r ".[] | select(.os | contains(\"ios\")) | .versions[] | select(.channel | contains(\"stable\")) | .version" current_chrome_versions.json)

rm -f current_chrome_versions.json || true

DEV_BRANCH="$DEV_VERSION-dev"
BETA_BRANCH="$BETA_VERSION-beta"
STABLE_BRANCH="$STABLE_VERSION"

if ! git ls-remote --exit-code origin "$STABLE_BRANCH" ; then
    echo "BUILDING $STABLE_BRANCH"
    create_release "$STABLE_VERSION" "$STABLE_BRANCH"
fi

if ! git ls-remote --exit-code origin "$BETA_BRANCH" ; then
    echo "BUILDING $BETA_BRANCH"
    create_release "$BETA_VERSION" "$BETA_BRANCH"
fi

if ! git ls-remote --exit-code origin "$DEV_BRANCH" ; then
    echo "BUILDING $DEV_BRANCH"
    create_release "$DEV_VERSION" "$DEV_BRANCH"
fi
