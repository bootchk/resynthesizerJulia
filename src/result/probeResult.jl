

include("betterment.jl")
include("../metric/patchDifference.jl")

#=
Result of a probe, a patch match for a given target point and corpus point.

!!! Not mutable.  Created as a return value.
=#
struct ProbeResult
    betterment::Betterment
    patchDifference::PatchDifferenceType
end

# Outer constructor for initial/empty/null result
function ProbeResult()
    return ProbeResult(NotBetter, Inf)
end
