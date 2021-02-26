function comp_each_char(
    s1::Vector{TR}, 
    i1::Int, 
    s2::Vector{TR}, 
    i2::Int
    )::Bool where TR

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
function find_pos_from_right_V0(
    substr::Vector{TR}, 
    fullstr::Vector{TR}, 
    posL_str::Int
    )::Int  where  TR

    for p ∈ posL_str:-1:1
        if comp_each_char(substr,1,fullstr,p)  return p   end
    end
    return -1
end


function nonoverlapping(
    substr::Vector{TR}, 
    fullstr::Vector{TR}, 
    posL_str::Int
    )::Vector{IntRange}  where  TR

    Nsub = length(substr)
    posL = posL_str
    R    = IntRange[]
    while posL >= Nsub
        #q = find_pos_from_right(substr, fullstr, posL, compare_func=compare_func)
        q = find_pos_from_right(substr, fullstr, posL)
        if q > 0
            push!(R, q:q+Nsub-1)
            posL = q-Nsub
        else
            break
        end
    end
    return R
end


function nonoverlapping(
    substr::Vector{TR}, 
    fullstr::Vector{TR}
    )::Vector{IntRange} where TR

    return nonoverlapping(  substr, 
                            fullstr, 
                            length(fullstr)-length(substr)+1 )
end
