# Findings Summary

A one-page summary of this project's key findings, for anyone who wants the substance without opening the notebook. Section numbers refer to `COVID19_Data_Analysis.ipynb`.

## Data Quality Findings (Section 4)

Every dataset was audited for missing values, duplicates, inconsistent naming, and out-of-range values before any analysis was run.

1. **Country-name mismatches.** `country_latest`/`full_grouped` and `worldometer` label several countries differently (`US` vs `USA`, `South Korea` vs `S. Korea`, `UK` vs `United Kingdom`, `Congo (Kinshasa)` vs `DRC`, etc.). A naive merge on country name would silently drop these countries. **Fix:** an explicit name-standardization map applied before any merge.

2. **`Province/State` missing for 34,404 of 49,068 rows** in `covid_19_clean_complete.csv`. Not bad data — most countries simply aren't split into provinces — but left as `NaN` it would make later `groupby` calls silently drop those rows. **Fix:** filled explicitly with `"Not Reported"`.

3. **`worldometer_data.csv` has real holes** in `NewCases`, `NewDeaths`, and `NewRecovered` (missing for ~205 of 209 countries) — unusable, and excluded rather than imputed. `WHO Region` was also missing for 25 rows; filled via the standardized country name rather than dropping those countries and understating region totals.

4. **`usa_county_wise.csv` mixes real US states with cruise ships and territories** (Diamond Princess, Grand Princess, Guam, Puerto Rico, etc.) under the same `Province_State` field. **Fix:** these entities were separated out explicitly before any "US states" comparison.

5. **Death-attribution artifact (the most consequential finding).** Some states have a large share of reported deaths attributed to `Unassigned` or `Out of <State>` pseudo-counties rather than a real county — e.g., South Dakota shows 1,004 of 1,126 total deaths (89%) under `Unassigned`, with 0 confirmed cases recorded against that same bucket. Left in, this would have put **South Dakota in first place for death rate (13.3%)** — a reporting artifact, not a real outcome. States above a materiality threshold were flagged and excluded from that specific ranking, with a note.

## Business Insights (Section 12)

**Descriptive:** ~16.5 million confirmed cases and ~654,000 deaths globally in this window — a global case-fatality rate of ~4.0%. The US, Brazil, and India had the three largest raw case counts.

**Trend:** Daily new cases rose from ~700/day at the start of the window to over 250,000/day by the end, driven mostly by a small number of large countries rather than a uniform global increase.

**Raw vs. per-capita:** Rankings diverge. The Americas lead on both raw and per-capita measures, so that ranking is robust. South-East Asia has the 2nd-highest raw case count but drops to 4th per-capita (it also has by far the largest regional population). Several smaller countries — Qatar, Bahrain, Panama — have far higher case *intensity* than their raw rank suggests.

**Testing confound:** Tests-per-million and cases-per-million are positively correlated (r ≈ 0.35, p < 0.001) but the relationship is moderate, not strong — testing volume is a real but partial explanation for cross-country case differences.

**US state-level:** California, Florida, New York, and Texas led on raw case count. Among high-case states, once states with unreliable death-attribution data were excluded, Connecticut, New Jersey, and New York had the highest death rates — consistent with the Northeast being hit earliest, before testing and treatment approaches had matured elsewhere.

**What this data cannot tell us:** why any specific country or state performed better or worse (requires policy, healthcare-capacity, and demographic data this dataset doesn't have), or anything about the pandemic's trajectory after July 2020.

## Why the Data-Quality Step Mattered

Finding 5 is the concrete proof this wasn't a box-checking exercise: skipping the audit would have put a data-quality artifact (South Dakota's 89% "Unassigned" death bucket) into a business-insight chart as if it were a genuine finding. The fix in Section 4 directly changed the correctness of the ranking in Section 9.
