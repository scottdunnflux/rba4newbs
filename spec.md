# Overview
This will be a page used by a few hundred Manhattan based birders.
It's designed to assist novice birders with composing alerts of their bird sightings on discord.
They primarily need help determining which discord to use for their alert.
Alerts for common species are posted to #manhattan-chat while rare species are posted to #manhattan-rba
Novice birders may also need help specifying the correct hotspot. 
All birders will need help with map URLs which are most useful when there is no appropriate hotspot but handy
to include in alerts as a reminder for intermediate or advanced birders who forget hotspot locations.

# Approach
Users in the field load a page on their phone where they enter a species and location and see
alert text automatically composed for them that optionally includes pin links.
The alert text appears in a widget that has a "copy" option so they can easily copy the alert text for use on discord.
Beneath the alert text they see a link that takes them straight to the appropriate discord channel.

# Coding
**Data files**:
data/nyc-species.json  (loaded by the app; carries an added `code4` 4-letter banding code per record, merged in from the alpha-code pipeline)
data/common-birds.txt
data/david-barret-hot-spots.json
data/alpha_codes_from_excel.json

**Frameworks**: 
- React w/ Ionic for mobile UI and GPS
- Install Tailwind alongside Ionic. Use Tailwind for your layout/spacing, Ionic variables for colors/components.
- Tailwind for layout/spacing/responsive breakpoints.
- Ionic CSS variables for colors/themes and ready-made components (buttons, cards, modals).

## Page design
The page should have an ios look with ios theme and ui
A small page title appears at the top: Manhattan Bird Alerts for Newbs

## Feature 1 - Determine valid species
- User enters species name in text entry box
- beneath that entry box, as each letter is entered, a list of possible matches is displayed. 
   - Possibilities are determined by fuzzy/contains searching for entry box text in list of  `common_name` or `alternative_names` values `nyc-species.json`
   - Possibilities may also include `english_name` from `alpha_codes_from_excel.json` in cases where user text matches `four_letter_code`
- user taps species name to add species to list
   - IF species exists on the `common-birds.txt` list then note it as **Common**
      - ELSE note it as **Rare**
   - after species is appended to list, species text entry is cleared to allow entry of next species
- tapping "clear list" button resets list
- tapping "clear text" button resets text entry area for species

## Feature 2 - Location Entry
Location entry may happen in multiple ways. 
- They may chose a hotspot by typing name and selecting from autocomplete list
- selecting one "near me"
- entering free form location and/or pasting map URL

### Method 1: Hotspot autocomplete
- user enters location in text entry space
- beneath the location text entry space we see a dynamic list showing possible hotspot *names* listed in `david-barret-hot-spots.json`. 
   - Possibilities are determined by "contains" and fuzzy logic
   - list updates with each character entered into location text entry space

### Method 2: Hotspot near me
- user taps "near me" button (invoking the following)
	- user's current location is fetched from phone's GPS system
	- latitude and longitude of user's GPS corrdinates are noted
	- distance is measured between current location and each hotspot location in `david-barret-hot-spots.json`
	- hotspots with 5 shortest distances are listed

### Method 3: Non-hotspot standard text 
- User conveys that their own text will be used instead of a suggested hotspot name
   - if user enters coordinates, note the latitude and longitude
   - if user enters a map url, note the latitude and longitude

### IF Hotspot name is tapped (from Method 1 or 2)
- user taps hotspot name
   - coordinates pulled from `david-barret-hot-spots.json`
   - full hotspot name is entered in location entry space

## Feature 3 - Alert construction
- As values from Feature 1 & 2 are entered or updated, boilerplate alert text is composed
  in a widget box that includes a "copy" button. This text is composed as follows
   - Species text on first line
   - word "at" on new line
   - Location text on new line
   - blank line
   - IF lat and lon are not empty
	  - hyperlinked google maps URL constructed with coordinates formatted as [Google Pin](https://maps.google.com/?q={lat},{lon})
	  - hyperlinked apple maps URL constructed with coordinates [Apple Pin](http://maps.apple.com/?ll={lat},{lon}&q=Dropped%20Pin)
	  - each link will have a "share" button
- Beneath alert text widget we see a link to discord. 
  - IF any species entered is rare present link to #manhattan-rba
  - ELSE present link to #manhattan-chat

