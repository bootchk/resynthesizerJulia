

#=

Definition
==========

https://en.wikipedia.org/wiki/Cauchy_distribution

Function proportional to the "Cauchy distribution".
The formula for cauchy pdf is 1/(pi(x^2/gamma^2 + 1)),


"Proportional to":
- the constant pi is removed from the usual formula.
- negative log is applied
These alterations speed up the computation with no loss of accuracy for the purpose.

negativeLog(x) == log(1/x)

A parameter is the gamma.
AKA the spread/dispersion/deviation.
so-called "autism" by the original author.

"Standard cauchy pdf":
- parameter for the center, Xsub0, is zero
- parameter for the spread, gamma, is 1

As defined, the max value is ~4.3 at max difference of 1.0

Parameters of the PDF
=====================
A parameter is the gamma.
AKA the spread/dispersion/deviation.
so-called "autism" by the original author.

It specifies the spikiness of the PDF peak.
Or, the "fatness" of the tails of the PDF.



Implementation notes
====================

This is a run-time computation when <value> is a variable.

When <value> is a compile-time constant,
does the compiler optimize this away?

When values (the domain of the function) are discrete
this can be evaluated using a table
instead of using run-time arithmetic.

Resynthesizer specific notes
============================

For a discussion of why the standard cauchy PDF is used, instead of the Gaussian,
and other discussion,
see Paul Harrison's thesis https://www.logarithmic.net/pfh-files/thesis/dissertation.pdf.

In the original Resynthesizer typeof value was byte integer (0-254)
i.e. a pixelel or channel value is unsigned byte.
So discrete, and computable using a table.
And the default (usually the best results) gamma parameter was 0.117.

!!! This is at the deepest point of the Resynthesizer computation iteration,
i.e. critical for performance.

Default gamma for resynthesizer
===============================

Should be relative to the domain of the function.
For example, if the max value is 255 (the difference between two byte values)
a gamma of 0.117 gives a certain very spiky curve
(and good results for the Resynthesizer algorithm, by experimental trials.)
When the max value is 1.0 (the float difference between to float values
in the range 0-1)
Then the corresponding default gamma should be 0.000459
to give a similarly shaped PDF curve.

=#

#=
TODO general for type of value
This is for float values in range 0-1

TODO table driven
=#
function negLnCauchy(value)
    #=
    As in C, log is natural log

    0.117 FUTURE a parameter
    =#
    return log( (value/0.000459)^2 + 1 )
end
