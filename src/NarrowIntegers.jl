module NarrowIntegers

using BitPacking

include("utils.jl")

primitive type NarrowSigned{W} <: Signed 8 end
primitive type NarrowUnsigned{W} <: Unsigned 8 end

const NarrowInteger{W} = Union{NarrowSigned{W},NarrowUnsigned{W}}

BitPacking.bitwidth(::Type{<:NarrowInteger{W}}) where W = W

export NarrowSigned
export NarrowUnsigned
export NarrowInteger

mask(W) = (0x01 << W) - 0x01
mask(::Type{<:NarrowInteger{W}}) where W = mask(W)
Base.:&(n::T, ::typeof(mask)) where T = n & mask(T)

Base.reinterpret(::Type{Unsigned}, n::NarrowInteger) = reinterpret(UInt8, n)

function (::Type{T})(n::Integer) where {W,T<:NarrowInteger{W}}
    (n < Int(typemin(T)) || n > Int(typemax(T))) && throw(InexactError(:trunc, T, n))
    return reinterpret(T, n % UInt8 & mask(W))
end

import Base: (+), (*), (-), (&), (|), (⊻)

for op in (:+, :*, :-, :&, :|, :⊻)
    @eval function ($op)(x::T, y::T) where {W,T<:NarrowInteger{W}}
        return reinterpret(T, ($op)(reinterpret(UInt8, x), reinterpret(UInt8, y)) & mask(W))
    end
end

Base.:~(x::T) where {W,T<:NarrowInteger{W}} = reinterpret(T, reinterpret(UInt8, x) ⊻ mask(W))

import Base: (<<), (>>), (>>>)

Base.:<<(x::NarrowInteger, k::Integer) = x << Int64(k)
Base.:<<(x::NarrowInteger, k::Unsigned) = x << Int64(k)
Base.:<<(x::T, k::Int64) where {W,T<:NarrowInteger{W}} = reinterpret(T, (reinterpret(UInt8, x) << k) & mask(W))

Base.:>>>(x::NarrowInteger, k::Integer) = x >>> Int64(k)
Base.:>>>(x::NarrowInteger, k::Unsigned) = x >>> Int64(k)
Base.:>>>(x::T, k::Int64) where {W,T<:NarrowInteger{W}} = reinterpret(T, reinterpret(UInt8, x) >> k)

Base.:>>(x::NarrowInteger, k::Integer) = x >> Int64(k)
Base.:>>(x::NarrowInteger, k::Unsigned) = x >> Int64(k)

function Base.show(io::IO, x::T) where T<:NarrowInteger
    show_typeinfo = get(IOContext(io), :typeinfo, nothing) != T
    type = repr(T)
    show_typeinfo && print(io, type, "(")
    print(io, Int(x))
    show_typeinfo && print(io, ")")
    return nothing
end

include("signed.jl")
include("unsigned.jl")

const Int1 = NarrowSigned{1}
const Int2 = NarrowSigned{2}
const Int3 = NarrowSigned{3}
const Int4 = NarrowSigned{4}
const Int5 = NarrowSigned{5}
const Int6 = NarrowSigned{6}
const Int7 = NarrowSigned{7}

const UInt1 = NarrowUnsigned{1}
const UInt2 = NarrowUnsigned{2}
const UInt3 = NarrowUnsigned{3}
const UInt4 = NarrowUnsigned{4}
const UInt5 = NarrowUnsigned{5}
const UInt6 = NarrowUnsigned{6}
const UInt7 = NarrowUnsigned{7}

export Int1, Int2, Int3, Int4, Int5, Int6, Int7
export UInt1, UInt2, UInt3, UInt4, UInt5, UInt6, UInt7

include("multi.jl")

export MultiInt

end
