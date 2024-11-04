#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(dirname ${SCRIPT_DIR})

source ${SCRIPT_DIR}/common.sh

echo "********************************************"

FEATURE=$1
if [ -z "${FEATURE}" ]; then
    FEATURE=all
fi

APP_MANIFEST=gen_${FEATURE}.appmanifest
SETTINGS=gen_${FEATURE}.settings
BUNDLE=bundle_${PLATFORM}_${FEATURE}

echo "Using FEATURE=${FEATURE}"

echo "********************************************"
echo "Cleanup"

BOB_PLATFORM=${PLATFORM}
case ${PLATFORM} in
    x86_64-macos)
        BOB_PLATFORM=x86_64-osx ;;
    arm64-macos)
        BOB_PLATFORM=arm64-osx ;;
esac

rm -rf ./build/default
rm -rf ./build/${PLATFORM}
rm -rf .internal/cache/${BOB_PLATFORM}
rm -rf ./${BUNDLE}

echo "********************************************"

gen_app_manifest ${FEATURE} ${APP_MANIFEST}
gen_settings ${FEATURE} ${SETTINGS}

echo "********************************************"
echo "Building project with FEATURE=${FEATURE}"

time java -jar ${BOB} build --settings ${SETTINGS} --platform=${PLATFORM} --architectures=${PLATFORM} --archive bundle --bo=${BUNDLE} --build-server=${SERVER} --variant=${VARIANT} --with-symbols

echo "********************************************"
du -hcs ${BUNDLE}

STRIP=
if [ "$(uname)" == "Darwin" ]; then
    STRIP=$(which strip)
fi

if [ ! -z "${STRIP}" ]; then
    find ${BUNDLE} -perm +111 -type f | xargs ${STRIP}
fi

find ${BUNDLE} -type f -perm +111 -print | xargs ls -la
