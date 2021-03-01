using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")

using SmartParser

using Profile

function build_structure_tree(fn)
    lines, lines1, patts, code = load_file(fn) ;
    if length(lines)==0
        return String[], String[], Multiline(), code
    end
    B = ( build_block_init(patts) 
            |> find_block_MostFreqSimilarSubsq |> merge_children 
                |> find_block_MostFreqSimilarSubsq |> merge_children 
                    |> find_block_MostFreqSimilarSubsq |> merge_children ) ;
    return lines, lines1, B, code
end


fns = [
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test4.pw.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test3.pwdry.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test1.pw.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test2.ph.x.out",
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/lammps.log" ,
]


@time lines, lines1, B, code = build_structure_tree(fns[4]) ;

codeinv = revert(code) ;

@time parse_file!(0, B, lines, lines1, codeinv) ;

@assert is_valid_block(B)


##

@time Y = search_x_in_tree(B, [61,])
@time Y = search_x_in_tree(B, [41,])

##

@time Y1 = next_block_by_id(B, 62, delay=1)
@time Y2 = next_block_by_id(B, 62, delay=2)

##

@time Y = search_kw_in_tree_data(B, "autoval")
@time Y = block_contains_kw_data(B, "autoval")

##

Bt = typical_blocks(B) ;
X = search_kw_in_tree_data(B, "__CHEM__")
CHEM_SOMBOLS = vcat(vcat([v for (k,v) in vcat((last.(last.(X))...)) if k=="__CHEM__"]...)...) |> unique

##
