Base.typemax(::Type{T}) where {W,T<:NarrowUnsigned{W}} = reinterpret(T, mask(W))
Base.typemin(::Type{T}) where {W,T<:NarrowUnsigned{W}} = reinterpret(T, 0x00)

(::Type{T})(n::NarrowUnsigned) where T<:Integer = T(reinterpret(UInt8, n))

Base.:>>(x::T, y::Int64) where {W,T<:NarrowUnsigned{W}} = x >>> y

Base.widen(::Type{T}) where T<:NarrowUnsigned = UInt8

