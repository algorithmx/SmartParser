#: ========================================================================
#global const __DEFAULT__R__ = (__DEFAULT_HASH_CODE__, TPattern[])  #+ modify
#global const __SIMILARITY_LEVEL__ = 0.9
#: ========================================================================

@inline processelemif(p,c,L) = for el ∈ L if c(el) p(el); end end

global const exp_m_i = [exp(-i) for i=1:100]
global const coeff_norm = [1.0/((1-exp(-i))/(ℯ-1)) for i=1:100]

#@inline exp_weighted(f,X::Int) = coeff_norm[X]*mapreduce(i->exp_m_i[i]*f(i), +, 1:X)
#@inline exp_weighted(f,X::Int) = coeff_norm[X]*sum([exp_m_i[i]*f(i) for i=1:X])
function exp_weighted(f::Function,X::Int)
    s = 0.0
    for i=1:X
        @inbounds s += exp_m_i[i]*f(i)
    end
    return coeff_norm[X]*s
end

@inline first_elem_iden_weighted(f,X::Int) = (f(1) ? exp_weighted(f,X) : 0.0)

@inline last_elem_sim_weighted(f,X::Int) = (f(X)>0.8 ? exp_weighted(f,X) : 0.0)


#TODO optimize
function patt_similarity2(p1::TPattern, p2::TPattern)::Float64
    len1 = length(p1)
    len2 = length(p2)
    if len1==len2==0  return 1.0  end
    lmin = min(len1,len2)
    return (lmin==0 ? 0.0 : (first_elem_iden_weighted(i->(p1[i]==p2[i]), lmin)))
end


#TODO optimize
function similarity2(a,b)::Float64
    if a[1]==b[1]
        return 1.0
    else
        N = length(a[2])
        if N!=length(b[2])
            return 0.0
        else
            return exp_weighted(i->patt_similarity2(a[2][i],b[2][i]), N)
        end
    end
end


##
#p1 = (:x,TPattern[[13, 0, 0, 0, 0, 0, 0], [14, 15, 0], [16, 17, 18, 19], [20, 21, 0], [-1]])
#p2 = (:y,TPattern[[22, 0, 0, 23], [14, 15, 0], [16, 17, 18, 19], [20, 21, 0], [-1]])
#similarity2(p1,p2)
#patt_similarity2([13, 0, 0, 0, 0, 0, 0],[22, 0, 0, 23])
#patt_similarity2([10, 11, 0, 12],[10, 11, 0, 0, 18, 19, 20, 17, 21, 22])^2
##

function good_label_crit(q::Int, A::Vector)::Bool
    if length(A[q][2][1])>1  return true  end
    return !(@inbounds A[q][2][1]==__M0_PATT__::TPattern || A[q][2][1]==__PATT__all_number_line__::TPattern)
end

# search substr in fullstr FROM THE RIGHTEST POSITION
function nonoverlapping(
    substr::Vector{TR}, 
    fullstr::Vector{TR},
    fullstr_good_pos::Vector{Bool}
    )::Vector{IntRange}  where  TR

    Nsub    = length(substr)
    sim_min = Nsub * __SIMILARITY_LEVEL__
    sim     = -1.0
    q       = -1
    posL    = length(fullstr)-Nsub+1
    R       = IntRange[]
    j       = -1
    while posL >= 1
        q = -1
        # test similarity FROM THE RIGHTEST POSITION
        for p ∈ posL:-1:1
            #if good_label_crit(p,fullstr)
            if fullstr_good_pos[p]
                @inbounds sim = similarity2(substr[1], fullstr[p]) + similarity2(substr[Nsub], fullstr[p+Nsub-1])
                if sim<1.5 || similarity2(fullstr[p], fullstr[p+Nsub-1])>0.4
                    # if first and last pattern doesn't match at high fidelity
                    # or the first and last in the fullstr to be matched are too similar
                    continue
                end
                # going FROM THE LEFTEST POSITION
                # j = 2 to Nsub-1
                j = 2
                while (j<Nsub-1) && (sim<sim_min)
                    @inbounds sim += similarity2(substr[j], fullstr[p+j-1])
                    if (sim+(Nsub-j)-2+1e-12<sim_min)
                        # if, even the remaining part all matches exactly (sim+=1 for each)
                        # the sim value still below minimum
                        break
                    end
                    j += 1 # going FROM THE LEFTEST POSITION
                end
                if j==Nsub-1
                    # the above while loop reaches the end
                    # overall similarity larger than fixed level
                    q = p
                    push!(R, q:q+Nsub-1)
                    posL = q-Nsub
                    break
                end
            end
        end
        if q < 0
            break
        end
    end
    return R
