using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")

using SmartParser

using Profile

function build_structure_tree(fn)
    lines, lines1, patts, code = load_file(fn) ;
    if length(lines)==0
        return String[], String[], Multiline(), code
    end
    B  = build_block_init(patts) ;
    B  = find_block_MostFreqSimilarSubsq(B) ;
    return lines, lines1, B, code
end


fns = [
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test4.pw.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test3.pwdry.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test1.pw.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test2.ph.x.out",
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/lammps.log" ,
]

fn = "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test2.ph.x.out"
fn = "/data/ReO3_phonon_configs/ps_GBRV_PBE_kp_8,8,8,1,1,1_kBar_0.5_dg_0.02/ReO3_ph/ReO3.ph.x.out" ;

##

lines, lines1, patts, code = load_file(fn) ;

B  = build_block_init(patts) ;

Profile.init(n = 10^9, delay = 0.001)
Profile.clear()
#@profview B  = find_block_MostFreqSimilarSubsq(B) ;

@time B  = find_block_MostFreqSimilarSubsq(B) ;

@assert is_valid_block(B)

##

codeinv = revert(code) ;

Profile.init(n = 10^9, delay = 0.001)

Profile.clear()

#@profview parse_file!(0, B, lines, lines1, codeinv) ;

@time parse_file!(0, B, lines, lines1, codeinv) ;

@assert is_valid_block(B)

##

function search_kw_in_tree_data(t::Block, kw)
    # DATA is organized as follows
    # range => Vector{Pair{String,Any}}[...]
    # each v in [...] is a line of data from parsing single line
    extract_data(x::Block) = (is_multi(x) 
                                ? (Any[]) 
                                : (Any[ tx=>Any[data for data in multiple_data if kw ∈ first.(data)] 
                                    for (tx,multiple_data) in x.DATA ]))
    coll = collect_action_dfs(t,extract_data)
    return vcat([ x for x in coll
                    if (vcat(x...)!=[]) && (vcat(vcat(last.(x)...)...)!=[]) ]...)
end

##

##

Bt = typical_blocks(B);

X = search_kw_in_tree_data(B, "__CHEM__")
CHEM_SOMBOLS = vcat(vcat(last.(vcat((last.(last.(X))...)))...)...) |> unique

X = search_kw_in_tree_data(B, "__FULLPATH__")
FULLPATH_SOMBOLS = vcat(vcat(last.(vcat((last.(last.(X))...)))...)...) |> unique


X = search_kw_in_tree_data(B, "__RELPATH__")
ABSPATH_SOMBOLS = vcat(vcat(last.(vcat((last.(last.(X))...)))...)...) |> unique

X = search_kw_in_tree_data(B, "__SYMBOLtypeA__") ;
SYMBOLtypeA_SOMBOLS = vcat(vcat(last.(vcat((last.(last.(X))...)))...)...) |> unique

X = search_kw_in_tree_data(B, "__KWCPU__")
REPSYMBOL_SOMBOLS = vcat(vcat(last.(vcat((last.(last.(X))...)))...)...) |> unique


##

Profile.init(n = 10^7, delay = 0.001)
Profile.clear()
@profview  search_kw_in_tree_data(B, "PseudoPot.") ;

@time [search_kw_in_tree_data(B, "PseudoPot.")  for i=1:100];


##

X_SOMBOLS = vcat(vcat(last.(vcat((last.(last.(X))...)))...)...) |> unique
