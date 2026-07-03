# Reviewer Comments — Building and Environment

## Editor

- **E01:** Each highlight should be a maximum of 85 characters, including spaces.
- **E02:** Please increase the font size and improve the clarity of the figures to enhance readability. Please check your figures in pdf/word and ensure that the text is visible at 100% zoom.

---

## Reviewer 1

**Summary:** The manuscript investigates the ankle draft risk model within ASHRAE Standard 55 under winter clothing conditions. The authors conduct controlled laboratory experiments with 51 participants wearing winter attire (approx. 0.75 clo) and exposed to various ankle-level air temperatures and air speeds. The findings demonstrate that the existing draft model systematically overpredicts occupant dissatisfaction under winter clothing conditions. The authors propose updated prediction equations for both ankle-covered and ankle-uncovered scenarios. This work represents a valuable and highly practical contribution to the field of building energy efficiency and thermal comfort, potentially allowing for the optimization of perimeter heating and facade insulation requirements. The study is well-designed, but requires revisions regarding statistical reporting, internal numerical consistency of the headline results, data presentation consistency, sample size justification, and abstract refinement.

**General comments:** The overall quality of the study is high. The experimental design is robust, the thermal chamber parameters are well-monitored, and the statistical approaches (using generalized linear mixed-effects models and Monte Carlo simulations) are advanced and appropriate. Regarding the Graphical Abstract and Highlights, both are clear, informative, and effectively summarize the main novelty of the paper (the overprediction of the current model and the potential for energy savings); however, see C09 regarding the inconsistency of the reported overprediction factor and C15 regarding the cited publication year. To fully align with the reviewer guidelines, the authors should also address a few systemic issues:

- The abstract currently lacks any mention of the study's limitations, which is an essential requirement under the journal guidelines.
- The methodology does not present a power analysis or statistical justification for the sample size.
- Regarding self-citations: the author self-citation rate (~13%) is largely justified, since the study directly extends and re-analyses the datasets of [5] and [7]. Rather than reducing these citations, the authors are encouraged to broaden the representation of independent research groups in the state-of-the-art to balance the reference list.

### Specific Comments

**C01:** "controlled laboratory experiments with 51 participants" — The authors should provide a detailed sample size estimation or a post-hoc power analysis to justify why a cohort of 51 participants was statistically sufficient to detect the expected differences.

**C02:** "Abstract... These findings support differentiating ASHRAE Standard 55 ankle draft criteria" — The abstract does not contain any mention of the major limitations of the study (such as the short 20-minute exposure time or the omission of radiant asymmetry), which should be transparently stated.

**C03:** "This ensemble targets a clothing insulation of approximately 0.75 clo... long trousers (ending just above the ankle), thin socks, and closed-toe shoes." — Since the trousers ended just above the ankle and the participants wore thin socks, the local thermal insulation at the actual ankle region was likely much lower than the overall 0.75 clo. The authors should discuss the specific local insulation value of the sock/ankle region and clarify whether using standard 0.75 clo equations is representative of local heat transfer.

**C04:** "continuously recorded participants' skin temperature on the lateral lower leg (mid-calf) and feet" (Methods, l. 122) vs. "Figure 7 illustrates the progression of ankle skin temperatures" (Section 3.3.3, l. 283) — The localized draft was directed at ankle level (0.1 m), yet skin temperature was measured at the mid-calf (covered by trousers) and feet (inside closed-toe shoes), not at the ankle. Beyond the concern that these locations may not represent the local temperature drop at the exposed/thinly covered ankle, the entire skin-temperature analysis (Section 3.3.3, Figures 7–8) is labelled "ankle skin temperature." The authors should reconcile this terminology with the stated measurement locations, and either justify the absence of an ankle sensor or clarify how the reported "ankle" values were derived.

