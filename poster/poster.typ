// Set the page size to A0 (841mm x 1189mm)
#set text(font: "STIX Two Text")
#set page(
  paper: "a0",
  margin: 48mm,
    footer: [
      #set align(center)
      #set text(32pt)
      #set text(rgb("#ffffff"))
      // Bold text
      #block(
        fill: rgb("006ca9ff"),
        width: 100%,
        inset: 20pt,
        radius: 15pt,
        [
          #text(size: 26pt, weight: "semibold", "https://currocam.github.io/") 
          #h(1fr) 
          #text(size: 32pt, weight: "semibold", smallcaps("Benelux Zoology Congress 2024")) 
          #h(1fr) 
          #text(size: 26pt, weight: "semibold", "12-12-2024")
        ]
      )
    ]
  )

// Set big font size for title and center
#set text(size: 48pt)
#set align(center)
= Reconstructing the demographic history of the adaptive radiation of silversides in Lake Matano 
#set text(size: 22pt)
#set align(center)
#grid(
  columns: (1fr, 1fr, 1fr),
  align(center)[
 Curro Campuzano Jiménez \
 Department of Biology, University of Antwerp \
    #link("mailto:curro.campuzanojimenez@uantwerpen.be")
  ],
  align(center)[
 Els De Keyzer \
 Department of Biology, University of Antwerp \
    #link("mailto:els.dekeyzer@uantwerpen.be")
  ],
  align(center)[
 Hannes Svardal \
 Department of Biology, University of Antwerp \
    #link("hannes.svardal@uantwerpen.be")
  ]
)
#linebreak()
//#line(length: 90%)
// Set up two columns
#columns(
  2,
  [
    #set text(size: 34pt)
    #set align(center)
    = Introduction
    
    #line(length: 100%)
    #set align(left)
    #set text(size: 24pt)
    
    Our study focuses on modeling key demographic parameters of two closely related species, _Telmatherina opudi_ and _Telmatherina sarasinorum_. Despite their classification and occupying different feeding niches, evidence of high ongoing gene flow raises questions about their speciation status. 
    In this preliminary work, we attempted to reconstruct their evolutionary history from different perspectives and timescales using whole-genome sequencing data.
 
    

    #figure(image("figures/intro.svg", width: 75%), caption : "Overview of the study system.")
    #set align(center)
    #set text(size: 34pt)
    = Results
    #set text(size: 24pt)
    #line(length: 100%)
    #set align(left)
        
    == Historical changes in effective population sizes

    First, we used a sequentially Markov coalescent approach to infer the historical changes in effective population size. 

    #figure(
      image("figures/smc++.svg", width: 80%),
      caption: [
        #set text(size: 20pt)
        Effective population size estimated with SMC++ across all chromosomes. We assumed a mutation rate of $3.5 times 10^(-9)$ and a generation time of one year.
        #set text(size: 24pt)
        ]
    )

    - We observed a large effective population size after a large expansion 25 thousand years ago.
    - _T. opudi_ and _T. sarasinorum_ showed highly similar demographic histories, which would be compatible with a low degree of separation between species.
    
    == Recent effective population size estimates    

    The SMC++ analysis provides a broad evolutionary perspective. However, it is not informative about the recent past. We analyzed the observed linkage disequilibrium using GONE2 to infer the effective population size in the last 100-200 generations.
    #figure(
      image("figures/gone.svg", width: 80%),
      caption: [
        #set text(size: 20pt)
        Recent effective population size inferred using GONE2 and averaged across all chromosomes. We used the recombination rate estimated from SMC++ and assumed a generation time of 1 year. Continuous lines represent the geometric mean. The 95% bootstrap confidence intervals are shown as shaded areas. The dashed lines show the maximum and minimum values of all chromosomes.
        #set text(size: 24pt)
        ]
    )    
    
    - We observed a slight decline in effective population size at the end of the 19th century. As before, _T. opudi_ and _T. sarasinorum_ showed similar identical demographic histories.
    - Notably, the estimate is orders of magnitude lower than the historical effective population size, suggesting recent demographic changes.

    == Posterior distribution of the mean effective dispersal rate#super("1")    
    Population genetic analysis is often based on a notion of discrete demes, rather than spatial continuum. Here, we acknowledge it and estimate the effective dispersal rate from shared identity-by-descent blocks#super("2"). We used a novel Bayesian inference approach based on the composite likelihood derived by Ringbauer, Coop and Barton (2017) to jointly estimate the effective density and dispersal rate.
    #figure(
      image("figures/dispersal.svg", width: 100%),
      caption: [
        #set text(size: 20pt)
        Estimated from shared identity-by-descent blocks using a composite likelihood Bayesian approach. We set a uniform prior to the dispersal of $U(0, 40)$ km. We jointly estimated the effective density (not shown).
        #set text(size: 24pt)
        ]
    )
    
    - Based on specific forward-in-time simulations, we determined that we could accurately estimate the dispersal rate. 
    - We observed a lower dispersal rate in the specialist _T. sarasinorum_ than in the generalist _T. opudi_. (95% HPD absolute difference: 0.9-17 km). 
    - Although we do not discard this due to technical reasons, it could be caused by _T. sarasinorum_ having fewer patches of suitable habitat.
    - Taking into account that Lake Matano is roughly 30 x 5 km, our results indicate no evidence of isolation by distance. 
    
    #set align(center)
    #set text(size: 34pt)
    = Methods 
    #set text(size: 24pt)
    #set align(left)
    #line(length: 100%)
    All analysis and simulations are available at #underline(text(rgb("006ca9ff"))[https://github.com/currocam/benelux-zoology-conference])

    #set align(center)
    #set text(size: 34pt)
    = Future work
    #set align(left)
    #line(length: 100%)
    #set text(size: 24pt)
    Future work would benefit from more extensive sequencing of modern samples of these and other species. Together, this would provide a better understanding of the evolutionary history of these species but can also lead to better conservation management strategies.
    
    - More extensive sampling would allow us to estimate the effective population and split times between different species among the radiation.
    - Modern samples would allow us to infer more recent demographic events and address the impact of human activities (nickel mining) and invasive species.
    #set align(center)
    #set text(size: 34pt)
    = Take-home message
    #line(length: 100%)
    #set text(size: 24pt)
    #set align(left)
    1. We observed almost identical demographic histories in _T. opudi_ and _T. sarasinorum_, whose species status is uncertain.
    2. We inferred a large historical effective population size, but we estimated a much lower recent effective population size.
    3. We found a higher dispersal rate in _T. opudi_ than _T. sarasinorum_, but no evidence of isolation by distance. Different feeding niches might explain the lower dispersal rate in _T. sarasinorum_.
    #set text(size: 18pt)

    #line(length: 100%)
    
    #super("1") The mean effective dispersal rate is the average distance between an individual and its parents.
    
    #super("2") Here, we define an identical-by-descent block as a contiguous segment of the genome inherited from a shared common ancestor without intervening recombination.

   #linebreak()
    #set align(center)
    #image("figures/eveco-en-rgb.svg", width: 80%)
  ]

)