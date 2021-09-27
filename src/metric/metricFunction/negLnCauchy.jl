

#=

Definition
==========

https://en.wikipedia.org/wiki/Cauchy_distribution

Function proportional to the "standard Cauchy distribution".

"Proportional to":
- the constant pi is removed from the usual formula.
- negative log is applied to invert the value
These alterations speed up the computation with no loss of accuracy for the purpose.

"Standard":
- parameter for the center, Xsub0, is zero
- parameter for the spread, gamma, is 1

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
    # as in C, log is natural log
    return log( (value/0.117)^2 + 1 )
end
