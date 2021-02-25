function findfirst_spec(l::S, spec0)::IntRange where {S<:AbstractString}
    spec = string(spec0)
    #: note the white space
    k = ((" "*spec*" " ∈ keys(MASK_RULES_DIC_INV)) ? MASK_RULES_DIC_INV[" "*spec*" "] : (spec=="£" ? MASK_RULES_DIC_INV["£"] : spec))
    p = findfirst(k,l)
    return (p!==nothing) ? p : (0:0)
end


@inline to_words(l) = split(l,r"[^\S\n\r]",keepempty=false)

function parse_file(
    t::Block{TR}, 
    lines::Vector{String}, 
    lines1::Vector{String}, 
    codeinv
    )::Block{TR} where TR
    
    t1 = copy(t)

    if is_multi(t)
        #TODO missing blocks !
        t1.C = [parse_file(c, lines, lines1, codeinv) for c ∈ children(t)]
    else
        @assert t.n==length(t.x)
        tokens = [codeinv[patt] for patt in t.p]
        words1 = to_words.(lines1[t.x])

        # extract data 
        data = []
        for (line,word) ∈ zip(lines[t.x],words1)
            ii = 0
            dt = []
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
        t1.DATA = data
    end

    return t1

end
