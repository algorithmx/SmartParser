function findfirst_spec(l::S, spec0)::IntRange where {S<:AbstractString}
    spec = string(spec0)
    #: note the white space
    k = ((" "*spec*" " ∈ keys(MASK_RULES_DIC_INV)) ? MASK_RULES_DIC_INV[" "*spec*" "] : (spec=="£" ? MASK_RULES_DIC_INV["£"] : spec))
    p = findfirst(k,l)
    return (p!==nothing) ? p : (0:0)
end


@inline to_words(l) = split(l,r"[^\S\n\r]",keepempty=false)


function parse_file(
    shift::Int,
    t::Block{TR}, 
    lines::Vector{String}, 
    lines1::Vector{String}, 
    codeinv
    )::Block{TR} where TR
    
    @assert is_valid_x(t)
    t1 = copy(t)

    if is_multi(t)
        Tx1 = concat0(t.C[1].x,t.C[end].x)
        N1  = length(Tx1)
        @assert N1*t.n == length(t.x)
        #: parse t.n times !!
        for k=1:t.n
            shift_n = shift+(k-1)*N1  #: the accumulated shift
            for i=1:length(t1.C)
                t1.C[i] = parse_file(shift_n, t1.C[i], lines, lines1, codeinv)
            end
        end
    else
        TX = (first(t.x)+shift):(last(t.x)+shift)
        tokens = [codeinv[patt] for patt in t.p]
        words1 = to_words.(lines1[TX])
        # extract data 
        data = Vector{Pair{String,String}}[]
        for (line,word) ∈ zip(lines[TX],words1)
            ii = 0
            dt = Pair{String,String}[]
            for w ∈ word
                r = findfirst_spec(line[ii+1:end], w)
                if r==0:0  @show (ii,line,word,w)  end
                @assert r!=0:0
                if w=="£" || " $w " ∈ keys(MASK_RULES_DIC_INV)  #: note the white space !!!
                    push!(dt, w=>string(line[ii+1:end][r]))
                end
                ii += last(r)
            end
            push!(data, dt)
        end
        push!(t1.DATA, TX=>data)
    end

    return t1

end
