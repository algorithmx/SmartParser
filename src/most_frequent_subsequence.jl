# findall the elements l in L satisfying c(l)==true and have unique value of u(l), then map f() to them
@inline processelemif(p,c,L) = for el ∈ L if c(el) p(el); end end

# see line *1 in tokenize.jl
#+ TODO it is wrong 
#non_empty_non_999999999(s) = (length(s)>1 || !(isempty(s) || s==__PATT__all_number_line__))
non_empty_non_999999999(s) = (s!=__M0_HASH__ && s!=__HASH__all_number_line__)

function MostFreqSubsq(str::Vector{UInt64}; Lmin=2, Lmax=80)::Vector{IntRange}
    if allunique(str)  return []  end

    N = length(str)
    # most apperance >> longest range >> earliest appearance
    sortf(x) = 100000*length(x) + length(x[1]) + (0.8*x[1][1]/N)
    RES = Vector{IntRange}[]
    B = nothing
    for l=Lmin:min(Lmax,N÷2)
        minL = min(2,l-1)
        U = Dict{Vector{UInt64},Int}()
        # updU(i) = ((str[i:i+l-1] ∈ keys(U)) ? U[str[i:i+l-1]]+=1 : U[str[i:i+l-1]]=1)  
        updU(i) = increaseindex!(U, str[i:i+l-1])  # dict for num of repetitions  #: improved 2x faster
        # record the unique substrings by num of reps
        # see line *1 in tokenize.jl
        #crit_i = i->length(unique(str[i:i+l-1]))>minL  # non-optimal version 
        crit_i(i) = any(non_empty_non_999999999, str[i:i+l-1]) #: optimized, 3x faster
        processelemif(updU, crit_i, 1:N-l+1) ;  
        all_blk_l = Vector{IntRange}[]
        for (s,m) ∈ U
            if m>1
                B = nonoverlapping(s,str)
                if length(B)>1  push!(all_blk_l,B)  end
            end
        end
        if length(all_blk_l)>0
            #: only record the best for each l
            push!(RES, last(sort(all_blk_l, by=sortf)))
        end
    end
    return length(RES)==0 ? [] : last(sort(RES, by=sortf))
end


##


#t1 = UInt64[rand(1:1000,2000); [1, 2,3, 4, 2,3, 2,3, 4]; rand(1:1000,2000)] ;
#comp_each_char(t2, 1, t1, 2)
#comp_each_char(t2, 1, t1, 4)
#nonoverlapping(t2,t1)
#nonoverlapping(t1[rep[1]], t1)
#@time rep = MostFreqSubsq(t1,Lmax=100)
#@time rep1 = MostFreqSubsqv1(t1)

