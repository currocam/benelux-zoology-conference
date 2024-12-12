source("figures/theme.R")

infiles <- list.files(
  "analysis/ringbauer/results/", pattern = "ringbauer_*", 
  full.names = TRUE
)
names(infiles) <- list.files("analysis/ringbauer/results/", pattern = "ringbauer_*") |> 
  basename() |> 
  str_remove(".csv") |>
  str_remove("ringbauer_") |>
  str_replace_all("_", " ")
data <- map(infiles, read_csv) |> bind_rows(.id = "Species")

# Sample 10_000 sigmas of each species and compute the difference
data |>
  group_by(Chromosome) |>
  summarise(
    diff = list(sample(
      sigma[Species == "Telmatherina opudi"], 100
    ) - sample(
      sigma[Species == "Telmatherina sarasinorum"], 100
    )),
    min.conf = quantile(diff[[1]], 0.025),
    max.conf = quantile(diff[[1]], 0.975)
  )
opudi_s <- sample(data$sigma[data$Species == "Telmatherina opudi"], 10000)
sara_s <- sample(data$sigma[data$Species == "Telmatherina sarasinorum"], 10000)

print(HDInterval::hdi(opudi_s - sara_s))R


data <-data |>
  group_by(Species, Chromosome) |>
  sample_n(100) |>
  ungroup() 

data |>
  # Sort the Chromosome factor by the number
  # extract Chr{d} and convert to integer
  mutate(
    Chromosome = str_extract(Chromosome, "\\d+") |> 
      as.integer() |>
      as.factor() |>
      fct_reorder(Chromosome, .desc = TRUE) |>
      # Add Labels to the Chromosome factor
      fct_relabel(~str_c("Chr", .))
    ) |>
  ggplot(aes(x = sigma, y = Chromosome, fill = Species)) +
  geom_density_ridges(alpha=0.8, scale = 4, linewidth = 1) + 
  scale_y_discrete(expand = c(0, 0)) +     # will generally have to set the `expand` option
  scale_x_continuous(expand = c(0, 0)) +   # for both axes to remove unneeded padding
  coord_cartesian(clip = "off") + # to avoid clipping of the very top of the top ridgeline
  theme_ridges()+
  ylab("")+
  xlab("Mean effective dispersal distance (km)")+
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
    name = "", values = c(
      "Telmatherina opudi" = opudi_color,
      "Telmatherina sarasinorum" = sara_color
    ),
    labels = c(
      "Telmatherina opudi" = "*Telmatherina opudi*",
      "Telmatherina sarasinorum" = "*Telmatherina sarasinorum*"
    )
  )+
  guides(color = guide_legend(override.aes = list(alpha = 1, linetype = 0, shape = NA)))
  #ggtitle(
  #  label = "Posterior distribution of effective dispersal rate",
  #  subtitle = "Estimated from shared identity-by-descent blocks using a composite likelihood Bayesian approach"
  #)

# Save figure ensuring 360mm wide and a 4:3 aspect ratio
ggsave(
  "figures/dispersal.svg",
  width = 380,
  #device = cairo_pdf,
  height = 380/(4/3),
  units = "mm",
  dpi = "retina"
)