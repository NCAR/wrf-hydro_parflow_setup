#!/bin/bash

auto_environment () {
  case ${1} in
    cheyenne*) AUTOFILE="${2}/cheyenne/intel-19.1.1";;
    derecho*) AUTOFILE="${2}/derecho/gnu-12.2.0";;
    *) printf "ERROR: no environment file for ${1}\n"; exit 1 ;;
  esac
  if [ -f "${AUTOFILE}" ]; then
    source ${AUTOFILE}
  else
    printf "ERROR: ${AUTOFILE} does not exist\n"
    exit 1
  fi
}
