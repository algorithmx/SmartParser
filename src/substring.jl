@inline function comps(s1, i1::Int, s2, i2::Int)
    n1 = length(s1)
    j = 0 
    while j < n1
        if s1[i1+j]!=s2[i2+j]   return false   end
        j += 1
    end
    return j==n1
end


# find the position q such that str[ q : q+Nsub-1 ] == substr
# starts from posL_str in str
# if not found return -1
function seek_pos_R(substr::Vector{UInt64}, fullstr::Vector{UInt64}, posL_str::Int)::Int
    for p ∈ posL_str:-1:1
        if comps(substr,1,fullstr,p)  return p   end
    end
    return -1
end


function nonoverlapping(substr::Vector{UInt64}, fullstr::Vector{UInt64}, posL_str::Int)::Vector{UnitRange{Int}}
    q = seek_pos_R(substr, fullstr, posL_str)
    if q > 0
        Nsub = length(substr)
        return [nonoverlapping(substr, fullstr, q-Nsub); [q:q+Nsub-1,]]
    else
        return []
    end
end

@inline nonoverlapping(substr::Vector{UInt64}, fullstr::Vector{UInt64}) = nonoverlapping(substr, fullstr, length(fullstr)-length(substr)+1)