**C05:** "Turbulence, low (%) 0.36 (± 0.02)" — In Table 3, the turbulence intensity rows are labeled with percentage units (%), yet the values are listed as decimals (e.g., 0.36, 0.26, 0.24). If these denote 36%, 26%, and 24% (which aligns with the text's mention of 30% turbulence), the row label or the listed numbers should be corrected to avoid presenting mathematically incorrect turbulence intensities of less than 1%.

**C06:** "b ≈ 0.15–0.17 per °C ... R² ≤ 0.03" — The authors should report the exact p-values, confidence intervals, and effect sizes for the non-significant relationships discussed in Section 3.2 to ensure complete transparency in statistical reporting.

**C07:** "the use of a 20 min exposure duration is expected to have a limited influence on this study's main findings." — While the authors extrapolated skin temperature changes up to 90 minutes, localized draft discomfort often accumulates over longer periods due to systemic vasoconstriction. The authors should soften their assertion and explicitly discuss how a 20-minute exposure limits the assessment of long-term discomfort in real office scenarios.

**C08:** "Finally, the experimental setup simulated the convective component of window downdraft but did not include radiant asymmetry..." — Given that occupants in real buildings near cold windows experience simultaneous convective cooling and radiant heat loss, the authors should expand their discussion on how this combined effect might alter the performance of the proposed ankle-covered model in practical applications.

**C09:** "overestimating dissatisfaction by an average of 2.8 times" (Abstract; also Highlights and Graphical Abstract) vs. "corresponding to an overestimation of approximately 2.3 times" (Section 3.4, l. 322) — The headline overprediction factor is inconsistent between the abstract/highlights/graphical abstract (2.8×) and the results (2.3×; 30%/13% = 2.31). As this ratio is the central finding of the paper, the authors must reconcile the figures and report a single correct value consistently throughout.

**C10:** "overestimating dissatisfaction by an average of 2.8 times and by as much as 39% at high air speeds" (Abstract) — The 39% figure is not traceable to the Results. Section 3.4 reports a maximum absolute overprediction of 30% (17–18°C, high flow) and 26% at 19–20°C, and Figure 9(b) shows no segment reaching 39%. The authors should indicate the source of the 39% value or correct it.

**C11:** "The intercept of the covered model was 1.91 units lower than that of the uncovered model" (Section 3.5, l. 345) vs. "with an intercept difference of approximately 1.5 units on the logit scale" (Conclusions, l. 499) — These two statements refer to the same quantity but report 1.91 and ~1.5 (note this is distinct from the 1.22 coverage coefficient of the screening model in Table 4, which is a different quantity and need not match). Please reconcile the value reported in the Results and the Conclusions.

**C12:** "summer clothing with exposed ankles (~0.5 clo)" (Abstract, l. 12; also l. 56) vs. "In the experiments of [7], where participants wore summer clothing (~0.6 clo)" (Discussion, l. 366) — The clothing insulation attributed to the exposed-ankle reference condition (and specifically to [7]) is given as ~0.5 clo in the Abstract/Introduction and ~0.6 clo in the Discussion. As this is the contrast value underpinning the study's premise, a single consistent figure should be used.

**C13:** "Participants were not required to respond to any individual question, though completion rates were monitored" (l. 134–135) — The actual completion/response rates are never reported, nor is the total number of observations entering the mixed-effects models (51 subjects × 9 conditions, less missing data). For reproducibility and to support the GLMM results in Tables 4–5, the authors should report the number of observations per model and the extent and handling of missing responses.

**C14:** "A total of 51 subjects participated in the study (28 female, 20 male, 3 other)" (l. 233) — The reference study anchoring the exposed-ankle condition was conducted on women only (ref. [7], "Sensation of draft at uncovered ankles for women exposed to displacement ventilation..."), whereas the present sample is mixed-sex. Sex is not included as a candidate predictor (Section 3.5) nor discussed. The authors should report whether sex modulates the dissatisfaction response and, at minimum, address sample sex composition as a factor in both comparability with [7] and generalizability.

**C15:** Graphical Abstract — "The ASHRAE 55 Draft Risk model by Liu et al. (2007) was designed for summer attire." The model is dated 2007, but reference [5] (S. Liu, S. Schiavon, A. Kabanshi, W.W. Nazaroff, *Predicted percentage dissatisfied with ankle draft*, Indoor Air 27, 852–862) was published in 2017. Please correct the year in the graphical abstract.

**C16:** "Within the near-neutral thermal range where ASHRAE Standard 55 applies, PMV provides the best available proxy for whole-body thermal sensation during design eva" (Section 4.3, l. 446–447) — The sentence is truncated mid-word ("eva…") and the paragraph ends without punctuation, leaving the statement incomplete. Please complete the sentence.

---

## Reviewer 2

**R2-01:** The authors used a custom displacement diffuser to simulate real window downdraft, but only a schematic illustration is provided. More importantly, the authors should explain why the generated airflow can be considered representative of real window downdraft, and how the similarity between the two was verified in terms of ankle-level air temperature, air speed, airflow direction, and turbulence characteristics.

**R2-02:** The experiment involved three seated test positions, but the consistency of local conditions among them is not sufficiently reported. The authors should compare ankle-level air temperature and air speed across the three positions.

**R2-03:** Each exposure lasted only 20 min, which may not represent long-term sedentary office work near windows. Although this issue has been acknowledged in the Limitations section, the authors should further justify the exposure duration and discuss whether longer exposure may lead to different discomfort responses.

**R2-04:** The axes in Figures 3–6 appear to be partially missing or not clearly displayed. In addition, the R² labels and legends are not well aligned. The authors should revise these figures to improve readability and presentation quality.

**R2-05:** The results show considerable scatter in local thermal sensation and ankle-level air movement acceptability, suggesting substantial individual differences in responses to ankle draft. However, the Results section mainly reports group-level trends. The authors should provide more discussion on inter-individual variability, or clarify whether the proposed model is mainly intended to represent average population responses.

**R2-06:** The covered-ankle and uncovered-ankle models were developed under specific experimental conditions, including ankle-level air temperatures of approximately 17–20°C, air speeds of 0.1–0.7 m/s, and specific clothing conditions. The authors should explicitly state the applicable range of the proposed models to avoid inappropriate extrapolation to lower temperatures, higher air speeds, or different clothing conditions.

**R2-07:** The authors suggest that the proposed covered-ankle criterion may help reduce facade insulation or perimeter heating requirements. However, the experiment only simulated the convective component of window downdraft and did not include radiant asymmetry from cold window surfaces, which is also an important contributor to perimeter-zone discomfort. Therefore, the implications for reducing facade insulation or perimeter heating systems should be discussed more carefully.
