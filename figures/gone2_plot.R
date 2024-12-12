source("figures/theme.R")

data_dir <- "analysis/GONE2/results/"
gone_files <- list.files(data_dir, pattern = "*_GONE2_Ne", full.names = TRUE)
names(gone_files) <- basename(gone_files)

# Read in the data
data <- gone_files |>
  map(read_tsv, show_col_types=FALSE) |>
  bind_rows(.id = "File") |>
  # Extract chromosome and species
  # Example: Telmatherina_opudi_Chr1_GO
  # Species: Telmatherina_opudi, Chromosome: Chr1
  mutate(Species = str_extract(File, "^[^_]+_[^_]+")) |>
  mutate(Chromosome = str_extract(File, "Chr\\d+")) |>
  filter(Generation > 100) |>
  mutate(Generation = 2002-data$Generation)


# We are going to resample chromosomes and compute a bootstrap CI
chroms <- unique(data$Chromosome)
bootstrap <- function(data, seed){
  set.seed(seed = seed)
  sampled <- sample(chroms, replace = TRUE)
  map(sampled, ~filter(data, Chromosome == .x)) |> 
    bind_rows() |>
    group_by(Generation, Species) |>
    summarize(
      Ne_diploids = exp(mean(log(Ne_diploids))),
      .groups = "drop"
    )
}

# Find bootstrapped sd and mean
boot_data <- 1000:1100 |>
  map(\(seed) bootstrap(data, seed)) |>
  bind_rows() |>
  group_by(Generation, Species) |>
  summarise(
    sd = sd(Ne_diploids), 
    minconf = quantile(Ne_diploids, 0.025),
    maxconf = quantile(Ne_diploids, 0.975),
    .groups = "drop"
    )



data |>
  group_by(Species, Generation) |>
  summarise(
    mean = exp(mean(log(Ne_diploids))),
    min = min(Ne_diploids),
    max = max(Ne_diploids),
  ) |>
  left_join(boot_data) |>
  ggplot(aes(x = Generation, fill = Species, color = Species))+
  geom_ribbon(
    aes(ymin = min, ymax = max),
    alpha = 0., linetype = 2, linewidth = 3,
  ) +
  geom_line(aes(y = mean), linewidth = 2.5) +
  geom_ribbon(
    aes(ymin = minconf, ymax = maxconf, group = Species),
    alpha = 0.3, linetype = 0,
  )+
  theme_minimal()+
  theme(
    legend.position = "bottom",
    text = element_text(size = 24, family = "STIX Two Text"),
    legend.text = element_markdown(size = 24, family = "STIX Two Text"),
    axis.title.x = element_text(size = 24, family = "STIX Two Text"),
    axis.title.y = element_text(size = 24, family = "STIX Two Text"),
    legend.key = element_rect(fill = NA, colour = NA),  # Transparent box around key
  ) +
  scale_fill_manual(
    name = "",
    values = c(
      "Telmatherina_opudi" = opudi_color,
      "Telmatherina_sarasinorum" =sara_color
    ),
    labels = c(
      "Telmatherina_opudi" = "*Telmatherina opudi*",
      "Telmatherina_sarasinorum" = "*Telmatherina sarasinorum*"
    )
  )+
  scale_color_manual(
    name = "",
    values = c(
      "Telmatherina_opudi" = opudi_color,
      "Telmatherina_sarasinorum" =sara_color
    ),
    labels = c(
      "Telmatherina_opudi" = "*Telmatherina opudi*",
      "Telmatherina_sarasinorum" = "*Telmatherina sarasinorum*"
    )
  )+
  guides(color = guide_legend(override.aes = list(alpha = 1, linetype = 0, shape = NA))) +
  ylab("Effective population size")+
  xlab("Year")+
  scale_y_log10(
    labels = scales::label_number_auto()
  )+
  scale_x_reverse(expand = c(0, 0))
  ggtitle(
    label = "Recent effective population size estimates using GONE2",
    subtitle = "Inferred from the spectrum of linkage disequilibrium and averaged across all chromosomes"
  )


ggsave(
  "figures/gone.svg",
  width = 380,
  height = 380/(4/3),
  #device = cairo_pdf,
  units = "mm",
  dpi = "retina"
)






