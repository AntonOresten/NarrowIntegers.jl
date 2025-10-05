Base.typemax(::Type{T}) where {W,T<:NarrowSigned{W}} = reinterpret(T, mask(W-1))
Base.typemin(::Type{T}) where {W,T<:NarrowSigned{W}} = reinterpret(T, mask(W-1) + 0x01)

function (::Type{T})(n::NarrowSigned{W}) where {W,T<:Integer}
    bits = reinterpret(UInt8, n) & mask(W)
    sign_term = bits & (0x01 << (W - 1))
    return T(bits & ~sign_term) - T(sign_term)
end

Base.signbit(x::T) where {W,T<:NarrowSigned{W}} = !iszero(reinterpret(UInt8, x) & (0x01 << (W - 1)))

function Base.:>>(x::T, y::Int64) where {W,T<:NarrowSigned{W}}
    lpad_ones = (0x01 << y - 0x01) << (W - y)
    lpad = signbit(x) * lpad_ones
    return reinterpret(T, lpad | reinterpret(UInt8, x) >> y)
end

Base.widen(::Type{T}) where T<:NarrowSigned = Int8

Base.promote_rule(::Type{N}, ::Type{N}) where N<:NarrowSigned = N

function Base.promote_rule(::Type{N}, ::Type{M}) where {N<:NarrowSigned,M<:Integer}
    bitwidth(N) > bitwidth(M) ? N : M
end
