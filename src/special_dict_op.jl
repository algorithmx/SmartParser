function increaseindex!(h::Dict{K,Int}, key::K) where K
    index = Base.ht_keyindex2!(h, key)
    if index > 0
        h.age += 1
        #@inbounds v0 = h.vals[index]
        @inbounds h.keys[index] = key
        @inbounds h.vals[index] += 1
    else
        @inbounds Base._setindex!(h, 1, key, -index)
    end
    return 
end
