# United Nations membership status - Data package

This data package contains the data that powers the chart ["United Nations membership status"](https://ourworldindata.org/grapher/united-nations-membership-status?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website. It was downloaded on September 12, 2026.

### Active Filters

A filtered subset of the full data was downloaded. The following filters were applied:

## CSV structure

Each row is an observation for an entity (usually a country or region) at a timepoint.

- "Entity" — the name of the entity, e.g. "United States".
- "Code" — our internal entity code. For most countries this is the [ISO alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code, e.g. "USA"; historical and other non-standard entities get a custom code.
- "Year" or "Day" — the timepoint. Annual data has a "Year" column holding an integer year; otherwise a "Day" column holds a date string in the form "YYYY-MM-DD".
- The final column is the data column — the time series that powers the chart. Downloaded with the "full data" option it corresponds to the time series below; with "only selected data visible in the chart" it is transformed depending on the chart type, so the correspondence may be less direct.


## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc.

## How we process data at Our World in Data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stitch together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

Preparing this data involves several processing steps. Depending on the data, this can include standardizing country names and world region definitions, converting units, calculating derived indicators such as per capita measures, as well as adding or adapting metadata such as the name or the description given to an indicator.
[Read about our data pipeline](https://docs.owid.io/projects/etl/).

## Detailed information about the data


### United Nations membership status
Membership is defined along current countries and their borders.
Last updated: May 15, 2025  
Next expected update: October 2026  
Date range: 1945–2024  
Source: United Nations (2025) – with major processing by Our World in Data  

#### How to cite this data

United Nations (2025) – with major processing by Our World in Data

#### Notes on our processing step for this indicator
The list of current UN members has been expanded with non-member entities we can map but are not included in the original list. Added entities include Taiwan, Palestine and Kosovo, among others.


## Sources

These are the sources behind the data in this package. Each time series above names the ones it draws on in its citation.

### United Nations – United Nations member states

This dataset contains the list of member states of the United Nations, with their date of admission.

Producer: United Nations  
Published: 2025  
Retrieved on: 2025-05-15  
Retrieved from: https://www.un.org/en/about-us/member-states  
License: Terms and conditions of use of United Nations websites (https://www.un.org/en/about-us/terms-of-use)  

Citation: United Nations – Member States (2025).

    