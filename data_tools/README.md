# Updating the data

The app loads four files from `docs/data/`. Edit or regenerate them, check the result locally
(`cd docs && python3 -m http.server`), then commit and push `main` to deploy.

The XSLT steps need Java and Saxon-HE 11.x (XSLT 3.0). `regenerate-species.sh` looks for the jar
in `SAXON_LIB` (default: `/Applications/K4 XML Exporter16/lib`).

## Species list: `nyc-species.json`

The species list is the eBird checklist for New York County (US-NY-061), plus 4-letter banding
codes.

```sh
data_tools/regenerate-species.sh              # re-pull from eBird and rebuild
data_tools/regenerate-species.sh --skip-pull  # rebuild from data_raw/nyc-species-raw.json
git diff docs/data/nyc-species.json           # review before committing
```

The script runs `get-species.py`, which calls the eBird API with the token in that file. It then
runs `append-codes.xsl`, which reads `../docs/data/dummy.xml` as a placeholder input. Keep that
file.

**After a refresh, check the names.** eBird sometimes renames species (for example, Herring Gull
became American Herring Gull). A rename affects two other files:
- `alpha_codes_from_excel.json`: the 4-letter code is matched by exact common name. Add an entry
  for the new name, or the species loses its code. The script prints how many records have no
  code.
- `common-birds.txt`: update the name there too (see below).

## Common birds: `common-birds.txt`

This file has one eBird common name per line. A species on this list is treated as **common**,
and its alerts go to `#manhattan-chat`. Every other species is treated as rare and goes to
`#manhattan-rba`.

Names must match `nyc-species.json` exactly, including case and punctuation. A name that doesn't
match is ignored without any warning, so that common bird gets routed to `#manhattan-rba`. To
list the names that don't match:

```sh
python3 -c "import json; sp={s['common_name'] for s in json.load(open('docs/data/nyc-species.json'))}; print([l.strip() for l in open('docs/data/common-birds.txt') if l.strip() and l.strip() not in sp])"
```

## Hotspots: `david-barret-hot-spots.json`

The hotspots come from David Barrett's public Google My Maps list, "David Barrett's Central Park
Birding". To refresh them, download the KML and convert it:

```sh
curl -sL "https://www.google.com/maps/d/kml?mid=15NWcsQyX3a96yfnwEGsqwSVwMHA&forcekml=1" \
  -o data_raw/david-barret-hot-spots.kml
java -cp "$SAXON_LIB/*" net.sf.saxon.Transform \
  -xsl:data_tools/kml-to-json.xsl -s:data_raw/david-barret-hot-spots.kml \
  | python3 -m json.tool --indent 4 > docs/data/david-barret-hot-spots.json
git diff docs/data/david-barret-hot-spots.json
```

Each hotspot is `{ name, lat, lon }`, with the coordinates stored as strings. The pin is the
point David chose on the map, so it's only roughly in the middle of a large hotspot. That's why
the app's default pin is the reporter's location. `kml-to-csv.xsl` produces the same data as CSV.

## 4-letter codes: `alpha_codes_from_excel.json`

This is the reference input for `append-codes.xsl`. It was built from the alpha code spreadsheet
in `data_raw/Alpha_codes_eng.xlsx`. Usually you only need to add entries by hand when eBird
renames a species (see above).
