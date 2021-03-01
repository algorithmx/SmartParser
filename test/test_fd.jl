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
    B  = find_block_MostFreqSimilarSubsq(B) ;
    B  = find_block_MostFreqSimilarSubsq(B) ;
    B  = find_block_MostFreqSimilarSubsq(B) ;
    return lines, lines1, B, code
end

RT  = ARGS[1]
@info RT

fns = ["$(rstrip(RT,'/'))/$ff" for ff in readdir("$RT") if !endswith(ff,".replaced.txt")]

for fn in fns
    try rm("$(fn).replaced.txt") catch ; end
end

DATA = []

for fn in fns
    @info fn
    lines, lines1, B, code = build_structure_tree(fn) ;
    codeinv = revert(code) ;
    parse_file!(0, B, lines, lines1, codeinv) ;
    @assert is_valid_block(B)
    push!(DATA, (B, code, codeinv, lines, lines1))
    NL = block_print(B, lines1, offset=0, mute=true) ;
    open("$(fn).replaced.txt","w") do f
        write(f,join(NL,"\n"))
    end
end
