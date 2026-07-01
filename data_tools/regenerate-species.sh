#!/usr/bin/env bash
#
# Regenerate the species list the app loads (docs/data/nyc-species.json).
#
# Two stages:
#   1. get-species.py   pulls the current NYC (US-NY-061) list from the eBird API
#                       -> data_raw/nyc-species-raw.json   { code, common_name, scientific_name }
#   2. append-codes.xsl adds a code4 (4-letter banding code) per record, matched by name
#                       against docs/data/alpha_codes_from_excel.json
#                       -> docs/data/nyc-species.json       { code4, code, ... }
#
# Requirements: python3 (with `requests`), java, and Saxon-HE 11.x.
# Point SAXON_LIB at the dir holding Saxon-HE-11.6.jar if it differs from the default.
#
# Usage:
#   data_tools/regenerate-species.sh            # full refresh (re-pull from eBird)
#   data_tools/regenerate-species.sh --skip-pull  # reuse existing raw file, just re-augment
#
# Review the diff before committing:  git diff docs/data/nyc-species.json
#
set -euo pipefail

SAXON_LIB="${SAXON_LIB:-/Applications/K4 XML Exporter16/lib}"
SAXON_JAR="$SAXON_LIB/Saxon-HE-11.6.jar"

# Resolve repo root from this script's location (works regardless of cwd).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW="$ROOT/data_raw/nyc-species-raw.json"
OUT="$ROOT/docs/data/nyc-species.json"

if [[ ! -f "$SAXON_JAR" ]]; then
  echo "Saxon jar not found: $SAXON_JAR" >&2
  echo "Set SAXON_LIB to the directory containing Saxon-HE-11.6.jar." >&2
  exit 1
fi

# --- Stage 1: pull raw species list from eBird -------------------------------
if [[ "${1:-}" == "--skip-pull" ]]; then
  echo "Skipping eBird pull; reusing $RAW" >&2
else
  echo "Pulling species list from eBird (US-NY-061)..." >&2
  python3 "$ROOT/data_tools/get-species.py" US "New York" > "$RAW"
fi
python3 -c "import json,sys; d=json.load(open('$RAW')); print(f'  raw: {len(d)} species', file=sys.stderr)"

# --- Stage 2: augment with code4, pretty-print to match existing 4-space style
# The transform reads its data via unparsed-text(); -s: just supplies a context
# node so match="/" fires. dummy.xml is a tiny throwaway kept for this purpose.
# Saxon emits minified JSON; re-indent to 4 spaces so diffs stay clean.
echo "Augmenting with code4 via Saxon..." >&2
# "$SAXON_LIB/*" puts Saxon-HE plus its xmlresolver companion jars on the classpath
# (java expands the trailing /* to all jars in the dir; Saxon-HE alone is insufficient).
( cd "$ROOT/data_tools" && java -cp "$SAXON_LIB/*" net.sf.saxon.Transform \
    -xsl:append-codes.xsl -s:../docs/data/dummy.xml ) \
| python3 -c '
import json, sys
out = sys.argv[1]
data = json.load(sys.stdin)
with open(out, "w") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write("\n")
empty = sum(1 for r in data if not r.get("code4"))
print(f"  wrote {len(data)} records to {out} ({empty} without a code4)", file=sys.stderr)
' "$OUT"

echo "Done. Review: git diff docs/data/nyc-species.json" >&2
