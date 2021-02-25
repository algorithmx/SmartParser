#: ========================================================================
#global const __DEFAULT__R__ = (__DEFAULT_HASH_CODE__, TPattern[])  #+ modify
#global const __SIMILARITY_LEVEL__ = 0.9
#: ========================================================================

avg(l) = sum(l)/length(l)

function patt_similarity(p1::TPattern, p2::TPattern, f=identity)
    len1 = length(p1)
    len2 = length(p2)
    lmin = min(len1,len2)
    return (len1==len2==0 ? 1.0 : f(avg(p1[1:lmin].==p2[1:lmin])))
end


similarity(a,b) = (a[1]==b[1] ? 1.0 : (length(a[2])!=length(b[2]) ? 0.0 : avg([patt_similarity(x,y) for (x,y) ∈ zip(a[2],b[2])])))


@inline function sim_each_char(s1::Vector{TR}, i1::Int, s2::Vector{TR}, i2::Int) where TR
    n1 = length(s1)
    j = 0 
    while j < n1
        if similarity(s1[i1+j], s2[i2+j]) < __SIMILARITY_LEVEL__   return false   end
        j += 1
    end
    return j==n1
end


similarity2(a,b) = (a[1]==b[1] ? 1.0 : (length(a[2])!=length(b[2]) ? 0.0 : avg([patt_similarity(x,y,a->a*a) for (x,y) ∈ zip(a[2],b[2])])))


@inline function sim_overall(s1::Vector{TR}, i1::Int, s2::Vector{TR}, i2::Int) where TR
    n1 = length(s1)
    sim = sum(Float64[similarity2(s1[i1+j], s2[i2+j])^4 for j=0:n1-1])
    return (sim > n1 * __SIMILARITY_LEVEL__)
end


good_label_crit(s) = (s[1]!=__M0_HASH__ && s[1]!=__HASH__all_number_line__)


function MostFreqSimilarSubsq(
    str::Vector{TR}; 
    Lmin=2, 
    Lmax=8
    )::Vector{IntRange} where TR

    N = length(str)
    if N<3 || allunique(str) 
        return IntRange[]
    end

    #+---------------------------------------------------
    # most apperance >> earliest appearance
    sortf1(x) = length(x) - (first(first(x))/N) #  
    # most apperance >> longest range 
    sortf2(x) = 1000*length(x) + length(first(x))  #  
    #+---------------------------------------------------
    RES = Vector{IntRange}[]
    B = nothing
    lenBmax = -1
    for l=Lmin:min(Lmax,N÷2)
        minL = min(2,l-1)
        U = Dict{Vector{TR},Int}()  # record the unique substrings by num of reps
        updU(i) = increaseindex!(U, str[i:i+l-1])  # dict for num of repetitions
        crit_i(i) = any(good_label_crit, str[i:i+l-1])
        processelemif(updU, crit_i, 1:N-l+1) ;
        all_blk_l = Vector{IntRange}[]
        for (s,m) ∈ U
            if m>1
                B = nonoverlapping(s, str, compare_func=sim_overall)
                if length(B)>1  push!(all_blk_l, B)  end
            end
        end
        if length(all_blk_l)>0
            #RES = [RES; all_blk_l]
            LASTB = last(sort(all_blk_l, by=sortf1))
            if length(LASTB) < lenBmax
                # increasing the sub-pattern length l won't get longer nonoverlapping blocks B
                break  
            end
            lenBmax = max(lenBmax, length(LASTB))
            #println( "----------  l = $l  length(LASTB) = $(length(LASTB)) ----------" )
            #@show str[first(LASTB)]
            push!(RES, LASTB)  # only record the best for each l
        end
    end
    return length(RES)==0 ? [] : last(sort(RES, by=sortf2))  # only return the best
end
