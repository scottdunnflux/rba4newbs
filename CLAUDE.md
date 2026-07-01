# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page web app that helps Manhattan birders compose "rare bird alert" (RBA) messages
for Discord. Users pick a species, pick/enter a location, and the app generates alert text
plus a link to the correct Discord channel (`#manhattan-rba` for rare species, `#manhattan-chat`
for common ones).

## Architecture

**The entire app is `docs/index.html`.** It is a self-contained, no-build React 18 app that uses
Babel Standalone to transpile JSX in the browser at load time. There is no bundler, no npm
install, no compile step. React, ReactDOM, Babel, and Tailwind 2 are all loaded from CDNs
inside a single `<script type="text/babel">` block.

- `docs/` is the deployment root — the app is served via GitHub Pages at
  https://scottdunnflux.github.io/rba4newbs/ (remote `origin`). Editing `docs/index.html` and
  pushing to `main` deploys.
- `docs/manifest.json` + `docs/img/` make it an installable PWA.
- `mrba-index-prototype.html` (repo root) is an earlier standalone prototype — **not** deployed.
  The live app is `docs/index.html`.

### App structure (all inside `docs/index.html`)
- `useDataLoader()` — hook that fetches the three data files from `./data/` on mount. Note it
  tolerates `david-barret-hot-spots.json` being either a bare array or `{ "hotspots": [...] }`.
- `App` — top-level component; a 3-step wizard driven by `currentPage` state
  (`'species'` → `'location'` → `'alert'`). Selected species and location live here and are
  passed down.
- `SpeciesPage` — species search + selection. Matching is **prefix-per-token across fields**:
  the query is split on whitespace/hyphens and every token must be a prefix of some word in
  `common_name`, `code4` (4-letter alpha code), `code` (eBird code), or `scientific_name`.
- `LocationPage` — three location methods: hotspot autocomplete, "near me" (GPS + nearest 5
  hotspots by distance), and free-form text / map pin.
- `LocationMap` — Google Maps pin picker (Maps JS API loaded on demand).
- `AlertPage` — composes the alert text, chooses the Discord channel, and builds Twitter text.
  Google/Apple Maps pin URLs are embedded when coordinates exist.

### Live data files (`docs/data/`)
These are what the running app actually loads:
- `nyc-species.json` — species list. **This is the file the app loads.**
  Schema: `{ code4, code, common_name, scientific_name }`. The `code4` field (4-letter banding
  code) is added by the augmentation pipeline (see below); 26/398 records have an empty `code4`.
- `common-birds.txt` — newline-separated common-name list; membership decides common vs. rare
  (rare → `#manhattan-rba`).
- `david-barret-hot-spots.json` — `{ hotspots: [{ name, lat, lon }] }`.
- `alpha_codes_from_excel.json` — reference alpha-code data (input to the pipeline).

## Data pipeline (`data_tools/`)

Offline, run manually when regenerating data — not part of the app. Source inputs live in
`data_raw/` (KML/KMZ hotspot exports, eBird PDFs/spreadsheets), outputs go to `docs/data/`.

The species-list flow is two stages:
1. `get-species.py` — pulls the NYC (US-NY-061) species list from the eBird API and prints raw
   JSON (`{ code, common_name, scientific_name }`) to stdout. Requires an eBird API token
   (`X-eBirdApiToken`). Run: `python data_tools/get-species.py US "New York" > data_raw/nyc-species-raw.json`
2. `append-codes.xsl` — reads `data_raw/nyc-species-raw.json` + `alpha_codes_from_excel.json`,
   adds a `code4` per record, and prints the augmented JSON to stdout. Redirect it to
   `docs/data/nyc-species.json` (the app file). Input ≠ output on purpose: re-running on the
   already-augmented file would emit duplicate `code4` keys.

Other tools:
- `kml-to-json.xsl` / `kml-to-csv.xsl` — XSLT 3.0 stylesheets converting hotspot KML to
  JSON/CSV (needs an XSLT 3.0 processor such as Saxon).

## Working on this repo

- **No build/test/lint tooling exists.** To run locally, serve `docs/` over HTTP (e.g.
  `python3 -m http.server` from inside `docs/`) — opening `index.html` via `file://` breaks the
  `fetch()` calls for data files. Then edit `index.html` and reload.
- `spec.md` describes the original intent (and mentions Ionic + a React/Vite build that were
  never adopted). Treat `docs/index.html` as ground truth over `spec.md` where they disagree.
- API keys for Google Maps and eBird are currently hardcoded in the source (`docs/index.html`,
  `data_tools/get-species.py`).
