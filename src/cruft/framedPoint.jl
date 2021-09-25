#=
A point associated with an image (the frame of its coordinate system).
Better to explicitly associate a point to its frame.
So that it is harder to make the programming error: use a point coordinate in the wrong frame.

Some applications, use many images having differing bounds.

Not mutable.  See comments for MaskedImage

!!! Types fully specified so compiler can generate good code.
Fully specified means a concrete type (possibly parameterized) ?
=#
struct PointInMaskedImage
    point::CartesianIndex{N} where N
    maskedImage::MaskedImage{T,N} where {T,N}
end

# Custom pretty printing, omit the image
Base.show(io::IO, z::PointInMaskedImage) = print(io, z.point)


# getter for an image
#=
function colorAtPoint( framedPoint)
    # Not checking mask

    # Julia does not permit indexing an Array by a Vector
    return framedPoint.maskedImage.image[ framedPoint.point[1], framedPoint.point[2] ]
end
=#
