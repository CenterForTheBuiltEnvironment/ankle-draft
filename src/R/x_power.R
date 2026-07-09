# ==============================================================================
# Title: Power Analysis
# Description: Simulation-based power analysis using Liu et al. (2017) as
#              the reference effect size. Justifies the N = 51 sample for
#              the covered-ankle GLMM.
#
# Runtime: ~10-20 minutes (nsim = 1000). Run once and save results.
# Author: Toby Kramer, Junmeng Lyu
# Date: 2026-07-03
# ==============================================================================

source(here::here("src", "R", "x_setup.R"))
source(here::here("src", "R", "x_data.R"))


# 1. Rebuild model data (mirrors x_analysis.R section 5) ======================

analysis_all <- dplyr::bind_rows(
  analysis %>%
    dplyr::filter(is_open_text == FALSE, workstation != "adaptation") %>%
    dplyr::mutate(response_value = as.numeric(response_value)) %>%
    dplyr::select(
      timestamp, subject_id, workstation, t_supply_c, t_air_c,
      v_air_m_s, question, response_value, turbulence_intensity
    ) %>%
    dplyr::mutate(source = "toby", clothing_type = "long"),

  analysis_liu %>%
    dplyr::filter(workstation != "adaptation") %>%
    dplyr::mutate(response_value = as.numeric(response_value)) %>%
    dplyr::select(
      timestamp, subject_id, workstation, t_supply_c, t_air_c,
      v_air_m_s, question, response_value, clothing_type, turbulence_intensity
    ) %>%
    dplyr::mutate(source = "liu")
)

new_model <- analysis_all %>%
  dplyr::arrange(subject_id, workstation, t_supply_c, v_air_m_s, t_air_c, question, timestamp) %>%
  dplyr::group_by(t_supply_c, v_air_m_s, t_air_c, subject_id, workstation, question) %>%
  dplyr::mutate(rep_id = dplyr::row_number()) %>%
  dplyr::ungroup() %>%
  tidyr::pivot_wider(
    id_cols = c(
      t_supply_c, v_air_m_s, t_air_c, subject_id, workstation,
      rep_id, source, clothing_type, turbulence_intensity
    ),
    names_from  = question,
    values_from = response_value
  ) %>%
  dplyr::mutate(
    dissatisfied_with_draft_ankles = dplyr::if_else(
      source == "liu",
      as.integer(thermal_sensation_ankles < 0 & air_movement_acceptability < 0),
      dissatisfied_with_draft_ankles
    )
  ) %>%
  dplyr::filter(
    !is.na(dissatisfied_with_draft_ankles),
    !is.na(thermal_sensation)
  )

ctr_vars  <- c("v_air_m_s", "thermal_sensation", "t_air_c", "t_supply_c", "turbulence_intensity")
ctr_means <- colMeans(new_model[ctr_vars], na.rm = TRUE)

new_model_c <- new_model %>%
  dplyr::mutate(dplyr::across(dplyr::all_of(ctr_vars), \(x) x - mean(x, na.rm = TRUE)))


# 2. Fit reference model (Liu 2017, exposed ankles) ===========================

liu_short_data <- new_model_c %>% dplyr::filter(source == "liu")

# Confirm subject count
n_liu_short <- dplyr::n_distinct(liu_short_data$subject_id)
message("Liu short-clothing subjects: ", n_liu_short)  # expected ~88

m_ref <- lme4::glmer(
  dissatisfied_with_draft_ankles ~ v_air_m_s + thermal_sensation + (1 | subject_id),
  data    = liu_short_data,
  family  = binomial(link = "logit"),
  control = lme4::glmerControl(optimizer = "bobyqa")
)

message("Reference model fitted. Fixed effects:")
print(lme4::fixef(m_ref))


# 3. Power curve: vary N from 10 to n_liu_short ===============================
#
# simr::powerCurve() subsets to the first K unique levels of `subject_id`
# and re-simulates / refits the model nsim times per break point.
# The test is a likelihood-ratio test for the v_air_m_s fixed effect (α = 0.05).
#
# Using Liu's exposed-ankle effect sizes as the reference is conservative:
# the covered-ankle effect is smaller, so if N = 51 is adequate here it is
# at least as adequate for detecting the smaller covered-ankle effect.

set.seed(42)

# Shuffle subjects so powerCurve subsets are random rather than ordered by ID
shuffled_ids <- sample(unique(liu_short_data$subject_id))
liu_short_shuffled <- liu_short_data %>%
  dplyr::mutate(
    subject_id = factor(subject_id, levels = shuffled_ids)
  ) %>%
  dplyr::arrange(subject_id)

m_ref_shuffled <- lme4::glmer(
  dissatisfied_with_draft_ankles ~ v_air_m_s + thermal_sensation + (1 | subject_id),
  data    = liu_short_shuffled,
  family  = binomial(link = "logit"),
  control = lme4::glmerControl(optimizer = "bobyqa")
)

breaks_n <- c(10, 20, 30, 40, 51, 65, n_liu_short)

pc <- simr::powerCurve(
  fit   = m_ref_shuffled,
  test  = simr::fixed("v_air_m_s"),
  along = "subject_id",
  breaks = breaks_n,
  nsim  = 1000,
  seed  = 42,
  progress = TRUE
)

print(pc)
plot(pc,
     xlab = "Number of participants",
     ylab = "Power (proportion significant, α = 0.05)",
     main = "Simulation-based power: effect of ankle air speed on draft dissatisfaction\n(reference: Liu et al. 2017, exposed-ankle GLMM)")
abline(h = 0.80, lty = 2, col = "grey40")
abline(v = 51,   lty = 3, col = "steelblue")


# 4. Extract key numbers for reporting =========================================

pc_summary <- summary(pc)
print(pc_summary)

# Minimum N achieving >= 80% power
n_80 <- pc_summary[pc_summary$mean >= 0.80, "nlevels"]
n_80_min <- if (length(n_80) > 0) min(n_80) else NA_integer_

# Power and 95% CI at N = 51
row_51 <- pc_summary[pc_summary$nlevels == 51, ]

message(
  "\n--- Power Analysis Summary ---",
  "\nReference effect (Liu 2017 GLMM):",
  "\n  v_air_m_s beta = ", round(lme4::fixef(m_ref)["v_air_m_s"], 3),
  "\n  thermal_sensation beta = ", round(lme4::fixef(m_ref)["thermal_sensation"], 3),
  "\nMinimum N for >= 80% power: ", n_80_min,
  "\nPower at N = 51: ", round(row_51$mean, 3),
  " (95% CI: ", round(row_51$lower, 3), "–", round(row_51$upper, 3), ")"
)

# Save for reproducibility
saveRDS(pc, here::here("manuscript", "tables", "power_curve_liu.rds"))
saveRDS(pc_summary, here::here("manuscript", "tables", "power_curve_summary.rds"))