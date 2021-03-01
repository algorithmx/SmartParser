#: ========================================================================
#global const __DEFAULT__R__ = (__DEFAULT_HASH_CODE__, TPattern[])  #+ modify
#global const __SIMILARITY_LEVEL__ = 0.9
#: ========================================================================

@inline processelemif(p,c,L) = for el ∈ L if c(el) p(el); end end

@inline exp_weighted(f,X) = mapreduce(i->exp(-i)*f(i), +, 1:X)/((1-exp(-X))/(ℯ-1))

@inline first_word_iden_weighted(f,X) = (f(1) ? exp_weighted(f,X) : 0.0)

#TODO optimize
function patt_similarity2(p1::TPattern, p2::TPattern)::Float64
    len1 = length(p1)
    len2 = length(p2)
    if len1==len2==0  return 1.0  end
    lmin = min(len1,len2)
    return (lmin==0 ? 0.0 : (first_word_iden_weighted(i->(p1[i]==p2[i]), lmin)))
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


good_label_crit(s)::Bool = (first(s[2])!=__M0_PATT__ && first(s[2])!=__PATT__all_number_line__)

# search substr in fullstr FROM THE RIGHTEST POSITION
function nonoverlapping(
    substr::Vector{TR}, 
    fullstr::Vector{TR}
    )::Vector{IntRange}  where  TR

    Nsub    = length(substr)
    sim_min = Nsub * __SIMILARITY_LEVEL__
    sim     = -1.0
    q       = -1
    posL    = length(fullstr)-Nsub+1
    R       = IntRange[]
    while posL >= 1
        q = -1
        # test similarity FROM THE RIGHTEST POSITION
        for p ∈ posL:-1:1
            if good_label_crit(fullstr[p])
                sim = similarity2(substr[1], fullstr[p])
                if sim<0.5
                    continue
                end
                # going down FROM THE RIGHTEST POSITION
                j = 2
                while (j<Nsub) && (sim<sim_min)
                    sim += similarity2(substr[j], fullstr[p+j-1])^2
                    if (sim+(Nsub-j)-1+1e-12<sim_min) 
                        # if, even the remaining part all matches exactly (sim+=1 for each)
                        # the sim value still below minimum
                        break
                    end
                    j += 1
                end
                if j==Nsub
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
    sortf1(x) = 10.0*length(x) - (first(last(x))/N)
    # most apperance >> longest range
    sortf2(x) = 100*length(x) + length(first(x))
    #+---------------------------------------------------

    RES = Vector{IntRange}[]
    B   = nothing
    lenBmax = -1
    for l=Lmin:min(Lmax,N÷2)
        U = Dict{Vector{TR},Int}()  # record the unique substrings by num of reps
        updU(i) = increaseindex!(U, str[i:i+l-1])  # dict for num of repetitions
        crit_i(i) = good_label_crit(str[i])
        processelemif(updU, crit_i, 1:N-l+1) ;
        all_blk_l = Vector{IntRange}[]
        max_len_B = -1
        lB = 0
        for (s,m) ∈ U
            if m>1
                B = nonoverlapping(s, str)
                lB = length(B)
                if lB>1 && lB>=max_len_B
                    max_len_B = lB
                    push!(all_blk_l, B)
                end
            end
        end
        if length(all_blk_l)>0
            #A = sort(all_blk_l, by=sortf1)
            #LASTB = last(A)
            LASTB = last(sort(all_blk_l, by=sortf1))
            if length(LASTB) < lenBmax
                # increasing the sub-pattern length l won't get longer nonoverlapping blocks B
                break  
            end
            #println("------ l = $l ----------")
            #[(println((length(A[k]),last(A[k]), str[last(A[k])])); 0)  for k=max(1,length(A)-10):length(A)]
            lenBmax = max(lenBmax, length(LASTB))
            push!(RES, LASTB)  # only record the best for each l
        end
    end
    return length(RES)==0 ? IntRange[] : last(sort(RES, by=sortf2))  # only return the best
end


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
