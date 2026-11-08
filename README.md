# COVID-19 Data Analysis

Global & US county-level exploratory and comparative analysis of the COVID-19 pandemic's first six months (Jan 22 – Jul 27, 2020), covering data-quality auditing, per-capita normalization, correlation testing, a US state-level deep dive, and a SQL analysis layer.

## Business Problem

During the first six months of the pandemic, decision-makers needed answers to three practical questions:

1. **Where is the outbreak worst right now** — in absolute terms and relative to population?
2. **Is the situation improving or worsening** globally and in specific countries/US states?
3. **What is testing telling us** — are more cases being found because there's more virus, or because there's more testing?

**What this analysis supports:** relative prioritization of attention/resources, spotting regions whose case counts look low only because of low testing, and identifying whether specific US states are outliers in death rate (not just case count).

**What this analysis cannot support:** causal claims about *why* a country or state performed better or worse (policy, healthcare capacity, demographics, and reporting practices all confound the raw numbers), anything about variants or later pandemic stages (data stops in July 2020), or individual-level risk.

## Datasets

| Dataset | Grain | Rows | Used for |
|---|---|---|---|
| `day_wise.csv` | 1 row per day (global) | 188 | Global trend lines |
| `full_grouped.csv` | 1 row per day per country | 35,156 | Country trend lines, SQL layer |
| `country_wise_latest.csv` | 1 row per country (snapshot) | 187 | Country rankings, region grouping |
| `covid_19_clean_complete.csv` | 1 row per day per country/province | 49,068 | Cross-check / province-level detail |
| `worldometer_data.csv` | 1 row per country (snapshot) | 209 | Population, testing → per-capita metrics |
| `usa_county_wise.csv` | 1 row per day per US county | 627,920 | US state/county deep dive |

Source: [Kaggle — COVID-19 Dataset](https://www.kaggle.com/datasets/imdevskp/corona-virus-report)

## Key Findings

Full detail in [`docs/findings_summary.md`](docs/findings_summary.md). Highlights:

- **Data quality first:** five real issues were found and explicitly fixed before analysis — country-name mismatches across datasets, a meaningful (not erroneous) missing-value pattern, unusable columns excluded rather than imputed, non-state entities (cruise ships, territories) separated from real US states, and a death-attribution artifact that would have put South Dakota in first place for death rate — a reporting glitch, not a real outcome.
- **Raw vs. per-capita rankings diverge:** the Americas lead on both measures, but South-East Asia drops from 2nd to 4th once population is accounted for. Several smaller countries (Qatar, Bahrain, Panama) have far higher case *intensity* than their raw rank suggests.
- **Testing volume is a partial, not full, explanation** for case-count differences across countries (Pearson r ≈ 0.35, p < 0.001 — positive but moderate).
- **US state-level:** California, Florida, New York, and Texas led on raw case count. Among high-case states, Connecticut, New Jersey, and New York had the highest death rates once states with unreliable death-attribution data were excluded — consistent with the Northeast being hit earliest.

## Repository Structure

```
covid19-data-analysis/
├── README.md
├── requirements.txt
├── data/
│   ├── raw/              # original source CSVs
│   └── processed/        # cleaned exports (facts, dims, audit, summaries)
├── notebooks/
│   └── COVID19_Data_Analysis.ipynb
├── sql/
│   └── analysis_queries.sql
├── outputs/
│   └── charts/
└── docs/
    └── findings_summary.md
```

## How to Run

```bash
pip install -r requirements.txt
jupyter notebook notebooks/COVID19_Data_Analysis.ipynb
```

The notebook reads from `data/raw/`, writes cleaned tables and charts to `outputs/`, and runs a SQL layer against an in-memory SQLite database populated from the cleaned data.

## Tech Stack

- **Python:** pandas, numpy, scipy, matplotlib, seaborn
- **SQL:** SQLite (in-memory) — subqueries, joins, window functions, `GROUP BY`/`HAVING`
- **Analysis:** data-quality auditing, per-capita normalization, Pearson correlation testing

## Limitations

- Data covers Jan 22 – Jul 27, 2020 only — the earliest phase of the pandemic, before vaccines, variants, and mature testing infrastructure in most countries.
- Case and death counts depend entirely on each country's testing and reporting practices, which varied enormously.
- The country-name standardization map covers mismatches affecting the top ~20 countries by case count; a handful of very small countries/territories may still fail to match across datasets.
- US county data excludes population, so US state-level analysis uses raw counts and death-rate-among-confirmed, not per-capita.
- `Recovered` figures are widely considered less reliable than `Confirmed`/`Deaths` in this dataset generation and are not leaned on for insights.

## Author's Note

This project builds on an earlier beginner EDA pass. This version adds an explicit data-quality audit, per-capita normalization, a correlation test on the testing confound, a previously-unused US county dataset, a parameterized country-trend function, a SQL analysis layer, a written business-insights section grounded in the computed numbers, and a plan for a Power BI handoff.
