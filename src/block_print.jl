function block_print(
    t::T,
    s::Vector{S}; 
    mute = false,
    header=y->repeat("|--",max(0,y)),
    offset=-1
    ) where {T <: Block, S <: AbstractString}
    nl = []
    level = [offset,]

    @inline make_str(a, x, l) = "\n"*repeat(" ",length(header(l)))*join(a[getfield(x,:x)], "\n"*repeat(" ",length(header(l))))
    @inline tup_str(x,a...)   = string(([getfield(x,m) for m in a]...,))
    
    f(x) = (push!(nl, header(level[end]) * tup_str(x,:n,:R) * (is_single(x) ? make_str(s,x,level[end]) : "")); 
            push!(level,level[end]+1);
            0 )
    
    g(x) = (pop!(level); 0)
    
    DFS(t, f, g)
    
    if !mute  println.(nl)  end

    return nl
end


treep(t) = tree_print(t, propfunc=x->(getfield(x,:n),label(x),(is_multi(x) ? "M" : "S")), offset=0)
