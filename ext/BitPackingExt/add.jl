# 16 lanes of 4 bits each, packed little-endian across the word.
const LO = 0x0f0f0f0f0f0f0f0f % UInt64  # low nibble in every byte
const M1 = 0x1111111111111111 % UInt64  # bit 0 in every nibble

# Per-nibble (mod 16) addition: no cross-nibble carry.
function add_chunk(::Val{4}, a::UInt64, b::UInt64)
    lo = (a & LO) + (b & LO)
    hi = ((a >> 4) & LO) + ((b >> 4) & LO)
    return (lo & LO) | ((hi & LO) << 4)
end

Base.similar(::Broadcasted{DefaultArrayStyle{N}}, ::Type{T}, dims) where {N,W,T<:NarrowInteger{W}} =
    similar(BitPackedArray{W,T,N}, dims)

function Broadcast.broadcasted(::typoef(+), )
end