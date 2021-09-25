
#=
Enumerated type describing how a better patch was found.

!!! JustBetter is better or equal.

Relation between new and previous diff:

>  Worse
= Just Better
< Just Better

new == 0  Perfect  (TODO within epsilon of zero.)
=#

@enum Betterment NotBetter JustBetter PerfectMatch

function classifyBetterment(newDiff, previousDiff)
    if newDiff >= previousDiff
        betterment = NotBetter
    elseif newDiff == 0
        betterment = PerfectMatch
    else
        betterment = JustBetter
    end
    return betterment
end
