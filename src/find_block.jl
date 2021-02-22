
#: ----------- concat -----------
concat(a::UnitRange{Int}) = a
concat(a::UnitRange{Int},b::UnitRange{Int}) = first(a):last(b)
concat(a::UnitRange{Int},b::UnitRange{Int},c...) = concat(concat(a,b),c...)



##: ----------- helpers -----------


@inline function correct_hash!(C::Vector)
    for i=1:length(C)
        C[i].R = 0x0
        C[i].R = hash(C[i])
    end
    return
end


@inline is_valid_C(C::Vector) = all([(c isa Block) for c ∈ C]) && all([last(C[i].x)+1==first(C[i+1].x) for i=1:length(C)-1])


# 
function merge_conseq_iden_blocks(C::Vector)
    @assert is_valid_C(C)
    N   = length(C)
    C1  = []
    T   = deepcopy(C[1])
    pos = 2
    while pos<=N
        Cp = C[pos]
        h  = hash(Cp)
        if h != T.R
            T.R = 0x0
            T.R = hash(T)
            push!(C1, T)
            T = deepcopy(Cp)
            pos += 1
            continue
        else # if h == T.R
            #: merge / accumulate
            T.n += Cp.n
            @assert last(T.x)+1==first(Cp.x)
            T.x = concat(T.x, Cp.x)
            pos += 1
            continue
        end
    end

    T.R = 0x0
    T.R = hash(T)
    push!(C1,T)

    correct_hash!(C1)
    @assert is_valid_C(C1)
    return C1

end


function fold_C_by_blks(C::Vector, blocks::Vector{UnitRange{Int}})

    if length(blocks)==0  return C  end

    @assert is_valid_C(C)

    B  = Set(vcat(collect.(blocks)...))
    @assert length(B)==sum(length.(blocks)) "blocks=$(blocks) overlapping !!!" #!! FIXME 

    NC = length(C)
    C1 = []

    i  = 1
    while i<=NC
        if i ∈ B
            ib = findfirst(x->i∈x, blocks)
            @assert i == first(blocks[ib])
            ML = Multiline(merge_conseq_iden_blocks(C[blocks[ib]]))  #TODO ???
            push!(C1, ML)
            i = last(blocks[ib])+1
            for j ∈ blocks[ib]  delete!(B,j);  end
        else
            push!(C1, C[i])
            i += 1
        end
    end

    correct_hash!(C1)

    return merge_conseq_iden_blocks(C1)
end


function loop_until_stable__(M0::Multiline, f::Function)
    M = deepcopy(M0)
    R = M.R
    M = f(M)
    while R != M.R
        R = M.R
        M = f(M)
        M.R = 0x0
        M.R = hash(M)
    end
    return M
end


# correct the .x and .n field of M1 according to M
function correct_x_n(M,M1)
    @assert first(M1.x) == first(M.x)
    if M.n>1  @info "M1.x=$(M1.x) , M.x=$(M.x) , M.n=$(M.n)"  end
    @assert length(M1.x)*M.n == length(M.x)
    M2 = deepcopy(M1)
    M2.n = M1.n * M.n
    M2.x = M.x
    M2.R = 0x0
    M2.R = hash(M2)
    return M2
end


fold_block(b::Multiline, blocks) = (length(blocks)>0 ? correct_x_n(b, Multiline(fold_C_by_blks(children(b), blocks))) : b)


#: ----------- find blocks -----------


function patterns_from_children(CD::Vector)
    H  = hash.(CD)
    unique_chn_patts = unique([hash.(children(c)) for c in CD if (c isa Multiline)])
    if length(unique_chn_patts)==0  return []  end
    blocks = [nonoverlapping(p,H) for p ∈ unique_chn_patts]
    ass = sortperm(blocks, by=length)
    return blocks[last(ass)]
end


restructure_children(b::Singleline) = b


restructure_children(b::Multiline) = fold_block(b, patterns_from_children(children(b)))


find_block(b::Singleline) = b


function find_block(b0::Multiline)
    b = restructure_children(deepcopy(b0))

    for i=1:length(children(b))
        b.C[i] = loop_find_block_until_stable(b.C[i])
    end

    b.R = 0x0
    b.R = hash(b)

    L(x) = fold_block(x, MFS(label.(children(x))))
    return loop_until_stable__(b, L)
end


loop_find_block_until_stable(M::Singleline) = M


loop_find_block_until_stable(M::Multiline) = loop_until_stable__(M, find_block)


#: ---------- correct 1_1 ------------


correct_1_1(b0::Singleline) = b0


function correct_1_1(b0::Multiline)
    maxd = max_depth(b0)
    if length(children(b0))==0 || maxd<2
        return b0
    elseif b0.n==1
        if maxd >= 2
            b   = deepcopy(b0)
            C   = vcat([((c isa Multiline) && (c.n==1) ? children(c) : [c,]) for c ∈ children(b)]...) .|> correct_1_1
            #@show [c.x for c in C]
            b.C = merge_conseq_iden_blocks(C)
            return correct_x_n(b0,b)
        else
            return b0
        end
    else
        return b0
    end
end


#: ----------- init blocks -----------


# assuming that each "logical block" is terminated by an empty line
function build_block_init(patts::Vector{Vector{Int}})

    Q = Int[]   #  previous pattern
    S = Stack{Tuple{Int,Block}}()
    L = 0   #  level

    for (i,p) ∈ enumerate(patts)
        if Q==Int[]  # previous line is empty
            L += 1   # increase level; next line is new block
        end

        #: enstack (level, pattern_i)
        push!(S, (L, Singleline(p,i)))
        
        if p==Int[]  # current line is empty
            if length(S)>0
                #: destack
                TMP  = []
                while length(S)>0 && top(S)[1]==L
                    t = pop!(S)
                    push!(TMP, t[2])
                end
                if length(S)>0
                    L = top(S)[1]
                else
                    L = 0
                end

                #: make Multiline (a tree) and enstack
                push!(S, (L, Multiline(merge_conseq_iden_blocks(TMP[end:-1:1]))))

            else  # stack is empty
                L = 0
            end
        end
        Q = p
        continue
    end

    # collect elements from stack bottom=1 --> top=n
    A = [last(s) for s in S][end:-1:1]

    return Multiline(merge_conseq_iden_blocks(A))

end


function typical_blocks(
    t::T;
    M = 2
    ) where {T <: Block}
    nl = []
    f(x) = ((x isa Multiline) && x.n>M ? (push!(nl,x); 0) : 0)
    DFS(t, f, identity)
    return sort(nl,by=x->-getfield(x,:n))
end


