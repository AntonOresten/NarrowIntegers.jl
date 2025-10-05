@generated function tile(::Type{U}, ::Val{W}, ::Val{x}) where {U<:Unsigned,W,x}
    u = U(x)
    k = sizeof(U) * 8 ÷ W
    for k in 1:k-1
        u |= u << (k * W)
    end
    return :($u)
end

alternating_mask(::Type{U}, ::Val{W}) where {U<:Unsigned,W} = tile(U, Val(2W), Val(mask(W)))
