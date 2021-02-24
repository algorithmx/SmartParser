#: ----------- concat -----------
concat0(a::UnitRange{Int}) = a
concat0(a::UnitRange{Int},b::UnitRange{Int}) = first(a):last(b)

##: ----------- helpers -----------

@inline function correct_hash!(C::Vector)
    for i=1:length(C)
        C[i].R = 0x0
        C[i].R = hash(C[i])
    end
    return
end

#@inline is_valid_C_oldver(C::Vector) = all([(c isa Block) for c ∈ C]) && all([last(C[i].x)+1==first(C[i+1].x) for i=1:length(C)-1])
#@inline is_valid_C(C::Vector) = sum(Int[length(c.x) for c in C])==concat0(C[1].x,C[end].x)
@inline is_valid_C(C::Vector) = mapreduce(c->length(getfield(c,:x)), +, C)==length(concat0(C[1].x,C[end].x))

# 
function merge_conseq_iden_blocks(C::Vector)::Vector
    if length(C)==0   return []   end
    @assert is_valid_C(C)
    N   = length(C)
    C1  = Block[]
    T   = copy(C[1])
    pos = 2
    while pos<=N
        Cp = C[pos]
        h  = hash(Cp)
        if h != T.R
            T.R = 0x0
            T.R = hash(T)
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
    T.R = 0x0
    T.R = hash(T)
    push!(C1,T)
    correct_hash!(C1)
    @assert is_valid_C(C1)
    return C1
end


function fold_C_by_blks(C::Vector, blocks::Vector{UnitRange{Int}})::Vector

    if length(blocks)==0 || length(C)==0  return C  end

    #:  @assert is_valid_C(C)
    B  = Set(vcat(collect.(blocks)...))
    @assert length(B)==sum(length.(blocks)) "blocks=$(blocks) overlapping !!!" #!! FIXME 
    NC = length(C)
    C1 = Block[]

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

# correct the .x and .n field of M1 according to M
function correct_x_n(M,M1)
    @assert first(M1.x) == first(M.x)
    ##//if M.n>1  @info "M1.x=$(M1.x) , M.x=$(M.x) , M.n=$(M.n)"  end
    @assert length(M1.x)*M.n == length(M.x)
    M2 = copy(M1)
    M2.n = M1.n * M.n
    M2.x = M.x
    M2.R = 0x0
    M2.R = hash(M2)
    return M2
end


fold_block(b::Multiline, blocks::Vector{UnitRange{Int}})::Multiline = (length(blocks)>0 
        ? correct_x_n(b, Multiline(fold_C_by_blks(children(b), blocks))) 
        : b)

fold_block_MFS(x::Singleline) = x

fold_block_MFS(x::Multiline) = fold_block(x, MFS(label.(children(x))))


#: ----------- find blocks -----------

find_block(b::Singleline) = b


function find_block(b0::Multiline)::Multiline
    b = fold_block_MFS(copy(b0))
    b.C = find_block.(b.C)
    return b
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
                TMP  = Block[]
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
    return sort(unique(nl),by=x->-getfield(x,:n))
end


