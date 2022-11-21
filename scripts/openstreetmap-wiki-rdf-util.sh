#!/bin/bash
#===============================================================================
#
#          FILE:  openstreetmap-wiki-rdf-util.sh
#
#         USAGE:  ./scripts/openstreetmap-wiki-rdf-util.sh
#                 FORCE_DOWNLOAD=1 ./scripts/openstreetmap-wiki-rdf-util.sh
#                 DUMP_LOG=osmr.log.tsv ./scripts/openstreetmap-wiki-rdf-util.sh
#
#   DESCRIPTION:  Wikibase RDF dump script optimized for use of OpenStreetMap
#                 Data Items.
#
#       OPTIONS:  env WIKIBASE_URL_DUMP
#                 env FORCE_DOWNLOAD
#                 env OUTPUT_DIR
#                 env DUMP_LOG
#                 env DUMP_LOG
#
#  REQUIREMENTS:  - curl
#                 - gzip
#                 - riot (Apache Jena)
#
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Emerson Rocha <rocha[at]ieee.org>
#       COMPANY:  EticaAI
#       LICENSE:  Public Domain dedication
#                 SPDX-License-Identifier: Unlicense
#       VERSION:  v1.0
#       CREATED:  2022-11-18 07:19 UTC Based on wikibase-wiki-dump-items.sh
#      REVISION:  ---
#===============================================================================
set -e

ROOTDIR="$(pwd)"

#### Customizable environment variable _________________________________________
# User agent: https://meta.wikimedia.org/wiki/User-Agent_policy
USERAGENT="${USERAGENT:-"openstreetmap-wiki-rdf-util.sh/0.1 (https://github.com/fititnt/openstreetmap-wiki-rdf-exporter; rocha(at)ieee.org)"}"
WIKIBASE_URL_DUMP="${WIKIBASE_URL_DUMP:-"https://wiki.openstreetmap.org/dump/wikibase-rdf.ttl.gz"}"
OUTPUT_DIR="${OUTPUT_DIR:-"$ROOTDIR/data/cache"}"
FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-""}"
OPERATION="${OPERATION:-""}"
DUMP_LOG="${DUMP_LOG:-""}" # osmr.log.tsv

# command line
EXE_JENA_ARQ="${EXE_JENA_ARQ:-"arq"}"
EXE_JENA_RIOT="${EXE_JENA_RIOT:-"riot"}"

# Semi-internal envs
_DUMPFILE_TTL_GZ="${_DUMPFILE:-"wikibase-rdf.ttl.gz"}"
_DUMPFILE_TTL="${_DUMPFILE:-"wikibase-rdf.ttl"}"
_DUMPFILE_TTL_FIXME="${_DUMPFILE:-"wikibase-rdf.ttl.fixme"}"

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
#   _DUMPFILE_TTL_FIXME
# Arguments:
#
# Outputs:
#
#######################################
download_wikibase_dump() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [$WIKIBASE_URL_DUMP] ${tty_normal}"

  if [ -f "${OUTPUT_DIR}/${_DUMPFILE_TTL_GZ}" ] && [ -z "${FORCE_DOWNLOAD}" ]; then
    printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "cached"
    if [ -n "$DUMP_LOG" ]; then
      printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "cached" >>"${DUMP_LOG}"
    fi
  else
    printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "downloading"
    if [ -n "$DUMP_LOG" ]; then
      printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "downloading" >>"${DUMP_LOG}"
    fi
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
      if [ -n "$DUMP_LOG" ]; then
        printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "download error" >>"${DUMP_LOG}"
      fi
    else
      set -x
      gzip \
        --force \
        --stdout \
        --decompress \
        "${OUTPUT_DIR}/${_DUMPFILE_TTL_GZ}" \
        >"${OUTPUT_DIR}/${_DUMPFILE_TTL}"

      touch "${OUTPUT_DIR}/${_DUMPFILE_TTL_FIXME}"
      printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "fixme"
      if [ -n "$DUMP_LOG" ]; then
        printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "fixme" >>"${DUMP_LOG}"
      fi
      set +x
    fi

  fi
  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Enforce HTTPS protocol namespaces either empty or file://
