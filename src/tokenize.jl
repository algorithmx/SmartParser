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


TPattern = Vector{Int}


encode_line(l,dic) = Int[dic[w] for w ∈ split(l,r"[^\S\n\r]",keepempty=false)]


function tokenize(lines::Vector{S}, code::Dict{String,Int}) where {S<:AbstractString}
    enc(l) = encode_line(l,code)
    # reserved token 999999999 for all number line
    patts = Vector{Int}[]
    try 
        patts = Vector{Int}[((unique(p)==[0,]) ? [999999999,] : p) for p ∈ enc.(lines)]
    catch _e_
        @warn "tokenize failed."
        return Vector{Int}[]
    end
    return patts
end


function tokenize(S0::String)::Tuple{Vector{TPattern},Dict{String,Int}}
    lines = split(S0,"\n") ;
    unique_words = unique(vcat(split.(lines,r"[^\S\n\r]",keepempty=false)...)) ;
    code = Dict{String,Int}(w=>i for (i,w) ∈ enumerate(unique_words))
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
    dic[999999999] = "£++++++++++++++++"
    return dic
end

#: ==========================================================


function load_file(fn)::Tuple{Vector{String},Vector{String},Vector{TPattern},Dict{String,Int}}
    if isfile(fn)
        S0 = read(fn,String) |> preprocess_raw_input
        patts, code = tokenize(mask(S0))
        lines = split(S0,"\n")
        lines_masked = split(mask(S0),"\n")
        return lines, lines_masked, patts, code
    else
        return String[], String[], TPattern[], Dict{String,Int}()
    end
end

