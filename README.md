# Ankle Draft Risk Model Under Winter Clothing Conditions

**Tobias Kramer, Junmeng Lyu, Stefano Schiavon**  
Center for the Built Environment, University of California, Berkeley

---

## About

This repository contains the data processing code, statistical analysis, and manuscript source for the paper *"Ankle draft risk model under winter clothing conditions"*, submitted to *Building and Environment*.

The study evaluates thermal comfort responses to ankle-level draft when participants wore winter clothing (0.75 clo). Based on controlled laboratory experiments with 51 participants, we find that the current ASHRAE Standard 55 ankle draft model overpredicts dissatisfaction by a factor of 2.8× under covered-ankle conditions, and propose separate draft risk models for covered and uncovered ankles.

---

## Repository Structure

```
ankle-draft-II/
├── src/
│   ├── R/                  # Statistical analysis and figure generation
│   └── python/             # Raw data import and preprocessing
├── data/
│   ├── 00-raw/             # Raw sensor and survey files (not tracked by git)
│   ├── 01-processed/       # Cleaned, standardized data (Python output)
│   └── 02-export/          # Analysis outputs used in the manuscript
├── manuscript/
│   ├── index.qmd           # Main manuscript (Quarto)
│   ├── refs.bib            # Bibliography
│   ├── figs/               # Figures
│   └── tables/             # Results tables
└── docs/                   # Rendered HTML output
```

---

## Analysis Pipeline

The analysis runs in two stages:

### Stage 1 — Data preprocessing (Python)

Raw experimental data (environmental sensors, air velocity, skin temperature iButtons, and survey responses) are processed into clean CSV files.

| Script | Purpose |
|--------|---------|
| `src/python/import_metadata.py` | Subject onboarding data |
| `src/python/import_survey.py` | Thermal comfort survey responses |
| `src/python/import_enviromental.py` | Environmental sensor logs (CO₂, temperature, humidity, etc.) |
| `src/python/import_airflow.py` | Air velocity measurements |
| `src/python/import_tsk.py` | Skin temperature (iButton) data |
| `src/python/constants.py` | Shared path and column-name configuration |
| `src/python/survey_config.py` | Survey question ID → variable name mapping |

### Stage 2 — Statistical analysis and figures (R)

R scripts are sourced in order by the manuscript at render time.

| Script | Purpose |
|--------|---------|
| `src/R/x_setup.R` | Package loading, factor levels, color palettes, figure dimensions |
| `src/R/x_data.R` | Imports processed CSVs and builds tidy analysis dataframes |
| `src/R/x_func.R` | Reusable plotting and data-summarization functions |
| `src/R/x_stat.R` | Statistical helpers (odds ratios and CIs from mixed-effects models) |
| `src/R/x_analysis.R` | Main analysis: all figures, models, and results reported in the manuscript |

### Stage 3 — Manuscript rendering (Quarto)

`manuscript/index.qmd` sources the R analysis and renders to DOCX and HTML via Quarto.

```bash
quarto render manuscript/index.qmd
```

---

## Reproducing the Analysis

### Requirements

**R** (≥ 4.2) with `renv` for package management:

```r
install.packages("renv")
renv::restore()
```

**Python** (≥ 3.10):

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Quarto** (≥ 1.4): [quarto.org](https://quarto.org)

### Steps

1. Place raw data files in `data/00-raw/` (see directory structure above).
2. Run the Python import scripts to populate `data/01-processed/`.
3. Open the RStudio project (`ankle-draft-II.Rproj`) or render from the terminal:

```bash
quarto render manuscript/index.qmd
```

The rendered manuscript is written to `docs/`.

---

## Key Dependencies

| Tool | Version |
|------|---------|
| R | ≥ 4.2 |
| lme4 | mixed-effects models |
| ggplot2 / patchwork | figures |
| gt | tables |
| Python | ≥ 3.10 |
| pandas | 2.3.3 |
| Quarto | ≥ 1.4 |

Full R package versions are pinned in `renv.lock`. Python dependencies are in `requirements.txt`.

---

## Citation

> Kramer T, Lyu J, Schiavon S. Ankle draft risk model under winter clothing conditions. *Building and Environment* (under review).
