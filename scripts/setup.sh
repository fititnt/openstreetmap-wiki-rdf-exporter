#!/bin/bash
#===============================================================================
#
#          FILE:  setup.sh
#
#         USAGE:  ./scripts/setup.sh
#   DESCRIPTION:  ---
#
#       OPTIONS:  ---
#
#  REQUIREMENTS:  - git
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Emerson Rocha <rocha[at]ieee.org>
#       COMPANY:  EticaAI
#       LICENSE:  Public Domain dedication
#                 SPDX-License-Identifier: Unlicense
#       VERSION:  v1.0
#       CREATED:  2022-11-14 09:31 UTC
#      REVISION:  ---
#===============================================================================
set -e

ROOTDIR="$(pwd)"
SOPHOX_GIT="https://github.com/Sophox/sophox.git"
SOPOX_LOCAL="$ROOTDIR/scripts/cache/sophox"

# Test data, < 1MB
OSM_PBF_TEST_DOWNLOAD="https://download.geofabrik.de/africa/sao-tome-and-principe-latest.osm.pbf"
OSM_PBF_TEST_FILE="$ROOTDIR/data/cache/osm-data-test.osm.pbf"

#### Fancy colors constants - - - - - - - - - - - - - - - - - - - - - - - - - -
tty_blue=$(tput setaf 4)
tty_green=$(tput setaf 2)
# tty_red=$(tput setaf 1)
tty_normal=$(tput sgr0)

## Example
# printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"
# printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
# printf "\t%40s\n" "${tty_blue} INFO: [] ${tty_normal}"
# printf "\t%40s\n" "${tty_red} ERROR: [] ${tty_normal}"
#### Fancy colors constants - - - - - - - - - - - - - - - - - - - - - - - - - -

#### functions _________________________________________________________________

#######################################
# Download existing Sophox monorepo to local cached directory.
#
# Globals:
#   ROOTDIR
#   SOPHOX_GIT
#   SOPOX_LOCAL
# Arguments:
#
# Outputs:
#
#######################################
gh_repo_sync_pull_sophox() {
  trivium_basi="$SOPOX_LOCAL"
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"

  if [ -d "$trivium_basi" ]; then
    # echo "local repo exist. Trying to pull ..."
    set -x
    git -C "${trivium_basi}" pull
    set +x
  else
    set -x
    mkdir "$trivium_basi"
    git clone "${SOPHOX_GIT}" "$trivium_basi"
    set +x
  fi
  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Install dependencies
#
# Globals:
#   SOPOX_LOCAL
# Arguments:
#
# Outputs:
#
#######################################
python_requeriments_sophox() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"
  pip install -r "$SOPOX_LOCAL/osm2rdf/requirements.txt"
  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Download test data
#
# Globals:
#   OSM_PBF_TEST_DOWNLOAD
#   OSM_PBF_TEST_FILE
# Arguments:
#
# Outputs:
#
#######################################
data_test_download() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"

  if [ ! -f "$OSM_PBF_TEST_FILE" ]; then
    # echo "local repo exist. Trying to pull ..."
    echo "TODO"
    set -x
    curl -o "${OSM_PBF_TEST_FILE}" "${OSM_PBF_TEST_DOWNLOAD}"
    set +x
  fi
  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#### main ______________________________________________________________________
# echo "TODO"

gh_repo_sync_pull_sophox
python_requeriments_sophox
data_test_download
