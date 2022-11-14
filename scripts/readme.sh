#!/bin/bash
#===============================================================================
#
#          FILE:  readme.sh
#
#         USAGE:  ./scripts/readme.sh
#   DESCRIPTION:  ---
#
#       OPTIONS:  ---
#
#  REQUIREMENTS:  - python
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

echo "cat playbook.sh"
echo "exiting..."
echo 1

## Run this to download repositories and install dependencies
./scripts/setup.sh

## Examples of scripts
scripts/cache/sophox/osm2rdf/osm2rdf.py --help
