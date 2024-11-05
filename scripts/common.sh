#!/sr/bin/env bash

if [ -z "${DYNAMO_HOME}" ]; then
    echo "No DYNAMO_HOME found. Settiong it to '.'"
    DYNAMO_HOME=.
fi

if [ -z "${BOB}" ]; then
    BOB=${DYNAMO_HOME}/share/java/bob.jar
fi

if [ -z "${SERVER}" ]; then
    SERVER=http://build.defold.com
fi

if [ -z "${LOOPCOUNT}" ]; then
    LOOPCOUNT=10
fi

PLATFORM=$1
shift
if [ -z "${PLATFORM}" ]; then
    echo "No platform argument specified"
    exit 1
fi

if [ -z "${VARIANT}" ]; then
    VARIANT=release
fi

echo "Using BOB=${BOB}"
echo "Using SERVER=${SERVER}"
echo "Using PLATFORM=${PLATFORM}"
echo "Using VARIANT=${VARIANT}"
echo ""
echo "Test params:"
echo "Using LOOPCOUNT=${LOOPCOUNT}"

if [ ! -e "${BOB}" ]; then
    echo "BOB=${BOB} does not exist"
    exit 1
fi


function gen_app_manifest {
    local feature=$1
    local output=$2
    case ${feature} in
        "all")
            excludes="[]"
            ;;
        "vanilla")
            excludes="['ExtensionCSharp', 'ExtensionCPP', 'ExtensionZig']"
            ;;
        "zig")
            excludes="['ExtensionCSharp', 'ExtensionCPP']"
            ;;
        "cpp")
            excludes="['ExtensionCSharp', 'ExtensionZig']"
            ;;
        "csharp")
            excludes="['ExtensionCPP', 'ExtensionZig']"
            ;;
    esac
    echo "#generated, do not edit!" > ${output}
    echo "platforms:" >> ${output}
    echo "    common:" >> ${output}
    echo "        context:" >> ${output}
    echo "            excludeSymbols: ${excludes}" >> ${output}
    echo "" >> ${output}
    echo "Wrote ${output}"
}

function gen_settings {
    local feature=$1
    local output=$2

    echo "[native_extension]" > ${SETTINGS}
    echo "app_manifest=${APP_MANIFEST}" >> ${SETTINGS}

    echo "[test]" >> ${SETTINGS}
    echo "perf_test=1" >> ${SETTINGS}
    echo "loopcount=${LOOPCOUNT}" >> ${SETTINGS}
    echo "Wrote ${SETTINGS}"
}
