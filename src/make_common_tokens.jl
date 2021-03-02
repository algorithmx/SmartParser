using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")
using SmartParser


function count_frequent_tokens(fns)
    stat = Dict{String,Int}()
    good_key(x) = !any(a->occursin(a,x), ["£",".", "\"", "*****","-----","%%%%%","+++++"])
    for f in fns
        if isfile(f)
            S0 = read(f,String) |> preprocess_raw_input
            MS0 = mask(S0)
            patts, code = tokenize0(MS0)
            codeinv = revert(code)
            for pt in patts
                for p in pt
                    ky = codeinv[p]
                    if p!=0 && good_key(ky)
                        increaseindex!(stat, ky)
                    end
                end
            end
        end
    end
    return stat
end

ALL_FILES = []

for RT ∈ ["/data/ReO3_phonon_configs","/data/ScF3_phonon_configs",]
    fns=vcat([[ "$RT/$fd/$ff/$fout" for ff in readdir("$RT/$fd") if isdir("$RT/$fd/$ff") 
                                        for fout in readdir("$RT/$fd/$ff") if endswith(fout,".out") ]
                                            for fd ∈ readdir(RT) if isdir("$RT/$fd") ]...)
    ALL_FILES = [ALL_FILES; fns]
end

##


STATS = count_frequent_tokens(ALL_FILES)
STATS_SORTV = sort([k=>v for (k,v) ∈ STATS if v>1], by=last) ;
L = length(STATS_SORTV)

##

CODE_ALL = Dict(k=>L-i+1 for (i,(k,v)) ∈ enumerate(STATS_SORTV)) ;
CODE_ALL |> print

##


for f in ALL_FILES
    try rm("$(f).replaced.1.txt") catch ; end
    try rm("$(f).replaced.2.txt") catch ; end
    try rm("$(f).replaced.3.txt") catch ; end
    try rm("$(f).replaced.4.txt") catch ; end
end

##