using CSV
using DataFrames
using Distances
# Load Ringbauer model
include("model.jl")
# harcoded constants
r = Dict("Telmatherina_opudi" => 2.572397e-07, "Telmatherina_sarasinorum"=> 2.492342e-07)
# Read metadata
metadata = CSV.File("data/sil185_metadata.csv") |> DataFrame
site_data = CSV.File("data/sampling_sites.txt") |> DataFrame
chrom_data = CSV.File("data/chrom_length.txt") |> DataFrame
column_names = [
    "sample1_id",       # First sample identifier
    "haplotype1_index", # First sample haplotype index
    "sample2_id",       # Second sample identifier
    "haplotype2_index", # Second sample haplotype index
    "chromosome",       # Chromosome
    "start_coord",      # Base coordinate of first marker
    "end_coord",        # Base coordinate of last marker
    "cM_length"         # cM length of IBD segment
]

# Helper functions
function assign_bin_midpoint(cM_value)
    try
        for i in 1:length(bins)-1
            if cM_value >= bins[i] && cM_value < bins[i+1]
                return bin_midpoints[i]
            end
        end
       catch e
           println(cM_value)
       end
    return nothing  # In case cM_value is outside the defined bins
end

function process_data(data, metadata, site_data)
    # Get the site of each sample
    merged = leftjoin(data, metadata, on = :sample1_id => :individual_id)
    data.site1 = merged[!, "sampling_location"]
    merged = leftjoin(data, metadata, on = :sample2_id => :individual_id)
    data.site2 = merged[!, "sampling_location"]

    # Find distances
    samples = union(unique(data.sample1_id), unique(data.sample2_id))
    distances = filter(row -> row.individual_id in samples, metadata)
    merged = leftjoin(distances, site_data, on = :sampling_location => :sampling_location)    
    merged.Longitude .= parse.(Float64, merged.Longitude)
    # Create a new DataFrame to store the sample pair distances
    distance_data = DataFrame(sample1_id = String[], sample2_id = String[], Distance = Float64[])
    # Compute the pairwise distances
    for i in 1:nrow(merged)
        for j in i+1:nrow(merged)
            sample1 = merged[i, :]
            sample2 = merged[j, :]
            
            # Get longitude and latitude for each sample as tuples (Longitude, Latitude)
            l1 = (sample1.Longitude, sample1.Latitude)
            l2 = (sample2.Longitude, sample2.Latitude)
            
            # Compute the distance using the Distances.haversine function
            dist = haversine(l1, l2)
            
            # Add the result to the distance_data DataFrame
            push!(distance_data, (sample1.individual_id, sample2.individual_id, dist))
        end
    end
    # We don't have to bin the distance
    distance_data.Distance ./= 1000 
    # Merge distance_data with data
    data = leftjoin(distance_data, data, on = [:sample1_id, :sample2_id])
    # Now, we bin the cM_length in blocks of 2cM
    data.binned_cM_length = map(assign_bin_midpoint, data.cM_length)
    binned_data = groupby(data, [:Distance, :binned_cM_length])
    binned_data = combine(binned_data, nrow => :count)
    all_combinations = crossjoin(
        DataFrame(Distance = unique(data.Distance)),
        DataFrame(binned_cM_length = unique(data.binned_cM_length))
    )
    final_df = leftjoin(all_combinations, binned_data, on = [:Distance, :binned_cM_length])
    final_df[!, :count] .= coalesce.(final_df[!, :count], 0)
    # Finally, we have to ad how many pairs share the length
    leftjoin(
        final_df,
        combine(groupby(distance_data, :Distance), nrow => :nr_pairs),
        on = :Distance
    )    
end

# Decide on some parameters
delta_L = 2 / 100
bins = 8:2:50
bin_midpoints = [(bin + (bin + 1)) / 2 for bin in bins]
for species in ["Telmatherina_opudi", "Telmatherina_sarasinorum"]
    results = DataFrame()
    infile = "data/$species.ibd.gz"
    df = CSV.File(infile, header=column_names) |> DataFrame
    chromosomes = unique(df.chromosome)
    for chrom in chromosomes
        data = filter(row -> row.chromosome == chrom, df)
        data = select(data, [:sample1_id, :sample2_id, :cM_length])
        data = process_data(data, metadata, site_data)
        data = data[data.Distance .> 0, :]
        data = filter(:binned_cM_length => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), data)
        # Inference
        L = chrom_data[chrom_data.Chrom .== chrom, :Bp][1]
        G = L * r[species]
        model = ringbauer(
            data[:, :Distance],
            data[:, :binned_cM_length] ./ 100,  # Convert to Morgans
            data[:, :count],
            data[:, :nr_pairs],
            G, delta_L
        )
        chains = sample(model, NUTS(), MCMCThreads(), 1000, 4)
        chain_df = DataFrame(chains)
        chain_df[!, :Species] .= species
        chain_df[!, :Chromosome] .= chrom
        results = vcat(results, chain_df)
    end
    filename = "ringbauer_$(species).csv"
    CSV.write(filename, results)
end


