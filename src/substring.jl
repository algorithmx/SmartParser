@inline function comp_each_char(s1::Vector{TR}, i1::Int, s2::Vector{TR}, i2::Int) where TR
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
    substr::Vector{TR}, 
    fullstr::Vector{TR}, 
    posL_str::Int; 
    compare_func=comp_each_char
    )::Int  where  TR

    for p ∈ posL_str:-1:1
        if compare_func(substr,1,fullstr,p)  return p   end
    end
    return -1

end


function nonoverlapping(
    substr::Vector{TR}, 
    fullstr::Vector{TR}, 
    posL_str::Int;
    compare_func=comp_each_char
    )::Vector{IntRange}  where  TR

    q = find_pos_from_right(substr, fullstr, posL_str, compare_func=compare_func)
    if q > 0
        Nsub = length(substr)
        return [nonoverlapping(substr, fullstr, q-Nsub, compare_func=compare_func)..., q:q+Nsub-1]
    else
        return IntRange[]
    end

end


@inline nonoverlapping(substr::Vector{TR}, fullstr::Vector{TR}; compare_func=comp_each_char) where TR = 
    nonoverlapping(substr, fullstr, length(fullstr)-length(substr)+1, compare_func=compare_func)
