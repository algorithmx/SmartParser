@inline function comp_each_char(s1, i1::Int, s2, i2::Int)
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
function find_pos_from_right(
    substr::Vector{UInt64}, 
    fullstr::Vector{UInt64}, 
    posL_str::Int; 
    compare_func=comp_each_char
    )::Int
    for p ∈ posL_str:-1:1
        if compare_func(substr,1,fullstr,p)  return p   end
    end
    return -1
end


function nonoverlapping(
    substr::Vector{UInt64}, 
    fullstr::Vector{UInt64}, 
    posL_str::Int;
    compare_func=comp_each_char
    )::Vector{UnitRange{Int}}
    q = find_pos_from_right(substr, fullstr, posL_str, compare_func=compare_func)
    if q > 0
        Nsub = length(substr)
        return [nonoverlapping(substr, fullstr, q-Nsub, compare_func=compare_func)..., q:q+Nsub-1]
    else
        return UnitRange{Int}[]
    end
end


@inline nonoverlapping(substr::Vector{UInt64}, fullstr::Vector{UInt64}; compare_func=comp_each_char) = 
    nonoverlapping(substr, fullstr, length(fullstr)-length(substr)+1, compare_func=compare_func)
