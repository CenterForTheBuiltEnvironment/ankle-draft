# Revision Analysis — Building and Environment

25 comments total: 2 from the Editor, 16 from Reviewer 1, 7 from Reviewer 2.

Overall tone is positive — both reviewers praise the experimental design and statistical approach. The required changes cluster around three themes: **numerical consistency** (several headline figures are contradictory within the manuscript), **statistical completeness** (reporting gaps in power analysis, p-values, observation counts), and **discussion depth** (exposure duration, radiant asymmetry, individual variability).

---

## Refute

These comments can be addressed primarily through explanation rather than new analysis or changes to the results.

| ID | Comment | Rationale for refuting / defending |
|----|---------|-------------------------------------|
| C03 | Local ankle insulation lower than 0.75 clo due to thin socks | The dissatisfaction model is fitted empirically to observed responses — it is not derived from local insulation values. The 0.75 clo describes the ensemble for reproducibility, not as an input to local heat-transfer equations. A short clarification paragraph suffices. |
| C07 | Soften assertion about 20-min exposure having limited influence | Partly refutable: the skin temperature extrapolation to 90 min is a legitimate methodological defence. However, the tone of the assertion should be softened and the vasoconstriction point acknowledged. |
| R2-03 | Further justify 20-min exposure duration | Same as C07 — partially defensible via the extrapolation analysis and prior literature. A fuller discussion rather than new data is sufficient. |

---

## Minor Revisions

Straightforward fixes — mostly text corrections, numerical consistency, and formatting. Most of these **can be handled directly in the manuscript or R code**.

| ID | Comment | Action | Can Claude handle? |
|----|---------|--------|--------------------|
| **E01** | Highlights > 85 characters | Shorten each highlight to ≤ 85 chars | ✅ Yes — text edit |
| **E02** | Figures: increase font size, check readability | Font sizes already increased for Figs 3–6; verify all figures render clearly at 100% | ✅ Yes — already partially done; can audit remaining figures |
| **C02** | Abstract lacks mention of limitations | Add one sentence on 20-min exposure and absence of radiant asymmetry | ✅ Yes — text edit (abstract is at ~250 words — will need to trim) |
| **C05** | Turbulence intensity table: decimals vs. percentages | Check raw values in `x_analysis.R` and fix either the table labels (add "×100") or the values | ✅ Yes — data/code check + table edit |
| **C09** | Overprediction factor: 2.8× (abstract) vs 2.3× (results) | Compute the correct average ratio from the data and use it consistently in abstract, highlights, and graphical abstract text | ✅ Yes — can compute from `lme_stats_d` / `dissatisfied_with_draft_ankles_rate`; text edits throughout |
| **C10** | 39% figure not traceable to results | Trace or correct: maximum in results is 30%. Remove "by as much as 39%" from abstract or replace with 30% | ✅ Yes — text edit in abstract |
| **C11** | Intercept difference: 1.91 (Results) vs ~1.5 (Conclusions) | Check the GLMM output in `x_analysis.R` for the correct value and fix one location | ✅ Yes — code check + text edit |
| **C12** | Reference clothing insulation: 0.5 clo (Abstract) vs 0.6 clo (Discussion) | Check ref [7] for the correct ensemble clo and use consistently | ✅ Yes — text edit |
| **C15** | Graphical abstract: Liu et al. "2007" should be 2017 | Correct year in the graphical abstract source file | ⚠️ Needs image edit (not directly in manuscript text) |
| **C16** | Truncated sentence in Section 4.3 | Locate and complete the sentence | ✅ Yes — text edit |
| **R2-04** | Axes missing/unclear in Figs 3–6; R² labels and legend alignment | Related to E02 — figure rendering improvements in `x_func.R` | ✅ Yes — R code edit |

---

## Major Revisions

These require new analysis, new content, or substantive additions to the manuscript.

