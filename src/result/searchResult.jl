
include("probeResult.jl")
include("../null.jl")

#=
Result of a searching function for best matching patch for a given target point.
A search comprises many probes, over the corpus, for a given target point.

This result is for a search for an ephemeral patch.
That is, the diff is not kept for the point,
since the patch around the point is changing often as we search.

!!! Mutable.  Updated as we search.
=#
mutable struct SearchResult{DimensionCount}
    bestProbeResult::ProbeResult
    bestMatchPointInCorpus::CartesianIndex{DimensionCount}
end


#=
For Resynthesizer:

Only one is ever created.
At the start of each search, we mutate it to the starting condition
using the method setStartSearchResult()
=#


#=
Constructor for initial/empty/null result
Only called once.

Sets both fields to start condition.

General on DimensionCount, taken from the passed tensor.
=#
function SearchResult(tensor)
    #=
    Here we are initializing to the least index.
    TODO better if point is out of range for Array (whose usual index base is 1
    =#
    #OLD not general on DimensionCount
    # return SearchResult(ProbeResult(), CartesianIndex(-1,-1))   # TODO missing?

    return SearchResult(ProbeResult(), leastIndex(tensor))
end

#=
Setter method for the start of a search.

Given diff is the best know diff.
We don't need to set bestMatchPointInCorpus,
a search does not read it without first overwriting it.
=#
function setStartSearchResult(searchResult, probeResult)
    searchResult.bestProbeResult = probeResult
end

#=
Setter method when a search finds a better match.
=#
function setBetterSearchResult(searchResult, probeResult, cartesianIndex)
    # Any further searching must best this latest probeResult
    searchResult.bestProbeResult = probeResult
    # The point that yielded this better match
    searchResult.bestMatchPointInCorpus = cartesianIndex
end

#=
Constructor for starting a search, with a know best difference.
The search must best the patchDifference to declare not NotBetter

NOT USED

function SearchResult(patchDifference)
    # point is out of range for Array
    #=
     TODO use undef?
     TODO the "missing" CartesianIndex is not generic on DimensionCount.
     Should use Missing.missing?
     =#
    return SearchResult(ProbeResult(NotBetter, patchDifference), CartesianIndex(-1,-1))
end
=#
