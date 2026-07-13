# ==============================================================================
# Title: Statistical Functions
# Description: Reusable functions for statistical analysis
# Author: Toby Kramer
# Date: 2026-01-05
# ==============================================================================

source(here::here("src", "R", "x_setup.R"))


# Odds Ratio Extraction ========================================================

#' Extract odds ratio and 95% CI from logistic mixed-effects model
#'
#' @param mod Fitted glmer model object (binomial family)
#' @param term Predictor term name (string)
#' @return Tibble with term, OR, CI_low, CI_high
logistic_or_ci <- function(mod, term) {
  b <- fixef(mod)[term]
  se <- sqrt(vcov(mod)[term, term])

  tibble(
    term = term,
    OR = exp(b),
    CI_low = exp(b - 1.96 * se),
    CI_high = exp(b + 1.96 * se)
  )
}


# Pairwise Table Formatting ===================================================

#' Format pairwise comparison results for manuscript tables
#'
#' Converts internal variable names such as `session_sat`, `workstation`,
#' `group1`, and `group2` into reader-facing columns.
#'
#' @param stats A paired-comparison result table containing `comparison`,
#'   `group1`, and `group2`, with optional `session_sat` and `workstation`.
#' @return A tibble with manuscript-facing comparison columns first.
format_pairwise_stats_table <- function(stats) {
  n_rows <- nrow(stats)
  
  comparison_raw <- if ("comparison" %in% names(stats)) {
    as.character(stats$comparison)
  } else {
    rep(NA_character_, n_rows)
  }
  
  session_sat <- if ("session_sat" %in% names(stats)) {
    as.character(stats$session_sat)
  } else {
    rep(NA_character_, n_rows)
  }
  
  workstation <- if ("workstation" %in% names(stats)) {
    as.character(stats$workstation)
  } else {
    rep(NA_character_, n_rows)
  }
  
  group1 <- if ("group1" %in% names(stats)) {
    as.character(stats$group1)
  } else {
    rep(NA_character_, n_rows)
  }
  
  group2 <- if ("group2" %in% names(stats)) {
    as.character(stats$group2)
  } else {
    rep(NA_character_, n_rows)
  }
  
  format_air_speed_condition <- function(x) {
    x_chr <- as.character(x)
    x_lower <- tolower(x_chr)
    
    dplyr::case_when(
      is.na(x_chr) ~ NA_character_,
      x_lower == "low" ~ "Low air speed",
      x_lower %in% c("med", "medium") ~ "Medium air speed",
      x_lower == "high" ~ "High air speed",
      TRUE ~ x_chr
    )
  }
  
  comparison_label <- dplyr::case_when(
    comparison_raw == "Air speed within ankle temperature" ~ "Air speed",
    comparison_raw == "Ankle temperature within air speed" ~ "Ankle temperature",
    TRUE ~ comparison_raw
  )
  
  condition_label <- dplyr::case_when(
    comparison_raw == "Air speed within ankle temperature" ~ session_sat,
    comparison_raw == "Ankle temperature within air speed" ~
      format_air_speed_condition(workstation),
    TRUE ~ NA_character_
  )
  
  keep_cols <- setdiff(
    names(stats),
    c("comparison", "session_sat", "workstation", "group1", "group2")
  )
  
  dplyr::bind_cols(
    tibble::tibble(
      Comparison = comparison_label,
      Condition = condition_label,
      `Pairwise comparison` = paste(group1, "vs.", group2)
    ),
    stats[keep_cols]
  )
}


# Paired Comparisons ===========================================================

