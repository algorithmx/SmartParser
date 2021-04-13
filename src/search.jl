#: ============================================

@inline lookup_code(P::Vector{TPattern},c::Int) = any(x->any(y->y==c,x),P)
@inline lookup_code(P::Vector{TPattern},cs::Vector{Int}) = any(x->any(c->any(y->y==c,x),cs),P)
@inline lookup_code(P::Vector{TPattern},cs::NTuple{N,Int}) where N = any(x->any(c->any(y->y==c,x),cs),P)

lookup_codes(P::Vector{TPattern},cs::Vector) = all(lookup_code(P,c) for c in cs)

#: ============================================

function get_DATA_by_codes(
    b::Block{RT}, 
    codes::Vector
    )::Vector{DATATYPE} where RT
    if is_multi(b)
        @assert length(b.R[2])>1  # R[2] = [[1,0,2],[23,24,25,1],...]
        return vcat([get_DATA_by_codes(c,codes) 
                        for c in children(b) 
                            if lookup_codes(c.R[2],codes) ]...)
    elseif is_single(b) && lookup_codes(b.R[2],codes)
        return DATATYPE[b.DATA]
    else
        return DATATYPE[]
    end
end

get_DATA_by_codes(b::Block{RT}, code::Int) where RT = get_DATA_by_codes(b, [code])

#: ============================================

function get_n_blocks_by_codes(b::Block, codes::Vector; n=1)
    status = 0
    function f(x)
        if is_single(x)
            @assert length(x.R[2])==1 
            if lookup_codes(x.R[2],codes)
                status = 1
            end
        end
        return
    end
    return DFS( b, 
                f, 
                x->nothing,
                Vb->( status==0 
                        ? vcat(Vb[1]...)    # hit; reset status and return 
                        : (status>=1+n  ? (status=0 ; vcat(Vb[1]...))    # enough recorded; reset status
                                        : (status+=1; vcat(Vb[1]..., Any[(status-1,Vb[2])]))) )  # not yet
            )
                #Vb->( status>=1+n 
                #        ? (status=0 ; vcat(Vb[1]...))    # enough recorded; reset status
                #        : (status>0 ? (status+=1; vcat(Vb[1]..., Any[(status-1,Vb[2])])) 
                #                    : vcat(Vb[1]...)) ) ) # not yet
end

get_n_blocks_by_code(b::Block, code::Int; n=1) = 
    get_n_blocks_by_codes(b, [code]; n=n)

#: ============================================

function get_blocks_max_by_codes(
    b::Block, 
    codes::Vector, 
    stop_codes::Vector; 
    n=800
    )
    status = 0
    function f(x)
        if is_single(x)
            @assert length(x.R[2])==1 
            if lookup_codes(x.R[2],codes)
                status = 1
            elseif lookup_codes(x.R[2],stop_codes)
                status = 0
            end
        end
        return
    end
    return DFS( b, 
                f, 
                x->nothing,
                Vb->(status==0 ? vcat(Vb[1]...) 
                               : (status+=1; vcat(Vb[1]..., Any[(status-1,Vb[2])])))  # not yet
            )
end

get_blocks_max_by_code(b::Block, code::Int, stop_code::Int; n=300) = 
    get_blocks_max_by_codes(b, [code], [stop_code]; n=n)

#: ============================================


function next_block_by_codes(b::Block, codes::Vector; delay=1)
    status = 0
    function f(x)
        if is_single(x)
            @assert length(x.R[2])==1 
            if lookup_codes(x.R[2],codes)
                status = 1
            end
        end
        return
    end
    return DFS( b, 
                f,
                x->nothing,
                Vb->( status==0 
                        ? vcat(Vb[1]...)    # hit; reset status and return 
                        : (status>=1+delay  ? (status=0;  Any[Vb[2],])
                                            : (status+=1; vcat(Vb[1]...)) ) )  # not yet
            )
                #Vb->( status>=1+delay 
                #        ? (status=0; Any[Vb[2],])    # hit; reset status and return 
                #        : (status>0 ? (status+=1; vcat(Vb[1]...)) 
                #                    : vcat(Vb[1]...)) ) ) # not yet
end

next_block_by_code(b::Block, code::Int; delay=1) = next_block_by_codes(b, [code]; delay=delay)


#: ============================================

comp(p1::TPattern,p2::TPattern) = (length(p1)==length(p2) && all(i->(p1[i]==p2[i]), 1:length(p1)))

lookup_patt(P::Vector{TPattern},patt::TPattern) = any(x->comp(patt,x),P)


function select_block_by_patt(
    b::Block{TR}, 
    patt::TPattern
    )::Vector{Block{TR}} where TR
    if lookup_patt(x.R[2],patt)  # R[2] = [[1,0,2],[23,24,25,1],...]
        return vcat([ select_block_by_patt(c,patt) 
                        for c in children(b) 
                            if lookup_patt(c.R[2],patt) ]...)
    else
        return Block{TR}[b,]
    end
end


function get_DATA_by_patt(
    b::Block{TR}, 
    patt::TPattern
    )::Vector{DATATYPE} where TR
    if  is_multi(b)  # R[2] = [[1,0,2],[23,24,25,1],...]
        return vcat([ get_DATA_by_patt(c,patt) 
                        for c in children(b) 
                            if lookup_patt(c.R[2],patt) ]...)
    elseif is_single(b) && lookup_patt(b.R[2],patt)
        return  DATATYPE[ b.DATA, ]
    else
        return  DATATYPE[  ]
    end
end
