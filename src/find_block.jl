#: ====================== concat  =====================

concat0(a::IntRange) = a
concat0(a::IntRange,b::IntRange) = first(a):last(b)


##: ===================== helpers =====================

@inline function correct_R!(C::Vector{Block{TR}})  where TR
    for i=1:length(C)
        C[i].R = compute_label(C[i])
    end
    return
end

##: ============== elementary operation ================


function merge_conseq_iden_blocks(
    C::Vector{Block{TR}}
    )::Vector{Block{TR}}  where TR

    if length(C)==0   return []   end
    @assert is_valid_C(C)
    N   = length(C)
    C1  = Block{TR}[]
    T   = copy(C[1])
    pos = 2
    while pos<=N
        Cp = C[pos]
        h  = label(Cp)   #! was hash(Cp)
        if h != label(T)
            T.R = compute_label(T)
            push!(C1, T)
            T = copy(Cp)
            pos += 1
            continue
        else # if h == T.R
            #: merge / accumulate
            T.n += Cp.n
            #@assert last(T.x)+1==first(Cp.x)
            T.x = concat0(T.x, Cp.x)
            pos += 1
            continue
        end
    end
    T.R = compute_label(T)
    push!(C1,T)

    correct_R!(C1)
    @assert is_valid_C(C1)
    return C1
end


function fold_C_by_blks(
    C::Vector{Block{TR}}, 
    blocks::Vector{IntRange}
    )::Vector{Block{TR}}  where TR

    if length(blocks)==0 || length(C)==0  return C  end
    @assert is_valid_C(C)

    B  = Set(vcat(collect.(blocks)...))
    @assert length(B)==sum(length.(blocks)) "blocks=$(blocks) overlapping !!!" #!! FIXME 
    NC = length(C)
    C1 = Block{TR}[]

    i  = 1
    while i<=NC
        if i ∈ B
            ib = findfirst(x->i∈x, blocks)
            @assert i==first(blocks[ib])
            ML = Block(C[blocks[ib]])   #TODO ???
            push!(C1, ML)
            i = last(blocks[ib])+1
            for j ∈ blocks[ib]  delete!(B,j);  end
        else
            push!(C1, C[i])
            i += 1
        end
    end

    correct_R!(C1)
    return merge_conseq_iden_blocks(C1)
end


# correct the .x and .n field of M1 according to M
function correct_x_n!(M::Block{TR}, M1::Block{TR})::Block{TR} where TR
    @assert first(M1.x) == first(M.x)
    @assert is_valid_x(M)
    @assert all(is_valid_x.(children(M1)))
    @assert length(M1.x)*M.n == length(M.x)
    M1.n = M1.n * M.n
    M1.x = M.x
    M1.R = compute_label(M1)
    return M1
end


function fold_block(b::Block{TR}, blocks::Vector{IntRange})::Block{TR} where TR
    return (length(blocks)>0 
        ? correct_x_n!(b, Block(fold_C_by_blks(children(b), blocks))) 
        : b)
end


function merge_children(b::Block)::Block
    C = merge_conseq_iden_blocks(children(b))
    b1 = copy(b)
    b1.C = C[:]
    return b1
end

#: ----------- find blocks -----------

find_block(x::Block; block_identifier=MostFreqSubsq)::Block = (is_single(x) ? x : fold_block(x, block_identifier(label.(children(x)))))

# not used
#find_block_MostFreqSubsq(x::Block) = find_block(x; block_identifier=MostFreqSubsq)

find_block_MostFreqSimilarSubsq(x::Block) = find_block(x; block_identifier=MostFreqSimilarSubsq)

#: ----------- init blocks -----------


# assuming that each "logical block" is terminated by an empty line
function build_block_init(patts::Vector{TPattern})::Block{__RTYPE__}
    Q = empty_TPattern()   #  previous pattern
    S = Stack{Tuple{Int,Block{__RTYPE__}}}()
    L = 0   #  level
    for (i,p) ∈ enumerate(patts)
        if Q==Int[]  # previous line is empty
            L += 1   # increase level; next line is new block
        end
        #: enstack (level, pattern_i)
        push!(S, (L, Block(p,i)))
        if p==Int[]  # current line is empty
            if length(S)>0
                #: destack
                TMP  = Block{__RTYPE__}[]
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
                push!(S, (L, Block(merge_conseq_iden_blocks(TMP[end:-1:1]))))
            else  # stack is empty
                L = 0
            end
        end
        Q = p
        continue
    end

    # collect elements from stack bottom=1 --> top=n
    A = [last(s) for s in S][end:-1:1]
    return Block(merge_conseq_iden_blocks(A))
end


function typical_blocks(
    t::T;
    M = 2
    ) where {T <: Block}
    nl = []
    f(x) = (is_multi(x) && x.n>M ? (push!(nl,x); 0) : 0)
    DFS(t, f, identity)
    return sort(unique(nl),by=x->(-getfield(x,:n)))
end

