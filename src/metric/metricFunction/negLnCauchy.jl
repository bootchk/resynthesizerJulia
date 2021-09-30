

#=

Definition
==========

https://en.wikipedia.org/wiki/Cauchy_distribution

Function proportional to the "standard Cauchy distribution".
The formula for standard cauchy pdf is 1/(pi(x2+1))

"Proportional to":
- the constant pi is removed from the usual formula.
- negative log is applied
These alterations speed up the computation with no loss of accuracy for the purpose.

negativeLog(x) == log(1/x)

We also scale the value with a parameter, usually 0.117,
so-called "autism" by the original author.

"Standard cauchy pdf":
- parameter for the center, Xsub0, is zero
- parameter for the spread, gamma, is 1

As defined, the max value is ~4.3 at max difference of 1.0

Implementation notes
====================

This is a run-time computation when <value> is a variable.

When <value> is a compile-time constant,
does the compiler optimize this away?

In the original, typeof value was byte integer (0-254)
and evaluated using a table.

!!! This is at the deepest point of the computation iteration,
i.e. critical for performance.
=#

function negLnCauchy(value)
    #=
    As in C, log is natural log

    0.117 TODO a parameter
    =#
    return log( (value/0.117)^2 + 1 )
end
