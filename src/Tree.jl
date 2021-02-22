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

import Base.copy
import Base.isequal

#: ------------  Block  -------------
abstract type Block <: AbstractTree end


#: ----------- Singleline -----------
mutable struct Singleline <: Block
    n::Int             # number of repetitions
    x::UnitRange{Int}  # 
    p::Vector{Int}     # pattern
    R::UInt64          # pattern hash
end
Singleline(patt::Vector{Int}, rg::UnitRange{Int}) = Singleline(length(rg), rg, patt, hash(patt))
Singleline(patt::Vector{Int}, i::Int) = Singleline(1, i:i, patt, hash(patt))
Singleline() = Singleline(0, 0:0, Int[], 0x0)

copy(s::Singleline) = Singleline(s.n, s.x, s.p, s.R)

isequal(s1::Singleline,s2::Singleline) = s1.n==s2.n && s1.R==s2.R


#: ----------- Multiline -----------
mutable struct Multiline <: Block
    n::Int             # number of repetitions
    x::UnitRange{Int}  # 
    R::UInt64          # pattern hash
    C::Vector          # children
end
Multiline() = Multiline(0,0:0,0x0,[])
function Multiline(C::Vector)
    @assert all([c isa Block for c in C])
    if length(C)==1  return C[1]  end
    rr = [t.x for t ∈ C]
    rconcat = concat(rr...)
    @assert sum(length.(rr)) == length(rconcat)
    T = Multiline(1, rconcat, 0x0, C)
    T.R = hash(T)
    return T
end

copy(s::Multiline) = Multiline(s.n, s.x, s.R, copy.(s.C))

isequal(s1::Singleline,c2::Multiline) = false
isequal(c1::Multiline,s2::Singleline) = false
isequal(c1::Multiline,c2::Multiline) = c1.n==c2.n && c1.R==c2.R

#: ----------- hash -----------
import Base.hash
hash(b::Singleline)::UInt64 = (b.R==0x0 ? hash(b.p) : b.R)
hash(b::Multiline)::UInt64 = (length(b.C)>0 ? (b.R==0x0 ? hash(hash.(b.C)) : b.R) : 0x0)

