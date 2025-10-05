# Shift each nibble left by k bits (0≤k≤3), modulo 16, independently.
@inline function shl4_chunk(x::UInt64, k::Int)::UInt64
    lo = ((x & LO) << k) & LO
    hi = ((((x >> 4) & LO) << k) & LO) << 4
    return lo | hi
end

# Make a per-nibble mask of 0xF where the k-th bit of the nibble in `a` is 1, else 0.
# Trick: bring that bit to each nibble’s LSB, then replicate via multiply-by-0xF.
@inline function nibble_mask_from_bit(a::UInt64, k::Int)::UInt64
    y = (a >> k) & M1               # 1 at each nibble’s LSB if bit k was set
    return (y * 0x0f) & LO          # => 0xF per selected nibble, else 0
end

# Per-nibble (mod 16) multiplication using 4 partial products and nibblewise adds.
# p = Σ_k ( (a_k ? (b << k) : 0) )  with all ops done per-nibble.
@inline function mul4_chunk(a::UInt64, b::UInt64)::UInt64
    a &= LO; b &= LO
    p = 0x0000000000000000 % UInt64
    @inbounds for k in 0:3
        mk = nibble_mask_from_bit(a, k)   # 0xF per nibble where bit k of a is 1
        part = shl4_chunk(b, k) & mk      # add b<<k only in those nibbles
        p = add4_chunk(p, part)           # nibblewise (mod 16) add
    end
    return p
end
