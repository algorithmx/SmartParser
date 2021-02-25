
function search_kw_in_tree_data(t::Multiline, kw)
    f(x) = (is_multi(x) ? [[]] : ([[v for (k,v) in data if k==kw] for data in x.DATA]))
    return [(i,x) for (i,x) in enumerate(collect_action_dfs(t,f)) if unique(x)!=[[]]]
end


function block_by_kw(t::Multiline, kw)
    @inline kw_in_sl(kw,sl) = length([1 for data in sl.DATA for (k,v) ∈ data if k==kw])>0
    h(x) = (is_multi(x[2]) 
                ? vcat( # pick the correct block (labelled by 1)
                        [CD[first.(CD).==1] for CD in x[1]]...,  
                        # and itself if there is any children returns [(0,nothing)]
                        (any([kw_in_sl(kw,sl) for sl in children(x[2]) if is_single(sl)]) ? [(1,x[2])] : []) )
                : [] )
    DFS(t, x->nothing, x->nothing, h)
end

#:========================================


function generate_line(patt::Vector{Int}, codeinv::Dict, data)
    if patt==[999999999,]
        @assert unique(first.(data))==["£",]
        return join(string.(last.(data)), "  ")
    else
        line = []
        idata = 1
        Ndata = length(data)
        #@show [codeinv[p] for p ∈ patt]
        for p ∈ patt
            w = codeinv[p]
            @assert  w != "£++++++++++++++++"
            if idata<=Ndata && w==data[idata][1]  # found data,
                #  replace p by data
                push!(line, string(data[idata][2]))  
                idata += 1
            else
                push!(line, w)
            end
        end
        return join(line, "  ")
    end
end


function reconstruct_file(DATATREE::Multiline, codeinv::Dict)
    single_line_reconstr(y) = [generate_line(y[2].p, codeinv, y[2].DATA[i]) for i=1:y[2].n]
    multi_line_reconstr(y)  = vcat(y[1]...)
    line_reconstr(y) = (is_single(y[2]) ? single_line_reconstr(y) : multi_line_reconstr(y))
    DFS(DATATREE, identity, identity, line_reconstr)
end

