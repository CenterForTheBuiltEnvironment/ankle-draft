# ==============================================================================
# Title: Reviewer Figures — Scatter + LM
# Description: Alternative visualisations requested by reviewer: raw ordinal
#              votes plotted against actual ankle temperature (t_supply_c) and
#              measured ankle air speed (v_air_m_s), with linear regression.
#              Saves to manuscript/figs/ with rv_ prefix. Does NOT touch or
#              overwrite any original figures.
# Author: Toby Kramer
# Date: 2026-05-18
# ==============================================================================

source(here::here("src", "R", "x_setup.R"))
source(here::here("src", "R", "x_func.R"))
source(here::here("src", "R", "x_data.R"))


# Additional colour palette for supply-air-temperature sessions ================

session_sat_palette <- c(
  "15C" = "#82c6ed",  # light blue – cool condition
  "17C" = "#c9e0b0",  # pale green – neutral condition
  "19C" = "#eb6b58"   # coral     – warm condition
)

# Visual gap inserted between the unacceptable/acceptable halves of the
# acceptability scale (mirrors the approach in the original acceptability plot)
vertical_gap <- 0.2


# Helpers ======================================================================

# Generic scatter + LM panel ---------------------------------------------------
# Switch method = "lm" to "loess" (+ span argument) if a smoothed fit is preferred.

plot_scatter_lm <- function(data, x_var, y_var, color_var, palette,
                            x_label, y_label, y_breaks, y_labels,
                            color_title, subtitle) {
  ggplot(data, aes(x = .data[[x_var]], y = .data[[y_var]],
                   color = .data[[color_var]])) +
    geom_jitter(alpha = 0.35, size = 0.8, width = 0.05, height = 0.1) +
    geom_smooth(
      aes(fill = .data[[color_var]]),
      method    = "lm",
      formula   = y ~ x,
      se        = TRUE,
      alpha     = 0.15,
      linewidth = 0.7
    ) +
    scale_color_manual(values = palette, name = color_title) +
    scale_fill_manual(values = palette, guide = "none") +
    scale_y_continuous(breaks = y_breaks, labels = y_labels) +
    labs(x = x_label, y = y_label, subtitle = subtitle) +
    theme_minimal(base_size = 7) +
    theme(
      panel.grid.major  = element_blank(),
      panel.grid.minor  = element_blank(),
      axis.ticks.y      = element_line(color = "grey", linewidth = 0.25),
      axis.ticks.x      = element_line(color = "grey", linewidth = 0.25),
      axis.ticks.length = unit(1, "mm"),
      axis.title.x      = element_text(margin = margin(t = 6)),
      legend.title      = element_text(size = 6),
      legend.key.size   = unit(3, "mm")
    )
}

# Acceptability scatter + LM panel ---------------------------------------------
# Mirrors the original acceptability plot: positive response_plot values are
# shifted up by vertical_gap so a visible gap appears around zero. Background
# rectangles and boundary lines are drawn *before* the data points so they sit
# behind the scatter.

plot_acc_scatter <- function(data, x_var, color_var, palette,
                             x_label, y_label, color_title, subtitle) {
  ggplot(data, aes(x = .data[[x_var]], y = response_plot,
                   color = .data[[color_var]])) +
    # --- background regions (drawn first, behind points) ---
    annotate("rect",
             xmin = -Inf, xmax = Inf,
             ymin = 0.1 + vertical_gap, ymax = Inf,
             fill = "#c1e0b9", alpha = 0.2) +
    annotate("rect",
             xmin = -Inf, xmax = Inf,
             ymin = -Inf, ymax = -0.1,
             fill = "#d99fa8", alpha = 0.2) +
    annotate("rect",
             xmin = -Inf, xmax = Inf,
             ymin = -0.1, ymax = 0.1 + vertical_gap,
             fill = "white") +
    geom_hline(yintercept =  0.1 + vertical_gap,
               linetype = "dashed", color = "grey50", linewidth = 0.3) +
    geom_hline(yintercept = -0.1,
               linetype = "dashed", color = "grey50", linewidth = 0.3) +
    # --- data layers (on top of background) ---
    geom_jitter(alpha = 0.35, size = 0.8, width = 0.05, height = 0.1) +
    geom_smooth(
      aes(fill = .data[[color_var]]),
      method    = "lm",
      formula   = y ~ x,
      se        = TRUE,
      alpha     = 0.15,
      linewidth = 0.7
    ) +
    scale_color_manual(values = palette, name = color_title) +
    scale_fill_manual(values = palette, guide = "none") +
    scale_y_continuous(
      breaks = c(-2, -1, -0.1,
                 0.1 + vertical_gap, 1 + vertical_gap, 2 + vertical_gap),
      labels = c("Clearly\nunacc.", "", "Just\nunacc.",
                 "Just\nacc.", "", "Clearly\nacc.")
    ) +
    labs(x = x_label, y = y_label, subtitle = subtitle) +
    theme_minimal(base_size = 7) +
    theme(
      panel.grid.major  = element_blank(),
      panel.grid.minor  = element_blank(),
      axis.ticks.y      = element_line(color = "grey", linewidth = 0.25),
      axis.ticks.x      = element_line(color = "grey", linewidth = 0.25),
      axis.ticks.length = unit(1, "mm"),
      axis.title.x      = element_text(margin = margin(t = 6)),
      legend.title      = element_text(size = 6),
      legend.key.size   = unit(3, "mm")
    )
}