# Without this reasoners break.
#
# Globals:
#   OUTPUT_DIR
#   _DUMPFILE_TTL
# Arguments:
#
# Outputs:
#
#######################################
dumpfile_namespace_hotfixes() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [${OUTPUT_DIR}/${_DUMPFILE_TTL}] ${tty_normal}"

  if [ -f "${OUTPUT_DIR}/${_DUMPFILE_TTL_FIXME}" ]; then
    if [ -n "$DUMP_LOG" ]; then
      printf "%s\t%s\n" "${_DUMPFILE_TTL}" "hotfixing" >>"${DUMP_LOG}"
    fi
    set -x

    # sed -r works on GNU sed (Not tested on OSX which may need sed -E instead)
    sed -i -r 's/^PREFIX ([a-z0-9]*): <file:\/\//PREFIX \1: <https:\/\//g' "${OUTPUT_DIR}/${_DUMPFILE_TTL}"
    #   in:  PREFIX p: <file://wiki.openstreetmap.org/prop/>
    #   out: PREFIX p: <https://wiki.openstreetmap.org/prop/>

    sed -i -r 's/^@prefix ([a-z0-9]*): <\/\//@prefix \1: <https:\/\//g' "${OUTPUT_DIR}/${_DUMPFILE_TTL}"
    #   in:  @prefix p: <//wiki.openstreetmap.org/prop/> .
    #   out: @prefix p: <http://wiki.openstreetmap.org/prop/> .

    rm "${OUTPUT_DIR}/${_DUMPFILE_TTL_FIXME}"

    set +x
  else
    printf "%s\t%s\n" "${_DUMPFILE_TTL_GZ}" "no change"
    if [ -n "$DUMP_LOG" ]; then
      printf "%s\t%s\n" "${_DUMPFILE_TTL}" "no hotfix applied" >>"${DUMP_LOG}"
    fi
  fi

  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Enforce HTTPS protocol namespaces either empty or file://
# Without this reasoners break.
#
# Globals:
#   OUTPUT_DIR
#   _DUMPFILE_TTL
# Arguments:
#
# Outputs:
#
#######################################
dumpfile_validate_basic() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [${OUTPUT_DIR}/${_DUMPFILE_TTL}] ${tty_normal}"

  "$EXE_JENA_RIOT" --validate "${OUTPUT_DIR}/${_DUMPFILE_TTL}"

  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Run some SPARQL queries against local RDF file
#
# Globals:
#   OUTPUT_DIR
#   _DUMPFILE_TTL
# Arguments:
#
# Outputs:
#
#######################################
run_query_tests() {
  echo "TODO"
  # "$EXE_JENA_ARQ" --help

  # QUERY='SELECT ?x WHERE { ?x  <http://www.w3.org/2001/vcard-rdf/3.0#FN>  "John Smith" }'

  # "$EXE_JENA_ARQ" --data="${OUTPUT_DIR}/${_DUMPFILE_TTL}" --query="${QUERY}"
  "$EXE_JENA_RIOT" --validate "${OUTPUT_DIR}/${_DUMPFILE_TTL}"
}

#### main ______________________________________________________________________

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "download" ]; then
  download_wikibase_dump
fi

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "dump_ns_hotfixes" ]; then
  dumpfile_namespace_hotfixes
fi

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "test_simple" ]; then
  dumpfile_validate_basic
  # run_query_tests
fi

# if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "merge_p" ]; then
#   # echo "TODO merge_p"
#   rdf_merge_items "P"
# fi

# if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "merge_q" ]; then
#   # echo "TODO merge_q"
#   rdf_merge_items "Q"
# fi
