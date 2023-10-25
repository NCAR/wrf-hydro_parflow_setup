#!/bin/bash
set -e

# usage instructions
usage () {
  printf "\n"
  printf "Usage: $0 [OPTIONS ...] PATH_TO_USE_CASE_CONFIG\n"
  printf "\n"
  printf "PATH_TO_USE_CASE_CONFIG\n"
  printf "  path to use case configuration file\n"
  printf "\n"
  printf "OPTIONS\n"
  printf "  --env-auto\n"
  printf "      load preconfigured environment based on system\n"
  printf "\n"
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
RUN_DIR="${APP_DIR}/run"
# user configurable default settings
ENV_AUTO=false
USE_CASE=""
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
    -?*) printf "ERROR: Unknown option $1\n"; usage; exit 1 ;;
    ?*) POSITIONAL_ARGS+=("${1}") ;;
    *) break ;;
  esac
  shift
done
set -- "${POSITIONAL_ARGS[@]}"

if [[ $# -ne 1 ]]; then
  printf "ERROR: Usage error\n"
  usage
  exit 1
else
  USE_CASE=$1
fi

#------------------------------------------------------------------------------

# automatically determine system
if [ -z "${SYSTEM}" ] ; then
  SYSTEM=$(find_system)
fi

# auto environment
if [ "${ENV_AUTO}" = true ] ; then
  case ${SYSTEM} in
    cheyenne) AUTOFILE="${ENV_DIR}/cheyenne/intel-19.1.1";;
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
  rm -rf ${RUN_DIR}
fi

# setup
python3 tools/rundirsetup.py ${USE_CASE} ${SYSTEM}
