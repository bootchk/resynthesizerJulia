
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





#=
??? .
Start w/o ::Float64   , 3s 500k allocs
w/::Float64            0.009619 seconds (160.06 k allocations: 2.444 MiB)
w/ const a,b   Unsupported const local
w/ ::Color             same
=#
function testColorDiff()
    a::Color = colorant"red"
    b::Color = colorant"darkred"
    sum::Float64 = 0.0
    for i in 1:10000
        # sum += colordiff(a,b)
        sum = sum + colordiff(a,b)
    end
    # println(a)
end


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


using Colors

include("../src/metric/distance.jl")

function testDiff3()
    a = colorant"red"
    #println(a)
    b = colorant"blue"  # "darkred"

    println(typeof(pointDifference))
    # sum = zero(typeof(pointDifference))
    # println(typeof(sum))

    sum::Float32 = zero(Float32)
    for i in 1:10000
        sum +=  pointDifference(a,b)
        #pointDifference(a,b)
    end
    println(sum)
end

function diffCI2(a, b)
    # Why isn't this returned without an allocation?
    # !!! Because the struct must be fully annotated with types?
    # return Foo(a.ci - b.ci, 3)
    return a.ci - b.ci
end