# Shared patchwork annotation --------------------------------------------------

patchwork_theme <- list(
  plot_annotation(tag_levels = "a", tag_suffix = "."),
  theme(
    plot.subtitle = element_text(hjust = 0.05, margin = margin(b = 3, unit = "mm")),
    plot.tag      = element_text(size = 7, face = "bold"),
    plot.margin   = margin(b = 5, unit = "mm"),
    axis.title    = element_text(margin = margin(r = 2, unit = "mm")),
    legend.margin = margin(l = 3, unit = "mm")
  )
)


# Data preparation =============================================================

prep_d <- function(q_name) {
  analysis %>%
    dplyr::filter(question == q_name, is_open_text == FALSE,
                  workstation != "adaptation") %>%
    dplyr::mutate(response_value_num = as.numeric(response_value)) %>%
    tidyr::drop_na(response_value_num, v_air_m_s, t_supply_c)
}

ts_overall <- prep_d("thermal_sensation")
tp_overall <- prep_d("thermal_preference")
ts_ankles  <- prep_d("thermal_sensation_ankles")
tp_ankles  <- prep_d("thermal_preference_ankles")
am_pref    <- prep_d("air_movement_preference_ankles")

# Acceptability data: add response_plot (positive values shifted up by
# vertical_gap to create the visual gap, matching the original plot)
ta_overall <- prep_d("thermal_acceptability") %>%
  dplyr::mutate(
    response_plot = ifelse(response_value_num > 0,
                           response_value_num + vertical_gap,
                           response_value_num)
  )

am_acc <- prep_d("air_movement_acceptability_ankles") %>%
  dplyr::mutate(
    response_plot = ifelse(response_value_num > 0,
                           response_value_num + vertical_gap,
                           response_value_num)
  )


# Y-axis scale definitions =====================================================

y_sensation <- list(
  breaks = seq(-3, 3, 1),
  labels = c("Cold", "Cool", "Sl. cool", "Neutral", "Sl. warm", "Warm", "Hot")
)

y_preference <- list(
  breaks = c(-1, 0, 1),
  labels = c("Cooler", "No change", "Warmer")
)

y_am_pref <- list(
  breaks = c(-1, 0, 1),
  labels = c("Less", "No change", "More")
)


# ==============================================================================
# Figure 1 — Thermal perception overall (sensation + preference)
# ==============================================================================

p_ts_temp <- plot_scatter_lm(
  ts_overall, "t_supply_c", "response_value_num", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Thermal sensation vote",
  y_breaks    = y_sensation$breaks,
  y_labels    = y_sensation$labels,
  color_title = "Air speed",
  subtitle    = "Thermal sensation, whole body"
)

p_ts_speed <- plot_scatter_lm(
  ts_overall, "v_air_m_s", "response_value_num", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Thermal sensation vote",
  y_breaks    = y_sensation$breaks,
  y_labels    = y_sensation$labels,
  color_title = "Supply temp.",
  subtitle    = "Thermal sensation, whole body"
)

p_tp_temp <- plot_scatter_lm(
  tp_overall, "t_supply_c", "response_value_num", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Thermal preference",
  y_breaks    = y_preference$breaks,
  y_labels    = y_preference$labels,
  color_title = "Air speed",
  subtitle    = "Thermal preference, whole body"
)

p_tp_speed <- plot_scatter_lm(
  tp_overall, "v_air_m_s", "response_value_num", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Thermal preference",
  y_breaks    = y_preference$breaks,
  y_labels    = y_preference$labels,
  color_title = "Supply temp.",
  subtitle    = "Thermal preference, whole body"
)

thermal_perception_overall_rv_p <-
  (p_ts_temp | p_ts_speed) / (p_tp_temp | p_tp_speed) +
  plot_layout(guides = "collect") +
  patchwork_theme[[1]] &
  patchwork_theme[[2]]

ggsave(
  here::here("manuscript", "figs", "rv_thermal_perception_overall.png"),
  plot   = thermal_perception_overall_rv_p,
  dpi    = 500,
  width  = double_col_width,
  height = 160,
  units  = "mm",
  bg     = "transparent"
)


