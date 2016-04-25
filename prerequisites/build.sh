#!/usr/bin/env bash
# BASH3 Boilerplate
#
# build.sh
#
#  - Build OpenCoarrays prerequisite packages and their prerequisites
#
# Usage: LOG_LEVEL=7 B3B_USE_CASE=/opt/bash3boilerplate/src/use-case ./my-script.sh -f script_input.txt 
#
# More info:
#
#  - https://github.com/kvz/bash3boilerplate
#  - http://kvz.io/blog/2013/02/26/introducing-bash3boilerplate/
#
# Version: 2.0.0
#
# Authors:
#
#  - Kevin van Zonneveld (http://kvz.io)
#  - Izaak Beekman (https://izaakbeekman.com/)
#  - Alexander Rathai (Alexander.Rathai@gmail.com)
#  - Dr. Damian Rouson (http://www.sourceryinstitute.org/) (documentation)
#
# Licensed under MIT
# Copyright (c) 2013 Kevin van Zonneveld (http://kvz.io)

# The invocation of bootstrap.sh below performs the following tasks:
# (1) Import several bash3boilerplate helper functions & default settings.
# (2) Set several variables describing the current file and its usage page.
# (3) Parse the usage information (default usage file name: current file's name with -usage appended).
# (4) Parse the command line using the usage information.  


export OPENCOARRAYS_SRC_DIR="${OPENCOARRAYS_SRC_DIR:-${PWD}/..}"
export __usage=${OPENCOARRAYS_SRC_DIR}/prerequisites/build.sh-usage
if [[ ! -f "${OPENCOARRAYS_SRC_DIR}/src/libcaf.h" ]]; then
  echo "Please run this script inside the top-level OpenCoarrays source directory "
  echo "or set OPENCOARRAYS_SRC_DIR to the OpenCoarrays source directory path."
  exit 1
fi
export B3B_USE_CASE="${B3B_USE_CASE:-${OPENCOARRAYS_SRC_DIR}/prerequisites/use-case}"
if [[ ! -f "${B3B_USE_CASE:-}/bootstrap.sh" ]]; then
  echo "Please set B3B_USE_CASE to the bash3boilerplate use-case directory path." 
  exit 2
fi
source "${B3B_USE_CASE}/bootstrap.sh" "$@"



# Set up a function to call when receiving an EXIT signal to do some cleanup. Remove if
# not needed. Other signals can be trapped too, like SIGINT and SIGTERM.
function cleanup_before_exit () {
  info "Cleaning up. Done"
}
trap cleanup_before_exit EXIT # The signal is specified here. Could be SIGINT, SIGTERM etc.

### Validation (decide what's required for running your script and error out)
#####################################################################

export __flag_present=1

if [[ "${arg_l}" != "${__flag_present}" && "${arg_L}" != "${__flag_present}" &&
      "${arg_v}" != "${__flag_present}" && "${arg_h}" != "${__flag_present}" &&
      -z "${arg_D:-${arg_p:-${arg_P:-${arg_U:-${arg_V}}}}}" ]]; then
  help "${__base}: Insufficient arguments. Please pass either -D, -h, -l, -L, -p, -P, -U, -v, -V, or a longer equivalent."
fi

# Suppress info and debug messages if -l, -P, -U, -V, -D, or their longer equivalent is present: 
[[ "${arg_l}" == "${__flag_present}" || ! -z "${arg_P:-${arg_U:-${arg_V:-${arg_D}}}}" ]] && suppress_info_debug_messages

[ -z "${LOG_LEVEL:-}" ] && emergency "Cannot continue without LOG_LEVEL. "

### Enforce mutual exclusivity of arguments that print single-line output
[ ! -z "${arg_P:-}" ] && [ ! -z "${arg_V:-}" ] && emergency "Only specify one of -P, -U, -V, or their long-form equivalents."
[ ! -z "${arg_P:-}" ] && [ ! -z "${arg_U:-}" ] && emergency "Only specify one of -P, -U, -V, or their long-form equivalents."
[ ! -z "${arg_U:-}" ] && [ ! -z "${arg_V:-}" ] && emergency "Only specify one of -P, -U, -V, or their long-form equivalents."

### Print bootstrapped magic variables to STDERR when LOG_LEVEL 
### is at the default value (6) or above.
#####################################################################

info "__file: ${__file}"
info "__dir: ${__dir}"
info "__base: ${__base}"
info "__os: ${__os}"
info "__usage: ${__usage}"
info "LOG_LEVEL: ${LOG_LEVEL}"

info "-b (--branch):           ${arg_b} "
info "-c (--with-c):           ${arg_c} " 
info "-C (--with-cpp):         ${arg_C} " 
info "-d (--debug):            ${arg_d} "
info "-D (--print-downloader): ${arg_D} "
info "-e (--verbose):          ${arg_e} "
info "-f (--with-fortran):     ${arg_f} "
info "-h (--help):             ${arg_h} "
info "-i (--install-dir):      ${arg_i} "
info "-j (--num-threads):      ${arg_j} "
info "-I (--install-version):  ${arg_I} "
info "-l (--list-packages):    ${arg_l} "
info "-L (--list-branches):    ${arg_L} "
info "-m (--with-cmake):       ${arg_m} "
info "-M (--with-mpi):         ${arg_M} "
info "-n (--no-color):         ${arg_n} "
info "-p (--package):          ${arg_p}"
info "-P (--print-path):       ${arg_P} " 
info "-t (--with-tau):         ${arg_t} "
info "-U (--print-url):        ${arg_U} "
info "-v (--version):          ${arg_v} "
info "-V (--print-version):    ${arg_V} "

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/set_or_print_default_version.sh"
set_or_print_default_version
export version_to_build="${arg_I:-${default_version}}"

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/set_or_print_downloader.sh"
set_or_print_downloader

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/set_or_print_url.sh"
set_or_print_url

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/set_or_print_installation_path.sh"
set_or_print_installation_path

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/download_if_necessary.sh"
download_if_necessary

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/unpack_if_necessary.sh"
unpack_if_necessary

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/set_compilers.sh"
set_compilers

source "${OPENCOARRAYS_SRC_DIR:-}/prerequisites/build-functions/build_and_install.sh"
build_and_install