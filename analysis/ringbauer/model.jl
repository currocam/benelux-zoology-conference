using Turing, BesselK, ForwardDiff, Distributions, Optim, MCMCChains
# Bayesian implementation of the Ringbauer model that
# relies on a custom AUtoDiff function to compute the
# BesselK function
function safe_adbesselk(v, x)
    try
        return adbesselk(v, x)
    catch
        return NaN
    end
end
# Eq: 5
function nL(beta, D, sigma, r, L)
    term1 = 2^(-1.5*beta-3)
    term2 = 1/pi/D/sigma^2
    term3 = (r/sqrt(L)/sigma)^(2+beta)
    term4 = safe_adbesselk(2+beta, sqrt(2*L)*r/sigma)
    return term1*term2*term3*term4
end
# From Appendix
function E_nl(G, beta, D, sigma, r, L)
    return ((G -L)*nL(beta, D, sigma, r, L) + (G -L)*nL(beta-1, D, sigma, r, L))*4
end
function expected_blocks(G, beta, D, sigma, r, L, delta_L)
    return E_nl(G, beta, D, sigma, r, L)*delta_L
end

# Define the model
@model function ringbauer(
    distances, block_lengths, counts,
    pairs, G, delta_L
    )
    # Define the priors
    beta ~ Normal(0, 0.001)
    D ~ truncated(Cauchy(20, 5), 0, Inf)
    sigma ~ Uniform(0, 40)
    if D <= 0 || sigma <= 0
        Turing.@addlogprob! -Inf
        return nothing
    end
    # Define the likelihood
    for i in eachindex(distances)
        expected_rate = expected_blocks(
            G, beta, D, sigma,
            distances[i], block_lengths[i], delta_L
        )*pairs[i]
        if isnan(expected_rate) || expected_rate < 0
            Turing.@addlogprob! -Inf
            return nothing
        end
        counts[i] ~ Poisson(expected_rate)
    end
end