# ==============================================================================
# Figure 2 — Thermal acceptability overall
# ==============================================================================

p_ta_temp <- plot_acc_scatter(
  ta_overall, "t_supply_c", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Thermal acceptability",
  color_title = "Air speed",
  subtitle    = "Thermal acceptability, whole body"
)

p_ta_speed <- plot_acc_scatter(
  ta_overall, "v_air_m_s", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Thermal acceptability",
  color_title = "Supply temp.",
  subtitle    = "Thermal acceptability, whole body"
)

thermal_acceptability_overall_rv_p <-
  (p_ta_temp | p_ta_speed) +
  plot_layout(guides = "collect") +
  patchwork_theme[[1]] &
  patchwork_theme[[2]]

ggsave(
  here::here("manuscript", "figs", "rv_thermal_acceptability_overall.png"),
  plot   = thermal_acceptability_overall_rv_p,
  dpi    = 500,
  width  = double_col_width,
  height = 80,
  units  = "mm",
  bg     = "transparent"
)


# ==============================================================================
# Figure 3 — Thermal perception ankles (sensation + preference)
# ==============================================================================

p_tsa_temp <- plot_scatter_lm(
  ts_ankles, "t_supply_c", "response_value_num", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Thermal sensation vote",
  y_breaks    = y_sensation$breaks,
  y_labels    = y_sensation$labels,
  color_title = "Air speed",
  subtitle    = "Thermal sensation, ankles"
)

p_tsa_speed <- plot_scatter_lm(
  ts_ankles, "v_air_m_s", "response_value_num", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Thermal sensation vote",
  y_breaks    = y_sensation$breaks,
  y_labels    = y_sensation$labels,
  color_title = "Supply temp.",
  subtitle    = "Thermal sensation, ankles"
)

p_tpa_temp <- plot_scatter_lm(
  tp_ankles, "t_supply_c", "response_value_num", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Thermal preference",
  y_breaks    = y_preference$breaks,
  y_labels    = y_preference$labels,
  color_title = "Air speed",
  subtitle    = "Thermal preference, ankles"
)

p_tpa_speed <- plot_scatter_lm(
  tp_ankles, "v_air_m_s", "response_value_num", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Thermal preference",
  y_breaks    = y_preference$breaks,
  y_labels    = y_preference$labels,
  color_title = "Supply temp.",
  subtitle    = "Thermal preference, ankles"
)

thermal_perception_ankle_rv_p <-
  (p_tsa_temp | p_tsa_speed) / (p_tpa_temp | p_tpa_speed) +
  plot_layout(guides = "collect") +
  patchwork_theme[[1]] &
  patchwork_theme[[2]]

ggsave(
  here::here("manuscript", "figs", "rv_thermal_perception_ankle.png"),
  plot   = thermal_perception_ankle_rv_p,
  dpi    = 500,
  width  = double_col_width,
  height = 160,
  units  = "mm",
  bg     = "transparent"
)


# ==============================================================================
# Figure 4 — Air movement acceptability + preference (ankles)
# ==============================================================================

p_ama_temp <- plot_acc_scatter(
  am_acc, "t_supply_c", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Air movement acceptability",
  color_title = "Air speed",
  subtitle    = "Air movement acceptability, ankles"
)

p_ama_speed <- plot_acc_scatter(
  am_acc, "v_air_m_s", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Air movement acceptability",
  color_title = "Supply temp.",
  subtitle    = "Air movement acceptability, ankles"
)

p_amp_temp <- plot_scatter_lm(
  am_pref, "t_supply_c", "response_value_num", "workstation",
  workstation_palette,
  x_label     = "Ankle air temperature (°C)",
  y_label     = "Air movement preference",
  y_breaks    = y_am_pref$breaks,
  y_labels    = y_am_pref$labels,
  color_title = "Air speed",
  subtitle    = "Air movement preference, ankles"
)

p_amp_speed <- plot_scatter_lm(
  am_pref, "v_air_m_s", "response_value_num", "session_sat",
  session_sat_palette,
  x_label     = "Ankle air speed (m/s)",
  y_label     = "Air movement preference",
  y_breaks    = y_am_pref$breaks,
  y_labels    = y_am_pref$labels,
  color_title = "Supply temp.",
  subtitle    = "Air movement preference, ankles"
)

air_movement_rv_p <-
  (p_ama_temp | p_ama_speed) / (p_amp_temp | p_amp_speed) +
  plot_layout(guides = "collect") +
  patchwork_theme[[1]] &
  patchwork_theme[[2]]

ggsave(
  here::here("manuscript", "figs", "rv_air_movement_acc_pref.png"),
  plot   = air_movement_rv_p,
  dpi    = 500,
  width  = double_col_width,
  height = 160,
  units  = "mm",
  bg     = "transparent"
)
