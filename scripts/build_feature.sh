#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(dirname ${SCRIPT_DIR})

# eats the first argument
source ${SCRIPT_DIR}/common.sh

echo "********************************************"

FEATURE=$1
if [ -z "${FEATURE}" ]; then
    FEATURE=all
fi

echo "Using PLATFORM=${PLATFORM}"
echo "Using FEATURE=${FEATURE}"

APP_MANIFEST=gen_${FEATURE}.appmanifest
SETTINGS=gen_${FEATURE}.settings
BUNDLE=bundle_${PLATFORM}_${FEATURE}

echo "********************************************"
echo "Cleanup"

SIGN=
BOB_PLATFORM=${PLATFORM}
case ${PLATFORM} in
    x86_64-macos)
        BOB_PLATFORM=x86_64-osx ;;
    arm64-macos)
        BOB_PLATFORM=arm64-osx ;;
    *-ios)
        if [ "" == "${IDENTITY}" ]; then
            echo "Missing IDENTITY variable for signing. (E.g. IDENTITY=\"Apple Developer\"")
            exit 1
        fi
        if [ "" == "${PROVISION}" ]; then
            echo "Missing PROVISION variable for signing. (E.g. PROVISION=./path/to/my.mobileprovision)"
            exit 1
        fi
        SIGN="--identity \"${IDENTITY}\" -mp ${PROVISION}"
        ;;
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

time java -jar ${BOB} build --settings ${SETTINGS} --platform=${PLATFORM} --architectures=${PLATFORM} --archive bundle --bo=${BUNDLE} --build-server=${SERVER} --variant=${VARIANT} ${SIGN}

echo "********************************************"
echo "BUNDLE"

du -hcs ${BUNDLE}

STRIP=$(which strip)


if [ "$(uname)" == "Darwin" ]; then
    case ${PLATFORM} in
        *-android)
            #STRIP=/Users/mathiaswesterdahl/Library/android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip
            ;;
    esac
fi

# if [ "" == "$SIGN" ]; then
#     # stripping invalidates the signing
#     if [ ! -z "${STRIP}" ]; then
#         echo "stripping..."
#         find ${BUNDLE} -perm +111 -type f | xargs ${STRIP}
#     fi
# fi

find ${BUNDLE} -type f -perm +111 -print | xargs ls -la
