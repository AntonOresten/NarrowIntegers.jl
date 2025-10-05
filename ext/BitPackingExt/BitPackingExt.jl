module BitPackingExt

using NarrowIntegers
using BitPacking

BitPacking.bitwidth(::Type{<:NarrowInteger{W}}) where W = W

# TODO:
# look at https://github.com/JuliaLang/julia/blob/441ebf958477aad68158b7d600c30278b2644d8c/base/broadcast.jl
# read https://julialang.org/blog/2018/05/extensible-broadcast-fusion/

include("add.jl")

end