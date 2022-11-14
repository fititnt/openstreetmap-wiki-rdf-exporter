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

# strange, this command try use > 10GB ram for a 1MB .osm.pbf file (Sao Tome and Principe)
scripts/cache/sophox/osm2rdf/osm2rdf.py parse data/cache/osm-data-test.osm.pbf data/cache/


# https://wiki.openstreetmap.org/wiki/Special:EntityData/Q2.nt

rdfpipe --input-format=trig data/cache-wiki-item-dump/P2.nt --output-format=longturtle
rdfpipe --input-format=trig data/cache-wiki-item-dump/P*.nt --output-format=longturtle > data/cache/P.ttl

rdfpipe --input-format=trig data/cache-wiki-item-dump/P*.ttl --output-format=longturtle > data/cache/Pv2.ttl

# 160 Q => ~400MB ram (because of pretty print output)
rdfpipe --input-format=trig data/cache-wiki-item-dump/Q*.nt --output-format=longturtle > data/cache/Q.ttl

rdfpipe --input-format=trig data/cache-wiki-item-dump/Q*.ttl --output-format=longturtle > data/cache/Qv2.ttl

# /opt/Protege-5.5.0/run.sh