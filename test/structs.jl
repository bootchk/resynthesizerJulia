
#=
Snippets for testing struct types.
=#

struct Foo
    field1::Int
end

isconcretetype(Foo) # true
# Foo is concrete because it is a struct.

fieldtype(Foo, 1)  # Int64
# While declared an Int, the actual type is Int64
# TODO because why?

Int64 <: Int  # true
# Int64 is a subtype of Int

Int64 <: Integer  # true
# Int64 is also a subtype of Integer
# Integer is Abstract supertype for all integers.

Int <: Integer  # true
Integer <: Int  # false
# Int is a subtype of Integer

isconcretetype(Int) # true
isconcretetype(Integer) # false

Int <: Signed   # true
Integer <: Signed   # true



isconcretetype(Int) # true
# Int

x::Int = 1  # ERROR: syntax: type declarations on global variables are not yet supported

x = 1
typeof(x)   # Int64

Int64 :< Int

typeof(Int) # DataType
# the type of a type is DataType


#=
Tests that all fields of given type expr are concrete.
=#
macro isconcretestruct(expr)
    @assert expr.head == :struct
    S = expr.args[2]
    return quote
        $(esc(expr))

        for n in fieldnames($S)
            if !isconcretetype(fieldtype($S, n))
                error("field $n is not concrete")
            end
        end
    end
end
