using StaticArrays
using BitPacking

import StaticArrays: similar_type

struct MultiInt{T<:NarrowInteger,N,D} <: StaticVector{N,T}
    data::D
end

function MultiInt{T,N,D}(x::NTuple{N,T}) where {T<:NarrowInteger,N,D}
    return MultiInt{T,N,D}(BitPacking.packint(D, x))
end

function similar_type(::Type{MultiInt{T,N,D}}, ::Type{T′}=T, ::Size{N′}=Size(N)) where {T,N,D,T′<:NarrowInteger,N′}
    return MultiInt{T′,only(N′),D}
end

function similar_type(::Type{MultiInt{T,N,D}}, ::Type{T′}=T, ::Size{N′}=Size(N)) where {T,N,D,T′,N′}
    return SVector{only(N′),T′}
end

function Base.getindex(x::MultiInt{T,N}, i::Int) where {W,T<:NarrowInteger{W},N}
    @boundscheck 1 <= i <= N || throw(BoundsError(x, i))
    return BitPacking.getint(x.data, T, i)
end

for (name, op) in ((:multiadd, :+), (:multimul, :*))
    @eval function ($name)(x::MultiInt{T,N,D}, y::MultiInt{T,N,D}) where {T,N,D}
        mask_a = alternating_mask(D, Val(bitwidth(T)))
        mask_b = ~mask_a
        a = (($op)(x.data & mask_a, y.data & mask_a)) & mask_a
        b = (($op)(x.data & mask_b, y.data & mask_b)) & mask_b
        return MultiInt{T,N,D}(a | b)
    end
end

multiand(x::T, y::T) where T<:MultiInt = T(x.data & y.data)
multior(x::T, y::T) where T<:MultiInt = T(x.data | y.data)
multixor(x::T, y::T) where T<:MultiInt = T(x.data ⊻ y.data)
multinot(x::T) where T<:MultiInt = T(~x.data)

function multisub(x::T) where T<:MultiInt
    ones = T(tile(typeof(x.data), Val(bitwidth(eltype(x))), Val(0x01)))
    return multiadd(multinot(x), ones)
end

Base.:+(x::T, y::T) where T<:MultiInt = multiadd(x, y)
Base.:-(x::T) where T<:MultiInt = multisub(x)

multisub(x::T, y::T) where T<:MultiInt = x + -y
Base.:-(x::T, y::T) where T<:MultiInt = multisub(x, y)
