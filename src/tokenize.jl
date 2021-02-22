
function mask(s0::String)::String
    _rules = [  
        r"(/[^/\s]*)+/([^/\s\.]*\.)+[A-Za-z0-9]*"=>" __FULLPATH__ ", 
        r"[^0-9/\s\.\(\)]{3,20}\.([^/\s\.\(\)]+\.)*[A-Za-z]+"=>" __ABSPATH__ ", 
        r"-?\d+(\.\d*)?((e|E)-?\d+)?"=>"£",
        "(£"=>"( £",
        "£)"=>"£ )",
        r"(?<![0-9A-Za-z])(H|He|Li|Be|B|C|N|O|F|Ne|Na|Mg|Al|Si|P|S|Cl|Ar|K|Ca|Sc|Ti|V|Cr|Mn|Fe|Co|Ni|Cu|Zn|Ga|Ge|As|Se|Br|Kr|Rb|Sr|Y|Zr|Nb|Mo|Tc|Ru|Rh|Pd|Ag|Cd|In|Sn|Sb|Te|I|Xe|Cs|Ba|La|Ce|Pr|Nd|Pm|Sm|Eu|Gd|Tb|Dy|Ho|Er|Tm|Yb|Lu|Hf|Ta|W|Re|Os|Ir|Pt|Au|Hg|Tl|Pb|Bi|Po|At|Rn|Fr|Ra|Ac|Th|Pa|U|Np|Pu|Am|Cm|Bk|Cf|Es|Fm|Md|No|Lr|Rf|Db|Sg|Bh|Hs|Mt)(?=[^0-9A-Za-z])"=>" __CHEMELEM__ ",
        r"[^\-\_\\\/\%\s]+((\-|\_)[^\-\_\\\/\%\s]+)+"=>" __SYMBOL__ "
    ]
    s = "$s0"
    for r ∈ _rules
        s = replace(s, r)
    end
    return s
end


encode_line(l,dic) = Int[dic[w] for w ∈ split(l,r"[^\S\n\r]",keepempty=false)]



TPattern = Vector{Int}


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
    patts = tokenize(lines, code)
    return patts, code
end



function load_file(fn)::Tuple{Vector{String},Vector{String},Vector{TPattern},Dict{String,Int}}
    if isfile(fn)
        S0 = read(fn,String)
        patts, code = tokenize(mask(S0))
        lines = split(S0,"\n")
        lines_masked = split(mask(S0),"\n")
        return lines, lines_masked, patts, code
    else
        return String[], String[], TPattern[], Dict{String,Int}()
    end
end
