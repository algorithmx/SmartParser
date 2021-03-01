##: ------------------------------------------------
#: general tree  
##: ------------------------------------------------

abstract type AbstractTree end


function children(t::T)::Vector{T} where {T<:AbstractTree}
    return t.C
end


label(t::AbstractTree) = t.R


#: my favourite
function DFS(t::T, f::Function, g::Function, h::Function)::Any where {T <: AbstractTree}
    f(t)
    V = Any[DFS(c, f, g, h) for c ∈ children(t)]
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


function min_depth(t::T) where {T <: AbstractTree}
    return DFS(t, x->nothing, x->nothing, x->(length(x[1])==0 ? 0 : minimum(x[1])+1))
end


function collect_action_dfs(t::T, action::Function) where {T <: AbstractTree}
    return DFS( t,  x->nothing, 
                    x->nothing, 
                    x->vcat(x[1]...,Any[action(x[2]),]) )
end


function collect_action_bfs(t::T, action::Function) where {T <: AbstractTree}
    return DFS( t,  x->nothing, 
                    x->nothing, 
                    x->vcat(Any[action(x[2]),], x[1]...) )
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

import Base.copy
import Base.isequal

#: ------------  Block  -------------
mutable struct Block{TR} <: AbstractTree
    # number of repetitions
    n::Int
    # x
    # full range of the block
    x::IntRange 
    # p
    # pattern for signle-line
    # undef for multi-line
    p::TPattern
    # R 
    # identifier, can be pattern hash, or DFS traverse data
    R::TR
    # C 
    # children
    C::Vector{Block{TR}}
    # DATA
    # for single line, store extracted data, 
    # for multi line, empty
    # DATA is organized by parsee_File!() as follows
    # range => Vector{Pair{String,Any}}[...]
    # each v in [...] is a line of data from parsing single line
    DATA
end

copy(s::Block{TR}) where TR = Block{TR}(s.n, s.x, copy(s.p), copy(s.R), copy.(s.C), copy(s.DATA))

isequal(s1::Block{TR},s2::Block{TR}) where TR = (s1.n==s2.n && s1.R==s2.R)

is_multi(s::Block{TR}) where TR = length(s.C)>0

is_single(s::Block{TR}) where TR = length(s.C)==0

@inline patt_dfs(t::Block) = collect_action_dfs(t, x->(is_single(x) ? x.p : __M1_PATT__))

@inline patt_bfs(t::Block) = collect_action_bfs(t, x->(is_single(x) ? x.p : __M1_PATT__))

#: ----------- hash -----------

khash(b::Block)::UInt64 = (is_single(b) ? hash(b.p,UInt(b.n)) : hash(khash.(b.C),UInt(b.n)))

is_valid_C(C::Vector{Block{TR}}) where TR = (length(C)>0 ? mapreduce(c->length(getfield(c,:x)), +, C)==length(concat0(C[1].x,C[end].x)) : true)

is_valid_x(M) = (is_single(M) ? length(M.x)==M.n : length(M.x)==M.n*sum([length(z.x) for z ∈ children(M)]))

function verify_block(b::Block{TR})::Bool where TR
    function h(x::Tuple{Vector,Block{TR}})
        if ! is_valid_x(x[2])
            @show x[2]
            return false
        else
            return all(x[1])
        end
    end
    DFS(b, x->nothing, x->nothing, h)
end

is_valid_block(b::Block{TR}) where TR = is_valid_C(children(b)) && verify_block(b)


#+ ========= compute_label ==========

compute_label(b::Block) = (khash(b), patt_dfs(b))

#+ ==================================

function Block(patt::TPattern, rg::IntRange)::Block{__RTYPE__}
    b = Block{__RTYPE__}(length(rg), rg, patt, __DEFAULT__R__, Block{__RTYPE__}[], [])
    b.R = compute_label(b)
    return b
end


Block(patt::TPattern, i::Int)::Block{__RTYPE__} = Block(patt, i:i)


Block()::Block{__RTYPE__} = Block(__DEFAULT_PATT__, 0)


function Block(C::Vector{Block{RT}})::Block{RT} where RT
    if length(C)==1  return C[1]  end
    rconcat = concat0(C[1].x, C[end].x)
    b = Block{RT}(1, rconcat, __DEFAULT_PATT__, __DEFAULT__R__, C, [])
    b.R = compute_label(b)
    return b
end