end



function MostFreqSimilarSubsq(
    str::Vector{TR}; 
    # meaning of Lmin and Lmax :
    # min and max lengths of the pattern for 
    # a group of blocks
    # experiments show that Lmin=3 is efficient for QE files
    Lmin=3,   
    Lmax=20
    )::Vector{IntRange} where TR

    N = length(str)
    if N<3 || allunique(str) 
        return IntRange[]
    end

    #+------------- lift the "degenereacy" --------------
    # most apperance >> earliest appearance
    sortf1(x) = length(x) - (first(last(x))/N)
    # most apperance >> longest range
    sortf2(x) = 10*length(x) + length(first(x))
    function crit_i_l(i::Int, l::Int)
        if length(str[i][2][1])>1   return true   end
        @inbounds cnd = (str[i][2][1]==__M0_PATT__::TPattern || str[i][2][1]==__PATT__all_number_line__::TPattern)
        if cnd
            return false
        else
            return (@inbounds similarity2(str[i],str[i+l-1])<0.5)
        end
    end
    #+---------------------------------------------------

    good_p_label= Bool[good_label_crit(i,str) for i=1:N]
    RES         = Vector{IntRange}[]
    B           = nothing
    lenLASTBmax = -10

    all_blk_l   = Vector{IntRange}[]
    max_len_B   = -1
    curr_len_B  = 0
    lB          = 0
    for l=Lmin:min(Lmax,N÷2)
        U = Dict{Vector{TR},Int}()  # record the unique substrings by num of reps
        updU(i::Int) = (@inbounds increaseindex!(U, str[i:i+l-1]))  # dict for num of repetitions
        crit_i(i::Int) = crit_i_l(i, l)
        @inbounds processelemif(updU, crit_i, 1:N-l+1) ;

        all_blk_l  = Vector{IntRange}[]
        max_len_B  = 2
        curr_len_B = 0
        lB         = 0
        for (s,m) ∈ U
            if m>1
                B  = nonoverlapping(s, str, good_p_label)
                lB = length(B)
                if lB>=max_len_B
                    max_len_B = lB
                    push!(all_blk_l, B)
                end
            end
        end
        if max_len_B < lenLASTBmax  # increasing the sub-pattern length l 
            break  # won't get longer nonoverlapping blocks B
        end
        if length(all_blk_l)>0
            (_,_i) = findmax(sortf1.(all_blk_l))
            lenLASTBmax = max(lenLASTBmax, length(all_blk_l[_i]))
            push!(RES, all_blk_l[_i])  # only record the best for each l
        end
    end
    if length(RES)==0  return IntRange[]  end
    # only return the best
    (_,_i) = findmax(sortf2.(RES))
    return RES[_i]
end

#=

