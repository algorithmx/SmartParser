##: ------------------------------------------------
#: general tree  
##: ------------------------------------------------

abstract type AbstractTree end


function children(t::AbstractTree)
    if hasfield(typeof(t),:C)
        return t.C
    else
        return []
    end
end


function label(t::AbstractTree)
    if hasfield(typeof(t),:R)
        return t.R
    else
        return nothing
    end
end


#: my favourite
function DFS(t::T, f::Function, g::Function, h::Function) where {T <: AbstractTree}
    f(t)
    V = [DFS(c, f, g, h) for c ∈ children(t)]
    g(t)
    return h((V,t))
end


@inline DFS(t::T, f::Function, g::Function) where {T <: AbstractTree} = DFS(t, f, g, identity)


@inline DFS(t::T, f::Function) where {T <: AbstractTree} = DFS(t, f, identity, identity)


function num_nodes(t::T) where {T <: AbstractTree} 
    tot = 0
    DFS(t, x->(tot+=1; 0))
    return tot
    #return 1 + sum(Int[num_nodes(i) for i in children(t)])
end


function max_depth(t::T) where {T <: AbstractTree}
    return DFS(t, x->nothing, x->nothing, x->(length(x[1])==0 ? 0 : maximum(x[1])+1))
end

function collect_action_dfs(t::T, action::Function) where {T <: AbstractTree}
    return DFS(t, x->nothing, x->nothing, x->(length(x[1])==0 ? [action(x[2]),] : vcat(x[1]...,[action(x[2]),])))
end

function collect_action_bfs(t::T, action::Function) where {T <: AbstractTree}
    return DFS(t, x->nothing, x->nothing, x->(length(x[1])==0 ? [action(x[2]),] : vcat([action(x[2]),], x[1]...)))
end

function tree_print(
    t::T; 
    propfunc=label,
    colfunc=x->(255,255,255),
    header=y->repeat("|--",max(0,y)),
    offset=0
    ) where {T <: AbstractTree}

    println_rgb(rgb_t) = (print("\e[1m\e[38;2;91;91;91;249m",rgb_t[2]);
                          println("\e[1m\e[38;2;$(rgb_t[1][1]);$(rgb_t[1][2]);$(rgb_t[1][3]);249m",rgb_t[3]);)
    nl = []
    level = [offset,]
    @inline s2s(x) = ((x isa Symbol) ? ":"*string(x) : string(x))
    f(x) = (push!(nl, [colfunc(x), header(level[end]), s2s(propfunc(x))]); push!(level,level[end]+1); 0)
    g(x) = (pop!(level); 0)

    DFS(t, f, g)

    println_rgb.(nl)
    return nothing
end


##: ------------------------------------------------
#: specially designed tree 
##: ------------------------------------------------

TPattern = Vector{Int}
# reserved token 999999999 for all number line
# used by tokenize
global const __patt__all_number_line__ = [999999999]

import Base.copy
import Base.isequal

#: ------------  Block  -------------
mutable struct Block{TR} <: AbstractTree
    n::Int                # number of repetitions
    x::UnitRange{Int}     # 
    p::TPattern           # pattern
    R::TR                 # identifier, can be pattern hash, or DFS traverse data
    C::Vector{Block{TR}}
    DATA
end

copy(s::Block{TR}) where TR = Block{TR}(s.n, s.x, copy(s.p), copy(s.R), copy.(s.C), copy(s.DATA))

isequal(s1::Block{TR},s2::Block{TR}) where TR = (s1.n==s2.n && s1.R==s2.R)

is_multi(s::Block{TR}) where TR = length(s.C)>0

is_single(s::Block{TR}) where TR = length(s.C)==0

#: ----------- hash -----------

import Base.hash

hash(b::Block)::UInt64 = (is_single(b) ? (b.R==0x00 ? hash(b.p) : b.R) : (b.R==0x00 ? hash(hash.(b.C)) : b.R))
khash(b::Block)::UInt64 = (is_single(b) ? hash(b.p) : hash(hash.(b.C)))


#+ ======== compute_label ========

compute_label(b::Block) = khash(b)

#+ ============================

global const __DEFAULT__R__ = UInt64(0x0)
global const __DEFAULT__RTYPE__ = typeof(__DEFAULT__R__)
global const __DEFAULT_PATT__ = Int[]


function Block(patt::TPattern, rg::UnitRange{Int})
    b = Block{__DEFAULT__RTYPE__}(length(rg), rg, patt, __DEFAULT__R__, Block{__DEFAULT__RTYPE__}[], [])
    b.R = compute_label(b)
    return b
end


Block(patt::TPattern, i::Int) = Block(patt, i:i)


Block() = Block(__DEFAULT_PATT__, 0)


function Block(C::Vector{Block{RT}}) where RT
    if length(C)==1  return C[1]  end
    rconcat = concat0(C[1].x, C[end].x)
    b = Block{RT}(1, rconcat, __DEFAULT_PATT__, __DEFAULT__R__, C, [])
    b.R = compute_label(b)
    return b
end
