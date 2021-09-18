
using Colors


# ??? code_warntype not defined?
# @code_warntype colordiff(colorant"red", colorant"darkred")

#=
function pointDifference(targetColor, corpusColor )::Float64
    return colordiff(
        corpusColor,
        targetColor,
        metric )
    # WAS metric=DE_94() i.e. computing the metric deep in the loops
end
=#


function maxPointDifference()
    #=
    According to Wolfram (but not the Julia site)
    the "typical" max for CIE2000 colordiff
    =#
    # return 1.16839  # CIE2000
    return 1.48916  # CIE84 DE_94
end

pointDifference = colordiff

#=
if subtract in loop, only 27 allocations.

=#
function testDiff()
    a = CartesianIndex(1,2)
    b = CartesianIndex(3,4)
    for i in 1:10000
        # This mutates the local a
        # a -= b

        # This does not mutate the local a
        # TODO why not?
        diffCI(a,b)
    end
    println(a)
end

function diffCI(a, b)
    # println itself requires allocations
    # println(typeof(a))
    a -= b
end



#=
Test whether a passed struct containing a CI
allocates ?
=#

struct Foo
    ci::CartesianIndex{N} where N
    b::Int64
end

mutable struct MutableFoo
    ci::CartesianIndex{N} where N
    b::Int64
end

function testDiff2()
    a = Foo(CartesianIndex(1,2), 1)
    b = Foo(CartesianIndex(3,4), 2)
    c = MutableFoo(CartesianIndex(1,2), 1)
    for i in 1:10000
        c.ci = diffCI2(a,b)
    end
    println(a)
end

function diffCI2(a, b)
    # Why isn't this returned without an allocation?
    # !!! Because the struct must be fully annotated with types?
    # return Foo(a.ci - b.ci, 3)
    return a.ci - b.ci
end
