source("figures/theme.R")

# TO-DO: This file is the product of the "estimate command" 
data <- read_csv("analysis/smc++/results/scm++_estimate.csv")
data |>
  rename(
    Species = label,
    Ne = y,
    Time = x
  ) |>
  # Santiago et al. [15] showed that, for relatively recent timespans of about
  # 200 generations back in time, MSMC [70] and Relate [71] are generally unable to detect changes in population size.
  mutate(
    Time = if_else(Time == 0, 200, Time),
    Species = str_replace(Species, "_", " ")
    ) |>
  ggplot(aes(x = Time/1000, y = Ne, fill = Species, color = Species))+
  geom_line(linewidth = 2)+
  scale_color_manual(
    name = "", values = c(
      "Telmatherina opudi" = opudi_color,
      "Telmatherina sarasinorum" =sara_color
    ),
    labels = c(
      "Telmatherina opudi" = "*Telmatherina opudi*",
      "Telmatherina sarasinorum" = "*Telmatherina sarasinorum*"
    )
  )+
  theme_minimal()+
  theme(
    legend.position = "bottom",
    text = element_text(size = 24, family = "STIX Two Text"),
    legend.text = element_markdown(size = 24, family = "STIX Two Text"),
    axis.title.x = element_text(size = 24, family = "STIX Two Text"),
    axis.title.y = element_text(size = 24, family = "STIX Two Text"),

  ) +
  ylab("Effective population size")+
  xlab("Years ago (in thousands)")+
  guides(color = guide_legend(override.aes = list(shape = NA))) +
  scale_y_log10(
    labels = scales::label_number_auto()
  )
  ggtitle(
    label = "Historical changes in effective population sizes",
    subtitle = expression("Estimated with SMC++ across all chromosomes (" ~ mu ~ "= 3.5×10"^{-9} ~ ", generation time = 1 year)")
  )


ggsave(
  "figures/smc++.svg",
  width = 380,
  height = 380/(4/3),
  #device = cairo_pdf,
  units = "mm",
  dpi = "retina"
)