function MostFreqSimilarSubsq_test_ver(
    str::Vector{TR}; 
    # meaning of Lmin and Lmax :
    # min and max lengths of the pattern for 
    # a group of blocks
    # experiments show that Lmin=3 is efficient for QE files
    Lmin=3,   
    Lmax=20
    )::Vector{IntRange} where TR

    N = length(str)
    if N<3 || allunique(str) 
        return IntRange[]
    end

    #+------------- lift the "degenereacy" --------------
    # most apperance >> earliest appearance
    sortf1(x) = length(x) - (first(last(x))/N)
    # most apperance >> longest range
    sortf2(x) = 10*length(x) + length(first(x))
    #+---------------------------------------------------

    RES = Vector{IntRange}[]
    B   = nothing
    lenLASTBmax = -10
    all_blk_l = Vector{IntRange}[]
    max_len_B  = -1
    curr_len_B = 0
    lB  = 0
    sortf1_val = 0.0
    for l=Lmin:min(Lmax,N÷2)
        #println("------ l = $l ----------")
        U = Dict{Vector{TR},Int}()  # record the unique substrings by num of reps
        updU(i)   = (@inbounds increaseindex!(U, str[i:i+l-1]))  # dict for num of repetitions
        crit_i(i) = (@inbounds  good_label_crit(str[i]) && similarity2(str[i],str[i+l-1])<0.5)
        processelemif(updU, crit_i, 1:N-l+1) ;

        all_blk_l = Vector{IntRange}[]
        max_len_B = 2
        curr_len_B = 0
        lB = 0
        for (s,m) ∈ U
            if m>1
                B  = nonoverlapping(s, str)
                lB = length(B)
                #if lB>1 && lB>=max_len_B
                if lB>=max_len_B
                    max_len_B = lB
                    push!(all_blk_l, B)
                end
            end
        end
        if max_len_B < lenLASTBmax
            # increasing the sub-pattern length l 
            # won't get longer nonoverlapping blocks B
            break
        end
        if length(all_blk_l)>0
            #A = sort(all_blk_l, by=sortf1)
            #LASTB = last(A)
            #LASTB = last(sort(all_blk_l, by=sortf1))
            #@assert max_len_B==length(LASTB)
            (_,LASTB_i) = findmax(sortf1.(all_blk_l))
            curr_len_B = length(all_blk_l[LASTB_i])
            @assert max_len_B==curr_len_B
            #[(println((length(A[k]),last(A[k]), str[last(A[k])])); 0)  for k=max(1,length(A)-10):length(A)]
            #lenLASTBmax = max(lenLASTBmax, length(LASTB))
            lenLASTBmax = max(lenLASTBmax, curr_len_B)
            #push!(RES, LASTB)  # only record the best for each l
            push!(RES, all_blk_l[LASTB_i])  # only record the best for each l
        end
    end
    return length(RES)==0 ? IntRange[] : last(sort(RES,by=sortf2))  # only return the best
end

# use heap , #! slow
function MostFreqSimilarSubsq_heap_ver(
    str::Vector{TR}; 
    # meaning of Lmin and Lmax :
    # min and max lengths of the pattern for 
    # a group of blocks
    # experiments show that Lmin=3 is efficient for QE files
    Lmin=3,   
    Lmax=20
    )::Vector{IntRange} where TR

    N = length(str)

    if N<3 || allunique(str) 
        return IntRange[]
    end

    #+------------- lift the "degenereacy" --------------
    # most apperance >> longest range >> earliest appearance
    sortf3(x::Vector{IntRange}) = -(2Lmax*length(x) + length(first(x)) - (first(last(x))/N))
    #+---------------------------------------------------

    B        = nothing
    l_B_max  = -10
    lB       = 0
    blk_H    = BinaryHeap(Base.By(sortf3), Vector{IntRange}[])
    for l=Lmin:min(Lmax,N÷2)
        l_B_max_at_l = -1
        U = Dict{Vector{TR},Int}()  # record the unique substrings by num of reps
        updU(i::Int)   = (@inbounds increaseindex!(U, str[i:i+l-1]))  # dict for num of repetitions
        crit_i(i::Int) = (@inbounds  (good_label_crit(str[i]) && similarity2(str[i],str[i+l-1])<0.5))
        processelemif(updU, crit_i, 1:N-l+1) ;

        lB = 0
        for (s,m) ∈ U
            if m>1
                B  = nonoverlapping(s, str)
                lB = length(B)
                if lB>1 && lB>=l_B_max_at_l
                    l_B_max_at_l = lB
                    push!(blk_H, B)
                end
            end
        end
        if l_B_max_at_l < l_B_max
            # increasing the sub-pattern length l 
            # won't get longer nonoverlapping blocks B
            break
        end
    end
    return length(blk_H)==0 ? IntRange[] : first(blk_H)  # only return the best
end

=#


#=

# not used
avg(l) = sum(l)/length(l)

# not used
function patt_similarity(p1::TPattern, p2::TPattern, f=identity)::Float64
    len1 = length(p1)
    len2 = length(p2)
    lmin = min(len1,len2)
    return (len1==len2==0 ? 1.0 : f(avg(p1[1:lmin].==p2[1:lmin])))
end

# not used
similarity(a,b)::Float64 = (a[1]==b[1] ? 1.0 : (length(a[2])!=length(b[2]) ? 0.0 : avg([patt_similarity(x,y) for (x,y) ∈ zip(a[2],b[2])])))

# not used
function sim_each_char(s1::Vector{TR}, i1::Int, s2::Vector{TR}, i2::Int)::Bool where TR
    n1 = length(s1)
    j = 0 
    while j < n1
        if similarity(s1[i1+j], s2[i2+j]) < __SIMILARITY_LEVEL__   return false   end
        j += 1
    end
    return j==n1
end

=#