#' Pairwise paired t-tests with BH adjustment. Computes Cohen's d effect sizes.
#'
#' @param data Long-format data frame containing survey observations
#' @param group_by_var Higher-level grouping variable
#' @param within_var Optional additional grouping variable for nested grouping (default: NULL)
#' @param subject_var Subject identifier for pairing observations.
#' @param question_var Variable defining the within-subject conditions to be compared
#' @param value_var Numeric outcome variable to be compared
#' @param order_var Optional ordering variable used to determine the first observation (for double check)
#' @return A tibble containing pairwise paired t-test results
paired_t_test <- function(data,
                          group_by_var,
                          within_var = NULL,
                          subject_var,
                          question_var,
                          value_var,
                          order_var = NULL) {
  
  group_vars <- unique(Filter(Negate(is.null), c(group_by_var, within_var)))
  
  data %>%
    dplyr::group_by(dplyr::across(all_of(group_vars))) %>%
    dplyr::group_modify(~{
      
      dat_long <- .x
      
      if (!is.null(order_var)) {
        dat_long <- dat_long %>%
          dplyr::arrange(
            dplyr::across(all_of(c(subject_var, question_var, order_var)))
          )
      }
      
      dat <- dat_long %>%
        dplyr::group_by(dplyr::across(all_of(c(subject_var, question_var)))) %>%
        dplyr::summarise(
          value = dplyr::first(.data[[value_var]]),
          .groups = "drop"
        ) %>%
        tidyr::pivot_wider(
          names_from = all_of(question_var),
          values_from = value
        )
      
      grp_names <- setdiff(names(dat), subject_var)
      
      if (length(grp_names) < 2) {
        return(tibble::tibble(
          group1 = NA_character_,
          group2 = NA_character_,
          n = NA_integer_,
          mean1 = NA_real_,
          mean2 = NA_real_,
          statistic = NA_real_,
          df = NA_real_,
          p = NA_real_,
          cohen_d = NA_real_
        ))
      }
      
      combs <- combn(grp_names, 2, simplify = FALSE)
      
      purrr::map_dfr(combs, function(pair){
        
        g1 <- as.character(pair[1])
        g2 <- as.character(pair[2])
        
        paired_dat <- dat %>%
          dplyr::select(all_of(c(subject_var, g1, g2))) %>%
          tidyr::drop_na(all_of(c(g1, g2)))
        
        if (nrow(paired_dat) < 2) {
          return(tibble::tibble(
            group1 = g1,
            group2 = g2,
            n = nrow(paired_dat),
            mean1 = mean(paired_dat[[g1]], na.rm = TRUE),
            mean2 = mean(paired_dat[[g2]], na.rm = TRUE),
            statistic = NA_real_,
            df = NA_real_,
            p = NA_real_,
            cohen_d = NA_real_
          ))
        }
        
        tt <- stats::t.test(paired_dat[[g1]], paired_dat[[g2]], paired = TRUE)
        
        diff_val <- paired_dat[[g1]] - paired_dat[[g2]]
        sd_diff <- stats::sd(diff_val, na.rm = TRUE)
        
        d_val <- if (is.na(sd_diff) || sd_diff == 0) {
          NA_real_
        } else {
          mean(diff_val, na.rm = TRUE) / sd_diff
        }
        
        tibble::tibble(
          group1 = g1,
          group2 = g2,
          n = nrow(paired_dat),
          mean1 = mean(paired_dat[[g1]], na.rm = TRUE),
          mean2 = mean(paired_dat[[g2]], na.rm = TRUE),
          statistic = unname(tt$statistic),
          df = unname(tt$parameter),
          p = tt$p.value,
          cohen_d = d_val
        )
      })
      
    }) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(dplyr::across(all_of(group_by_var))) %>%
    dplyr::mutate(
      p.adj = stats::p.adjust(p, method = "BH")
    ) %>%
    dplyr::ungroup()
}


