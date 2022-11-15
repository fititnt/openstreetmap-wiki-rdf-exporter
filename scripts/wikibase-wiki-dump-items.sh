#!/bin/bash
#===============================================================================
#
#          FILE:  wikibase-wiki-dump-items.sh
#
#         USAGE:  ./scripts/wikibase-wiki-dump-items.sh
#                 DELAY=10 ./scripts/wikibase-wiki-dump-items.sh
#                 Q_START=1 Q_END=2 ./scripts/wikibase-wiki-dump-items.sh
#                 OPERATION=merge_p ./scripts/wikibase-wiki-dump-items.sh
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
#
#  REQUIREMENTS:  - curl
#                 - rdfpipe (pip install rdflib)
#                   - Used to merge results. Tested with rdflib 6.1.1. Feel
#                     free to use other tools to concatenate.
#
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Emerson Rocha <rocha[at]ieee.org>
#       COMPANY:  EticaAI
#       LICENSE:  Public Domain dedication
#                 SPDX-License-Identifier: Unlicense
#       VERSION:  v1.0
#       CREATED:  2022-11-14 10:38 UTC
#      REVISION:  ---
#===============================================================================
set -e

ROOTDIR="$(pwd)"

#### Customizable environment variable _________________________________________
WIKI_URL_ENTITYDATA="${WIKI_URL_ENTITYDATA:-"https://wiki.openstreetmap.org/wiki/Special:EntityData/"}"
P_START="${P_START:-"1"}"
P_END="${P_END:-"60"}"
Q_START="${Q_START:-"1"}"
Q_END="${Q_END:-"20000"}"
DELAY="${DELAY:-"5"}" # delay in seconds (after download success or error)
CACHE_ITEMS="${CACHE_ITEMS:-"$ROOTDIR/data/cache-wiki-item-dump"}"
CACHE_ITEMS_404="${CACHE_ITEMS_404:-"$ROOTDIR/data/cache-wiki-item-dump-404"}"
OUTPUT_DIR="${OUTPUT_DIR:-"$ROOTDIR/data/cache"}"
OPERATION="${OPERATION:-""}"

