using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")
using SmartParser

function build_structure_tree(fn)
    lines, lines1, patts, code = load_file(fn) ;
    if length(lines)==0
        return String[], String[], Multiline(), code
    end
    B = build_block_init(patts) ;
    B  = find_block_MostFreqSimilarSubsq(B) ;
    return lines, lines1, B, code
end


for RT ∈ ["/data/ReO3_phonon_configs","/data/ScF3_phonon_configs",]
    fns=vcat([[ "$RT/$fd/$ff/$fout" for ff in readdir("$RT/$fd") if isdir("$RT/$fd/$ff") 
                                        for fout in readdir("$RT/$fd/$ff") if endswith(fout,".out") ]
                                            for fd ∈ readdir(RT) if isdir("$RT/$fd") ]...)
    DATA = []
    skip = [""]
    for fn in fns
        if fn ∉ skip
            @info fn
            lines, lines1, B, code = build_structure_tree(fn) ;
            codeinv = revert(code) ;
            BD = parse_file(0, B, lines, lines1, codeinv) ;
            push!(DATA, (BD, B, code, codeinv, lines, lines1))
            NL = block_print(B, lines1, offset=0, mute=true) ;
            open("$(fn).replaced.txt","w") do f
                write(f,join(NL,"\n"))
            end
        end
    end
end

