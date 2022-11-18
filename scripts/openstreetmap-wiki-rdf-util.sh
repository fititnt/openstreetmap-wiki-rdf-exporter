#!/bin/bash
#===============================================================================
#
#          FILE:  openstreetmap-wiki-rdf-util.sh
#
#         USAGE:  ./scripts/openstreetmap-wiki-rdf-util.sh
#                 FORCE_DOWNLOAD=1 ./scripts/openstreetmap-wiki-rdf-util.sh
#
#   DESCRIPTION:  This shell script will download Wikibase Ps and Qs in
#                 less efficient way, one by one. Cache individual results
#                 in disk (including errors). At the end it will merge
#                 the output into single files, already well formated
#                 in a preditable way (e.g. to allow diffs).
#                 The merging mecanism may
#
#       OPTIONS:  env WIKI_URL_ENTITYDATA=
#                     http://example.org/wiki/Special:EntityData/
#                 env DELAY
#                 env P_START
#                 env P_END
#                 env Q_START
#                 env Q_END
#                 env CACHE_ITEMS
#                 env CACHE_ITEMS_404
#                 env CACHE_ITEMS
#                 env CACHE_ITEMS_404
#                 env DUMP_LOG
#
#  REQUIREMENTS:  - curl
#                 - gzip
#
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Emerson Rocha <rocha[at]ieee.org>
#       COMPANY:  EticaAI
#       LICENSE:  Public Domain dedication
#                 SPDX-License-Identifier: Unlicense
#       VERSION:  v1.0
#       CREATED:  2022-11-14 10:38 UTC Based on wikibase-wiki-dump-items.sh
#      REVISION:  ---
#===============================================================================
set -e

ROOTDIR="$(pwd)"

#### Customizable environment variable _________________________________________
# User agent: https://meta.wikimedia.org/wiki/User-Agent_policy
USERAGENT="${USERAGENT:-"openstreetmap-wiki-rdf-util.sh/0.1 (https://github.com/fititnt/openstreetmap-wiki-rdf-exporter; rocha(at)ieee.org)"}"
WIKIBASE_URL_DUMP="${WIKIBASE_URL_DUMP:-"https://wiki.openstreetmap.org/dump/wikibase-rdf.ttl.gz"}"
# WIKI_URL_ENTITYDATA="${WIKI_URL_ENTITYDATA:-"https://wiki.openstreetmap.org/wiki/Special:EntityData/"}"
# P_START="${P_START:-"1"}"
# P_END="${P_END:-"60"}"
# Q_START="${Q_START:-"1"}"
# Q_END="${Q_END:-"20000"}"
# DELAY="${DELAY:-"5"}" # delay in seconds (after download success or error)
# CACHE_ITEMS="${CACHE_ITEMS:-"$ROOTDIR/data/cache-wiki-item-dump"}"
# CACHE_ITEMS_404="${CACHE_ITEMS_404:-"$ROOTDIR/data/cache-wiki-item-dump-404"}"
OUTPUT_DIR="${OUTPUT_DIR:-"$ROOTDIR/data/cache"}"
FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-""}"
OPERATION="${OPERATION:-""}"
DUMP_LOG="${DUMP_LOG:-""}"

# Semi-internal envs
_DUMPFILE_TTL_GZ="${_DUMPFILE:-"wikibase-rdf.ttl.gz"}"
_DUMPFILE_TTL="${_DUMPFILE:-"wikibase-rdf.ttl"}"

#### internal variables ________________________________________________________
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
# Download an Wikibase canonical RDF dumpfile GZiped to local cache and
# decompress
#
# Globals:
#   USERAGENT
#   WIKIBASE_URL_DUMP
#   OUTPUT_DIR
#   FORCE_DOWNLOAD
#   _DUMPFILE_TTL_GZ
#   _DUMPFILE_TTL
# Arguments:
#
# Outputs:
#
#######################################
download_wikibase_dump() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [$WIKIBASE_URL_DUMP] ${tty_normal}"

  if [ -f "${OUTPUT_DIR}/${_DUMPFILE_TTL_GZ}" ] && [ -z "${FORCE_DOWNLOAD}" ]; then
    printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "cached"
  else
    printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "downloading"
    EXIT_CODE="0"
    set -x
    curl \
      --user-agent "'$USERAGENT'" \
      --silent \
      --fail \
      --output "${OUTPUT_DIR}/${_DUMPFILE_TTL_GZ}" \
      "${WIKIBASE_URL_DUMP}" || EXIT_CODE=$?
    set +x

    if [ "$EXIT_CODE" != "0" ]; then
      printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "download error"
    else
      set -x
      gzip \
        --force \
        --stdout \
        --decompress \
        "${OUTPUT_DIR}/${_DUMPFILE_TTL_GZ}" \
        >"${OUTPUT_DIR}/${_DUMPFILE_TTL}"
      set +x
    fi

  fi
  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Download an Wikibase canonical RDF dumpfile GZiped to local cache and
# decompress
#
# Globals:
#   USERAGENT
#   WIKIBASE_URL_DUMP
#   OUTPUT_DIR
#   FORCE_DOWNLOAD
#   _DUMPFILE_TTL_GZ
#   _DUMPFILE_TTL
# Arguments:
#
# Outputs:
#
#######################################
dumpfile_namespace_hotfixes() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [$WIKIBASE_URL_DUMP] ${tty_normal}"

  echo "TODO"

  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#### main ______________________________________________________________________

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "download" ]; then
  download_wikibase_dump
fi

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "dump_ns_hotfixes" ]; then
  dumpfile_namespace_hotfixes
fi

# if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "merge_p" ]; then
#   # echo "TODO merge_p"
#   rdf_merge_items "P"
# fi

# if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "merge_q" ]; then
#   # echo "TODO merge_q"
#   rdf_merge_items "Q"
# fi