# Usert agent used: https://meta.wikimedia.org/wiki/User-Agent_policy
USERAGENT="${USERAGENT:-"wikibase-wiki-dump-itemsbot/0.1 (https://github.com/fititnt/openstreetmap-wiki-rdf-exporter; rocha(at)ieee.org)"}"

#### internal variables ________________________________________________________
#### Fancy colors constants - - - - - - - - - - - - - - - - - - - - - - - - - -
tty_blue=$(tput setaf 4)
tty_green=$(tput setaf 2)
tty_red=$(tput setaf 1)
tty_normal=$(tput sgr0)

## Example
# printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"
# printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
# printf "\t%40s\n" "${tty_blue} INFO: [] ${tty_normal}"
# printf "\t%40s\n" "${tty_red} ERROR: [] ${tty_normal}"
#### Fancy colors constants - - - - - - - - - - - - - - - - - - - - - - - - - -

#### functions _________________________________________________________________

#######################################
# Main loop. The output to screen will be a valid .tsv format. Example:
#   item<tab>result
#   Q1<tab>error cached
#   Q2<tab>cached
#   Q3<tab>downloaded
#
# Globals:
#    CACHE_ITEMS
#    CACHE_ITEMS_404
#
# Arguments:
#
# Outputs:
#
#######################################
main_loop_items() {
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"

  if [ ! -d "$CACHE_ITEMS" ]; then
    printf "%s\n" "${tty_red} ERROR: env CACHE_ITEMS \
[$CACHE_ITEMS]? ${tty_normal}"
    exit 1
  fi

  if [ ! -d "$CACHE_ITEMS_404" ]; then
    printf "%s\n" "${tty_red} ERROR: env CACHE_ITEMS_404 \
[$CACHE_ITEMS_404]? ${tty_normal}"
    exit 1
  fi

  # tab-separated output, START
  printf "\n%s\t%s" "item" "result"

  for ((c = P_START; c <= P_END; c++)); do
    download_wiki_item "P${c}" ""
  done
  for ((c = Q_START; c <= Q_END; c++)); do
    download_wiki_item "Q${c}" "?flavor=dump"
  done
  echo ""
  # tab-separated output, END

  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Download an item if already not cached on disk
#
# Globals:
#   CACHE_ITEMS
#   CACHE_ITEMS_404
#   RDF_INPUT_EXT
#   WIKI_URL_ENTITYDATA
#   DELAY
# Arguments:
#   item        string   (required) Examples: P2 , Q3, (...)
#   urlsuffix   string   (optional) Example:  ?flavor=dump
# Outputs:
#
#######################################
download_wiki_item() {
  item="$1"
  urlsuffix="${2-""}"
  # suffix=".nt"
  # printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [$WIKI_URL_ENTITYDATA] [$item] ${tty_normal}"

  # https://www.wikidata.org/wiki/Wikidata:Data_access/pt-br#Less_verbose_RDF_output

  if [ -f "${CACHE_ITEMS_404}/${item}.ttl" ]; then
    printf "\n%s\t%s" "${item}" "error cached"
  elif [ -f "${CACHE_ITEMS}/${item}.ttl" ]; then
    printf "\n%s\t%s" "${item}" "cached"
  else
    EXIT_CODE="0"
    # set -x
    curl \
      --user-agent "'$USERAGENT'" \
      --silent \
      --fail \
      --output "${CACHE_ITEMS}/${item}.ttl" \
      "${WIKI_URL_ENTITYDATA}${item}.ttl${urlsuffix}" || EXIT_CODE=$?
    # set +x
    if [ "$EXIT_CODE" != "0" ]; then
      printf "\n%s\t%s" "${item}" "error"
      touch "$CACHE_ITEMS_404/${item}.ttl"
    else
      # printf "\n%s" "${tty_green}${item}${tty_normal}"
      printf "\n%s\t%s" "${item}" "downloaded"
    fi
    # echo "before delay $DELAY"
    sleep "$DELAY"
    # echo "after delay"
  fi
  # printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Main loop. The output to screen will be a valid .tsv format. Example:
#   item<tab>result
#   Q1<tab>error cached
#   Q2<tab>cached
#   Q3<tab>downloaded
#
# Globals:
#    CACHE_ITEMS
#    OUTPUT_DIR
#
# Arguments:
#    itemtype    string    Type of item. Values: Q , P
# Outputs:
#
#######################################
rdf_merge_items() {
  itemtype="$1"
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"

  if [ ! -d "$CACHE_ITEMS" ]; then
    printf "%s\n" "${tty_red} ERROR: env CACHE_ITEMS \
[$CACHE_ITEMS]? ${tty_normal}"
    exit 1
  fi

  set -x
  rdfpipe \
    --input-format=ttl \
    --output-format=longturtle \
    "${CACHE_ITEMS}/${itemtype}"*.ttl \
    >"${OUTPUT_DIR}/${itemtype}.ttl"
  set +x

  printf "\t%40s\n" "${tty_blue} INFO: [hotfixes after formating] ${tty_normal}"
  set -x
  # Trying to be very specific, so unlikely edit text contents
  sed -i 's/^PREFIX schema1: /PREFIX schema: /' "${OUTPUT_DIR}/${itemtype}.ttl"
  sed -i 's/^    a schema1:/    a schema:/g' "${OUTPUT_DIR}/${itemtype}.ttl"
  sed -i 's/^    schema1:/    schema:/g' "${OUTPUT_DIR}/${itemtype}.ttl"
  # Input:  PREFIX p: <file://wiki.openstreetmap.org/prop/>
  # Output: PREFIX p: <https://wiki.openstreetmap.org/prop/>
  sed -i 's/^PREFIX p: <file:\/\//PREFIX p: <https:\/\//g' "${OUTPUT_DIR}/${itemtype}.ttl"

  # sed -r works on GNU sed (Not tested on OSX which may need sed -E instead)
  sed -i -r 's/^PREFIX ([a-z]*): <file:\/\//PREFIX \1: <https:\/\//g' "${OUTPUT_DIR}/${itemtype}.ttl"
  set +x

  echo "TODO"

  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#### main ______________________________________________________________________

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "download" ]; then
  main_loop_items
fi

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "merge_p" ]; then
  # echo "TODO merge_p"
  rdf_merge_items "P"
fi

if [ -z "${OPERATION}" ] || [ "${OPERATION}" = "merge_q" ]; then
  # echo "TODO merge_q"
  rdf_merge_items "Q"
fi
