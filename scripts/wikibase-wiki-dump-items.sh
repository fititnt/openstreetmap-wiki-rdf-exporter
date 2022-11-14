#!/bin/bash
#===============================================================================
#
#          FILE:  wikibase-wiki-dump-items.sh
#
#         USAGE:  ./scripts/wikibase-wiki-dump-items.sh
#   DESCRIPTION:  ---
#
#       OPTIONS:  ---
#
#  REQUIREMENTS:  - rdfpipe (pip install rdflib)
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

CACHE_ITEMS="$ROOTDIR/data/cache-wiki-item-dump"
CACHE_ITEMS_404="$ROOTDIR/data/cache-wiki-item-dump-404"

#### Customizable environment variable _________________________________________
WIKI_URL_ENTITYDATA="${WIKI_URL_ENTITYDATA:-"https://wiki.openstreetmap.org/wiki/Special:EntityData/"}"
P_START="${P_START:-"1"}"
P_END="${P_END:-"60"}"
Q_START="${Q_START:-"1"}"
Q_END="${Q_END:-"100"}"
DELAY="${DELAY:-"5"}" # delay in seconds (after download success or error)

# https://meta.wikimedia.org/wiki/User-Agent_policy
# User-Agent: CoolBot/0.0 (https://example.org/coolbot/; coolbot@example.org) generic-library/0.0
USERAGENT="${USERAGENT:-"wikibase-wiki-dump-itemsbot/0.1 (https://github.com/fititnt/openstreetmap-wiki-rdf-exporte; rocha(at)ieee.org)"}"

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
# Download existing Sophox monorepo to local cached directory.
#
# Globals:
#   ROOTDIR
#   P_START
#   P_END
#   Q_START
#   Q_END
# Arguments:
#
# Outputs:
#
#######################################
main_loop_p() {
  # trivium_basi="$SOPOX_LOCAL"
  printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED ${tty_normal}"

  printf "\n%s\t%s" "item" "result"

  for ((c = P_START; c <= P_END; c++)); do
    download_wiki_item "P${c}"
  done

  for ((c = Q_START; c <= Q_END; c++)); do
    download_wiki_item "Q${c}"
  done

  printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#######################################
# Download an item if already not cached on disk
#
# Globals:
#   CACHE_ITEMS
#   CACHE_ITEMS_404
#   WIKI_URL_ENTITYDATA
#   DELAY
# Arguments:
#
# Outputs:
#
#######################################
download_wiki_item() {
  item="$1"
  suffix=".nt"
  # printf "\n\t%40s\n" "${tty_blue}${FUNCNAME[0]} STARTED [$WIKI_URL_ENTITYDATA] [$item] ${tty_normal}"

  if [ -f "${CACHE_ITEMS_404}/${item}${suffix}" ]; then
    printf "\n%s\t%s" "${item}" "error cached"
  elif [ -f "${CACHE_ITEMS}/${item}${suffix}" ]; then
    printf "\n%s\t%s" "${item}" "cached"
  else
    EXIT_CODE="0"
    # set -x
    curl \
      --user-agent "'$USERAGENT'" \
      --silent \
      --fail \
      --output "${CACHE_ITEMS}/${item}${suffix}" \
      "${WIKI_URL_ENTITYDATA}${item}${suffix}" || EXIT_CODE=$?
    # set +x
    if [ "$EXIT_CODE" != "0" ]; then
      printf "\n%s\t%s" "${item}" "error"
      touch "$CACHE_ITEMS_404/${item}${suffix}"
    else
      # printf "\n%s" "${tty_green}${item}${tty_normal}"
      printf "\n%s\t%s" "${item}" "downloaded"
    fi
    sleep "$DELAY"
  fi
  # printf "\t%40s\n" "${tty_green}${FUNCNAME[0]} FINISHED OKAY ${tty_normal}"
}

#### main ______________________________________________________________________
echo "TODO"

main_loop_p

# gh_repo_sync_pull_sophox
# python_requeriments_sophox
# data_test_download
