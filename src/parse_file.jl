#+ =========== parse ============

@inline to_words(l) = split(l,r"[^\S\n\r]",keepempty=false)

function parse_file!(
    shift::Int,
    t::Block{TR}, 
    lines::Vector{String}, 
    lines1::Vector{String}, 
    codeinv
    )::Block{TR} where TR

    @assert is_valid_x(t)
    if is_multi(t)
        Tx1 = concat0(t.C[1].x,t.C[end].x)
        N1  = length(Tx1)
        #@assert N1*t.n == length(t.x)
        #: parse t.n times !!
        for k=1:t.n
            shift_n = shift+(k-1)*N1  #: the accumulated shift
            for i=1:length(t.C)
                t.C[i] = parse_file!(shift_n, t.C[i], lines, lines1, codeinv)
            end
        end
    else
        TX = (first(t.x)+shift):(last(t.x)+shift)
        tokens = [codeinv[patt] for patt in t.p]
        words1 = to_words.(lines1[TX])
        # extract data 
        data = Vector{Pair{String,Any}}[]
        for (line,word) ∈ zip(lines[TX],words1)
            ii = 0
            keywords = Pair{String,Any}[w=>((cmp(w,"£")==0 || startswith(w,"__")) 
                                            ? MASK_RULES_DIC_INV1[w]
                                            : nothing) 
                                        for w ∈ word]
            for (i,(w,kw)) ∈ enumerate(keywords)
                line_ii = line[ii+1:end]
                if kw!==nothing
                    r = findfirst(kw,line_ii) #: note the white space !!!
                    if r!==nothing
                        #push!(dt, w=>string(line_ii[r]))
                        keywords[i] = w=>string(line_ii[r])
                    else
                        throw(error("Incompatible keyword structure in line $(line) at word $(w) and keyword $(kw)."))
                    end
                    ii += last(r)
                end
            end
            push!(data, keywords)
        end
        push!(t.DATA, TX=>data)
    end
    return t
end


#+ =========== search ============

function search_kw_in_tree_data(t::Block, kw)
    # DATA is organized as follows
    # range => Vector{Pair{String,Any}}[...]
    # each v in [...] is a line of data from parsing single line
    key_in_data(dt) = any(  tx_data_pair->any(  kv_list->any(kv->first(kv)==kw,kv_list), 
                                                last(tx_data_pair) ), 
                            dt   )
    extract_data(x::Block) = (is_single(x) && key_in_data(x.DATA)) ? x.DATA : Any[]
    coll = collect_action_dfs(t, extract_data)

    return vcat([ x for x in coll if (vcat(x...)!=[]) && (vcat(vcat(last.(x)...)...)!=[]) ]...)
end
