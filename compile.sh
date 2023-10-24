#!/bin/bash
set -e

# usage instructions
usage () {
  printf "Usage: $0 [OPTIONS]...\n"
  printf "\n"
  printf "OPTIONS\n"
  printf "  --env-auto\n"
  printf "      load preconfigured environment based on system\n"
  printf "  --build-type=BUILD_TYPE\n"
  printf "      build type; valid options are 'debug', 'release',\n"
  printf "      'relWithDebInfo'\n"
  printf "  --build-jobs=BUILD_JOBS\n"
  printf "      number of jobs used for building esmx and components\n"
  printf "  --verbose, -v\n"
  printf "      build with verbose output\n"
  printf "  --clean\n"
  printf "      delete build and install directories\n"
  printf "\n"
}

# print settings
settings () {
  printf "#######################################################\n"
  printf "Settings:\n\n"
  printf "\tSYSTEM=${SYSTEM}\n"
  printf "\tENV_AUTO=${ENV_AUTO}\n"
  printf "\tBUILD_TYPE=${BUILD_TYPE}\n"
  printf "\tBUILD_JOBS=${BUILD_JOBS}\n"
  printf "\tVERBOSE=${VERBOSE}\n"
  printf "\tCLEAN=${CLEAN}\n"
  printf "#######################################################\n"
}

# find system name
find_system () {
    local sysname=`hostname`
    sysname="${sysname//[[:digit:]]/}"
    echo "$sysname"
}

#------------------------------------------------------------------------------

# default settings
APP_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SYSTEM=""
ENV_DIR="${APP_DIR}/env"
BUILD_DIR="${APP_DIR}/build"
INSTALL_PREFIX="${APP_DIR}/install"
# user configurable default settings
ENV_AUTO=false
BUILD_TYPE="release"
BUILD_JOBS="2"
VERBOSE=false
CLEAN=false

#------------------------------------------------------------------------------

# process arguments
POSITIONAL_ARGS=()
while :; do
  case $1 in
    --help|-h) usage; exit 0 ;;
    --env-auto) ENV_AUTO=true ;;
    --env-auto=?*) printf "ERROR: $1 argument ignored.\n"; usage; exit 1 ;;
    --env-auto=) printf "ERROR: $1 argument ignored.\n"; usage; exit 1 ;;
    --build-type=?*) BUILD_TYPE=${1#*=} ;;
    --build-type) printf "ERROR: $1 requires an argument.\n"; usage; exit 1 ;;
    --build-type=) printf "ERROR: $1 requires an argument.\n"; usage; exit 1 ;;
    --build-jobs=?*) BUILD_JOBS=${1#*=} ;;
    --build-jobs) printf "ERROR: $1 requires an argument.\n"; usage; exit 1 ;;
    --build-jobs=) printf "ERROR: $1 requires an argument.\n"; usage; exit 1 ;;
    --verbose|-v) VERBOSE=true ;;
    --verbose=?*) printf "ERROR: $1 argument ignored.\n"; usage; exit 1 ;;
    --verbose=) printf "ERROR: $1 argument ignored.\n"; usage; exit 1 ;;
    --clean) CLEAN=true ;;
    --clean=?*) printf "ERROR: $1 argument ignored.\n"; usage; exit 1 ;;
    --clean=) printf "ERROR: $1 argument ignored.\n"; usage; exit 1 ;;
    -?*) printf "ERROR: Unknown option $1\n"; usage; exit 1 ;;
    ?*) POSITIONAL_ARGS+=("${1}") ;;
    *) break ;;
  esac
  shift
done
set -- "${POSITIONAL_ARGS[@]}"

if [[ $# -ge 1 ]]; then
  printf "ERROR: Unknown argument $1\n"
  usage
  exit 1
fi

#------------------------------------------------------------------------------

# automatically determine system
if [ -z "${SYSTEM}" ] ; then
  SYSTEM=$(find_system)
fi

# print settings
settings

# auto environment
if [ "${ENV_AUTO}" = true ] ; then
  case ${SYSTEM} in
    cheyenne) AUTOFILE="${ENV_DIR}/cheyenne/gnu-10.1.0";;
    derecho) AUTOFILE="${ENV_DIR}/derecho/gnu-12.2.0";;
    *) printf "ERROR: unspecified --env-auto for ${SYSTEM}\n"; exit 1 ;;
  esac
  if [ -f "${AUTOFILE}" ]; then
    source ${AUTOFILE}
  else
    printf "ERROR: ${AUTOFILE} does not exist\n"
    exit 1
  fi
fi

set -u

# clean
if [ "${CLEAN}" = true ]; then
  rm -rf ${BUILD_DIR} ${INSTALL_PREFIX}
fi

# build
BUILD_SETTINGS=("")
BUILD_SETTINGS+=("--build-dir=${BUILD_DIR}")
BUILD_SETTINGS+=("--prefix=${INSTALL_PREFIX}")
if [ "${VERBOSE}" = true ]; then
  BUILD_SETTINGS+=("--verbose")
fi
if [ ! -z "${BUILD_TYPE}" ]; then
  BUILD_SETTINGS+=("--build-type=${BUILD_TYPE}")
fi
if [ ! -z "${BUILD_JOBS}" ]; then
  BUILD_SETTINGS+=("--build-jobs=${BUILD_JOBS}")
fi

ESMX_Builder ${BUILD_SETTINGS[@]} appcfg/wrfhydro_parflow.yaml