#' paired Wilcoxon test for ordinal variables
#' Performs pairwise Wilcoxon signed-rank tests with BH adjustment. Computes effect size r.
#'
#' @param data Long-format data frame containing survey observations
#' @param group_by_var Higher-level grouping variable
#' @param within_var Optional additional grouping variable for nested grouping (default: NULL)
#' @param subject_var Subject identifier for pairing observations.
#' @param question_var Variable defining the within-subject conditions to be compared
#' @param value_var Numeric outcome variable to be compared
#' @param order_var Optional ordering variable used to determine the first observation (for double check)
#' @return A tibble containing pairwise paired t-test results
paired_wilcox_test <- function(data,
                               group_by_var,
                               within_var = NULL,
                               subject_var,
                               question_var,
                               value_var,
                               order_var = NULL) {

  # Ordinal questionnaire responses are tested on their intended integer
  # scale. Unlike base::round(), this treats x.5 as away from zero.
  round_half_away_from_zero <- function(x) {
    sign(x) * floor(abs(x) + 0.5)
  }
  
  group_vars <- unique(Filter(Negate(is.null), c(group_by_var, within_var)))
  
  data %>%
    dplyr::group_by(dplyr::across(all_of(group_vars))) %>%
    dplyr::group_modify(~{
      
      dat_long <- .x
      
      if (!is.null(order_var)) {
        dat_long <- dat_long %>%
          dplyr::arrange(
            dplyr::across(all_of(c(subject_var, question_var, order_var)))
          )
      }
      
      dat <- dat_long %>%
        dplyr::group_by(dplyr::across(all_of(c(subject_var, question_var)))) %>%
        dplyr::summarise(
          value = round_half_away_from_zero(
            dplyr::first(.data[[value_var]])
          ),
          .groups = "drop"
        ) %>%
        tidyr::pivot_wider(
          names_from = all_of(question_var),
          values_from = value
        )
      
      grp_names <- setdiff(names(dat), subject_var)
      
      if (length(grp_names) < 2) {
        return(tibble::tibble(
          group1 = NA_character_,
          group2 = NA_character_,
          n = NA_integer_,
          mean1 = NA_real_,
          mean2 = NA_real_,
          median1 = NA_real_,
          median2 = NA_real_,
          statistic = NA_real_,
          p = NA_real_,
          r = NA_real_
        ))
      }
      
      combs <- combn(grp_names, 2, simplify = FALSE)
      
      purrr::map_dfr(combs, function(pair) {
        
        g1 <- as.character(pair[1])
        g2 <- as.character(pair[2])
        
        paired_dat <- dat %>%
          dplyr::select(all_of(c(subject_var, g1, g2))) %>%
          tidyr::drop_na(all_of(c(g1, g2)))
        
        if (nrow(paired_dat) < 2) {
          return(tibble::tibble(
            group1 = g1,
            group2 = g2,
            n = nrow(paired_dat),
            mean1 = mean(paired_dat[[g1]], na.rm = TRUE),
            mean2 = mean(paired_dat[[g2]], na.rm = TRUE),
            median1 = stats::median(paired_dat[[g1]], na.rm = TRUE),
            median2 = stats::median(paired_dat[[g2]], na.rm = TRUE),
            statistic = NA_real_,
            p = NA_real_,
            r = NA_real_
          ))
        }
        
        long_dat <- paired_dat %>%
          tidyr::pivot_longer(
            cols = all_of(c(g1, g2)),
            names_to = "group",
            values_to = "value"
          ) %>%
          dplyr::mutate(
            group = factor(group, levels = c(g1, g2))
          )
        
        wt <- stats::wilcox.test(
          paired_dat[[g1]],
          paired_dat[[g2]],
          paired = TRUE,
          exact = FALSE
        )
        
        eff <- tryCatch(
          rstatix::wilcox_effsize(
            data = long_dat,
            value ~ group,
            paired = TRUE
          ),
          error = function(e) NULL
        )
        
        tibble::tibble(
          group1 = g1,
          group2 = g2,
          n = nrow(paired_dat),
          mean1 = mean(paired_dat[[g1]], na.rm = TRUE),
          mean2 = mean(paired_dat[[g2]], na.rm = TRUE),
          median1 = stats::median(paired_dat[[g1]], na.rm = TRUE),
          median2 = stats::median(paired_dat[[g2]], na.rm = TRUE),
          statistic = unname(wt$statistic),
          p = wt$p.value,
          r = if (is.null(eff)) NA_real_ else eff$effsize[1]
        )
      })
      
    }) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(dplyr::across(all_of(group_by_var))) %>%
    dplyr::mutate(
      p.adj = stats::p.adjust(p, method = "BH")
    ) %>%
    dplyr::ungroup()
}
