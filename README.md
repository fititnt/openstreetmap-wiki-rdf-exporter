# openstreetmap-wiki-rdf-exporter
**Poor's man Wikibase exporter: one-by-one downloader of Ps and Qs (alternative for full dump).**
Tested with <https://wiki.openstreetmap.org/wiki/Data_items>, but can be customized for other instances.

> Tip: if you're here because OpenStreetMap Data Items, one outdated run is run available at <https://gist.github.com/fititnt/b1c8962f21d60433c2ca857f912d2fa8>

## Implementation
See [scripts/wikibase-wiki-dump-items.sh](scripts/wikibase-wiki-dump-items.sh)
for all options.

### Quickstart

```bash
git clone https://github.com/fititnt/openstreetmap-wiki-rdf-exporter.git
cd openstreetmap-wiki-rdf-exporter

./scripts/wikibase-wiki-dump-items.sh
# DELAY=5 (5 seconds) vs 60 Ps + 20.000 Qs

# While you wait, data/cache-wiki-item-dump/*.ttl are merged with rdfpipe:
pip install rdflib

# 28 Hours later...
ls data/cache/P.ttl
ls data/cache/Q.ttl
```

## References
- https://wiki.openstreetmap.org/wiki/Talk:Wiki#RDF_dump_of_OpenStreetMap_Data_Items
  - https://github.com/Sophox/sophox/blob/e77056d794ecf7ecd8957f947b2395e0fb2a45be/docker/blazegraph-updater/bg-updater.sh

<!--
TODO
- https://www.npmjs.com/package/wikibase-cli (maybe test this?)
-->

## TODOs
### `scripts/wikibase-wiki-dump-items.sh`
- [x] Review download time. Likely downloading redundant information.

## License

[![Public Domain](https://i.creativecommons.org/p/zero/1.0/88x31.png)](UNLICENSE)

To the extent possible under law, [Emerson Rocha](https://github.com/fititnt)
has waived all copyright and related or neighboring rights to this work to
[Public Domain](UNLICENSE).
