import requests
import json
import sys

API_KEY = "gjfp0nrccoif"
HEADERS = {"X-eBirdApiToken": API_KEY}

def find_sub1_code(country_code: str, region_name: str) -> str:
    return 'US-NY-061'
    url = f"https://api.ebird.org/v2/ref/region/list/subnational1/{country_code}"
    resp = requests.get(url, headers=HEADERS)
    resp.raise_for_status()
    for entry in resp.json():
        if entry["name"].lower() == region_name.lower():
            return entry["code"]
    raise ValueError(f"No state/province named '{region_name}' in {country_code}")

def get_species_codes(region_code: str) -> list[str]:
    url = f"https://api.ebird.org/v2/product/spplist/{region_code}"
    resp = requests.get(url, headers=HEADERS)
    resp.raise_for_status()
    return resp.json()

def lookup_taxonomy_all(locale: str = "en") -> list[dict]:
    """
    Fetch the entire eBird taxonomy in one go, then we can
    filter down to just the codes we need locally.
    """
    url = "https://api.ebird.org/v2/ref/taxonomy/ebird"
    params = {
        "locale": locale,
        "fmt":    "json",     # <- this is the crucial bit
    #    "cat":    "species"   # optional filter
    }
    resp = requests.get(url, headers=HEADERS, params=params)
    resp.raise_for_status()
    return resp.json()

def build_species_list(country_code: str, region_name: str) -> list[dict]:
    # 1) Find your region code (e.g. "US-NY" or "US-NY-061")
    region_code = find_sub1_code(country_code, region_name)
    print(f"Using region code: {region_code}", file=sys.stderr)

    # 2) Get the raw species codes for that region
    codes = get_species_codes(region_code)
    print(f"Found {len(codes)} species codes", file=sys.stderr)

    # 3) Fetch the full taxonomy once
    taxonomy = lookup_taxonomy_all(locale="en")
    print(f"Fetched {len(taxonomy)} total taxonomy entries", file=sys.stderr)

    # 4) Filter down to only the codes we need
    code_set = set(codes)
    filtered = [
        {
            "code":             entry["speciesCode"],
            "common_name":      entry["comName"],
            "scientific_name":  entry["sciName"]
        }
        for entry in taxonomy
        if entry["speciesCode"] in code_set
    ]
    print(f"Matched {len(filtered)} entries in taxonomy", file=sys.stderr)
    return filtered

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python get-species.py COUNTRY_CODE REGION_NAME", file=sys.stderr)
        print("Example: python get-species.py US \"New York\"", file=sys.stderr)
        sys.exit(1)

    country, region = sys.argv[1], sys.argv[2]
    try:
        species_list = build_species_list(country, region)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    print(json.dumps(species_list, indent=2))

