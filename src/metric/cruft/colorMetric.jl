
#=
Implementation of a metric.

Using the Colors module.

You might not be able to include this,
if you also define another metric having the same signature.

I initially used this code
because the Colors module exists
and I thought it would work since it does compute a "difference" in some sense.

But the Colors module has different concerns:
the vagaries of human perception.
We don't need that, instead we need fast.
Experimentally: too slow because of issues with allocations in a call to colordiff(),
because of issues with Julia precompiling failing to infer properly.
=#

using Colors

#=
More generally, call it a "value."
=#
function pointDifference(targetColor, corpusColor )
    result = 0

    result = colordiff(
        targetColor,
        corpusColor,
        metric )
    # WAS metric=DE_94() i.e. computing the metric deep in the loops
    return result
end

#=
The maximum value of the metric.
Approximate constants from the literature.
According to Wolfram (but not the Julia site)
the "typical" max for CIE2000 colordiff
1.16839  # CIE2000
1.48916  # CIE84 DE_94

!!! Depends on metric passed to colorDiff
=#

const maxPointDifference = 1.16839
