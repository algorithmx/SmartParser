#: ==========================================================

function preprocess_raw_input(raw::String)
    s = "$raw"
    for r ∈ __preproc__
        s = replace(s, r)
    end
    return s
end

#: ==========================================================



function mask(s0::String)::String
    s = "$s0"
    for r ∈ MASK_RULES
        s = replace(s, r)
    end
    return s
end


#: ==========================================================

encode_line(l,dic) = Int[dic[w] for w ∈ split(l,r"[^\S\n\r]",keepempty=false)]


function tokenize(
    lines::Vector{S}, 
    code::Dict{String,Int}
    )::Vector{TPattern} where {S<:AbstractString}
    enc(l) = encode_line(l,code)
    patts = TPattern[]
    try 
        #: line *1
        patts = TPattern[((unique(p)==[0,]) ? __PATT__all_number_line__ : p) for p ∈ enc.(lines)]
    catch _e_
        @warn "tokenize failed."
        return TPattern[]
    end
    return patts
end


function tokenize(S0::String)::Tuple{Vector{TPattern},Dict{String,Int}}
    lines = split(S0,"\n",keepempty=false) ; #TODO 
    unique_words = unique(vcat(split.(lines,r"[^\S\n\r]",keepempty=false)...)) ;
    code = Dict{String,TCode}(w=>i for (i,w) ∈ enumerate(unique_words))
    code["£"] = 0  # reserved token 0 for number
    conflict_kw = [k for (k,v) ∈ code if "£"!=k && occursin("£",k)]
    if length(conflict_kw)>0
        @warn "conflict_kw = $(conflict_kw)"
    end
    patts = tokenize(lines, code)
    return patts, code
end


#: ==========================================================

function revert(code::Dict{String,Int})
    dic = Dict{Int,String}(i=>k for (k,i) ∈ code)
    dic[__PATT__all_number_line__[1]] = "£++++++++++++++++"
    return dic
end

#: ==========================================================


function add_newline(lines)
    @inline headspace(l) = ((length(l)>0 && startswith(l," ")) 
                                ? (findfirst(x->x!=' ',l)!==nothing ? (findfirst(x->x!=' ',l)-1) 
                                : findlast(x->x==' ',l)) : 0)
    hstack = Stack{Int}()
    lines1 = []
    for l ∈ lines
        h = headspace(l)
        if length(hstack)>0
            if h > top(hstack)
                push!(lines1,"")
            elseif h == top(hstack)
                nothing
            else
                ht = top(hstack)
                push!(lines1,"")
                while length(hstack)>0 && top(hstack)>h
                    x = pop!(hstack)
                    if x != ht
                        ht = x
                        push!(lines1,"")
                    end
                end
            end
        end
        push!(lines1, l)
        push!(hstack, h)
    end
    return lines1
end


function load_file(
    fn
    )::Tuple{Vector{String},Vector{String},Vector{TPattern},Dict{String,Int}}
    if isfile(fn)
        S0 = read(fn,String) |> preprocess_raw_input
        MS0 = mask(S0)
        patts, code = tokenize(MS0)
        lines = split(S0,"\n",keepempty=false) #TODO
        lines_masked = split(MS0,"\n",keepempty=false) #TODO
        return lines, lines_masked, patts, code
    else
        return String[], String[], TPattern[], Dict{String,Int}()
    end
end

