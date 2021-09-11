
include("probeResult.jl")

#=
Result of a searching function for best matching patch for a given target point.
A search comprises many probes, over the corpus, for a given target point.

!!! Mutable.  Updated as we search.
=#
mutable struct SearchResult{DimensionCount}
    bestProbeResult::ProbeResult
    bestMatchPointInCorpus::CartesianIndex{DimensionCount}
end

#= NOT USED
# Constructor for initial/empty/null result
# TODO make this a constant
function SearchResult()
    # point is out of range for Array, whose usual index starts at 1
    return SearchResult(ProbeResult(), missing) # CartesianIndex(-1,-1))
end
=#

#=
Constructor for starting a search, with a know best difference.
The search must best the patchDifference to declare not NotBetter
=#
function SearchResult(patchDifference)
    # point is out of range for Array
    #=
     TODO use undef?
     TODO the "missing" CartesianIndex is not generic on DimensionCount.
     Should use Missing.missing?
     =#
    return SearchResult(ProbeResult(NotBetter, patchDifference), CartesianIndex(-1,-1))
end