| ID | Comment | Action needed |
|----|---------|---------------|
| **C01** | Sample size: no power analysis | Conduct a post-hoc power analysis (e.g., using `pwr` in R for the GLMM) or cite literature justifying N=51 for this type of within-subjects design. Add a paragraph to Methods. |
| **C04** | Skin temperature terminology: "ankle" but measured at mid-calf and feet | Clarify in Methods that iButtons were placed at mid-calf and dorsal foot, and rename the section/figures accordingly (e.g., "lower-limb skin temperature"). Justify why a dedicated ankle sensor was not used — or acknowledge the limitation explicitly. |
| **C06** | Report exact p-values, CIs, and effect sizes for non-significant relationships (Section 3.2) | Extract and report these from the `lme4` model objects in `x_analysis.R`. Adds to a results table or inline text. |
| **C08** | Expand discussion on combined effect of convection + radiant asymmetry | Write an expanded limitations/discussion paragraph citing literature on radiant asymmetry (e.g., ISO 7730, Fanger et al.) and how it would be expected to compound the covered-ankle effect. |
| **C13** | Report completion rates and number of observations per GLMM | Extract n_obs from model objects in R. Add a sentence to Methods and a note to Tables 4–5. |
| **C14** | Sex not discussed; reference study [7] was women-only | At minimum, add sex as a sensitivity analysis (check if it improves GLMM fit) and discuss the all-female composition of [7] vs. the mixed-sex present sample in the Discussion. |
| **G03 / general** | Broaden independent references in state-of-the-art | Identify 3–5 additional independent studies on local draft discomfort, ankle comfort, or winter clothing thermal comfort and cite them in the Introduction. |
| **R2-01** | Justify representativeness of custom displacement diffuser | Add a paragraph to Methods explaining the design rationale of the diffuser (velocity profile, temperature gradient, turbulence) and how it was validated against published downdraft characterizations. |
| **R2-02** | Compare conditions across three seated positions | Extract and report air temperature and air speed by position from the environmental data (`data/01-processed/env/`). A supplementary table or a brief note in Methods would address this. |
| **R2-05** | Discuss inter-individual variability | Add a discussion paragraph on the scatter in Figs 3–6 — could include SD or IQR of individual responses, and note that the GLMM random effects partially capture this. |
| **R2-06** | Explicitly state applicable range of models | Add a box or paragraph specifying the valid input ranges (17–20°C, 0.1–0.7 m/s, 0.75 clo covered / ~0.5–0.6 clo uncovered) and note that extrapolation beyond these is not validated. |
| **R2-07** | Discuss energy implications more carefully given no radiant asymmetry | Expand the Discussion to note that the energy savings estimates are conservative because real cold-window scenarios include radiant asymmetry, which would increase the dissatisfaction baseline and thus partially offset the savings. |

---

## Notes on Numerical Consistency (C09, C10, C11, C12)

These four comments all point to internal contradictions in the manuscript's headline numbers. They should be the **first priority** since the correct values need to be established before any other text edits are made.

- **C09:** The correct overprediction ratio needs to be computed from `dissatisfied_with_draft_ankles_rate`. The abstract/highlights say 2.8×, the body says 2.3×. Check whether 2.8× was the maximum or the mean — if 2.3× is the mean and 2.8× was cited as representative, clarify that distinction or pick one.
- **C10:** The 39% maximum overprediction in the abstract doesn't appear in the results. Likely needs to be changed to 30%.
- **C11:** The 1.91 vs ~1.5 intercept difference — one of these is wrong. Check `coef(summary(m_glmm_covered))` in the R output.
- **C12:** Check ref [7] — Liu et al. (2017) — for the clothing insulation of their participants. Use that value consistently.

---

## Summary Table

| Category | Count | Notes |
|----------|-------|-------|
| Refute | 3 | C03, C07, R2-03 — partially defensible; tone softening needed |
| Minor revision | 11 | Mostly text edits and figure fixes; ~8 are direct code/text changes |
| Major revision | 12 | New analyses, new paragraphs, or new content needed |
| **Total** | **25** | |
