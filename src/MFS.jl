
#+ shorter !
function MFS(str::Vector{UInt64}; Lmin=2, Lmax=80)::Vector{UnitRange{Int}}
    if allunique(str)  return []  end
    # findall the elements l in L satisfying c(l)==true and have unique value of u(l), then map f() to them
    @inline processelemif(p,c,L) = ([(p(el); nothing) for el ∈ L if c(el)] ; nothing)
    @inline len1p(L) = L[length.(L).>1]

    N = length(str)
    # most apperance >> longest range >> latest appearance
    sortf(x) = 100000*length(x) + length(x[1]) + 0.8*x[1][1]/N  
    RES = []
    for l=Lmin:min(Lmax,N÷2)
        U = Dict{Vector{UInt64},Int}()
        updU(i) = ((str[i:i+l-1] ∈ keys(U)) ? U[str[i:i+l-1]]+=1 : U[str[i:i+l-1]]=1)  #: dict for num of repetitions
        processelemif(updU, i->length(unique(str[i:i+l-1]))>min(2,l-1), 1:N-l+1) ;  #: record the unique substrings by num of reps
        all_blk_l = [nonoverlapping(s,str) for (s,m) ∈ U if m>1] |> len1p  #: if s has repeated (m>1) then useful
        if length(all_blk_l)>0
            push!(RES, last(sort(all_blk_l, by=sortf)))  #: only record the best for each l
        end
    end
    return RES==[] ? [] : last(sort(RES, by=sortf))
end

#
#t1 = UInt64[rand(1:1000,2000); [1, 2,3, 4, 2,3, 2,3, 4]; rand(1:1000,2000)] ;
#comps(t2, 1, t1, 2)
#comps(t2, 1, t1, 4)
#nonoverlapping(t2,t1)
#nonoverlapping(t1[rep[1]], t1)
#@time rep = MFS(t1,Lmax=100)
#@time rep1 = MFSv1(t1)

