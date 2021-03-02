using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")

using SmartParser

using Profile

function build_structure_tree(fn)
    lines, lines1, patts, code = load_file(fn) ;
    if length(lines)==0
        return String[], String[], Multiline(), code
    end
    B = (build_block_init(patts) |> loop_until_stable) ;
    return lines, lines1, B, code
end

fn = "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test2.ph.x.out"

fn = "/data/ReO3_phonon_configs/ps_GBRV_PBE_kp_8,8,8,1,1,1_kBar_0.5_dg_0.02/ReO3_ph/ReO3.ph.x.out" ;

#

lines, lines1, patts, code = load_file(fn) ;

##

@time  B = (build_block_init(patts) 
            |> find_block_MostFreqSimilarSubsq
            |> find_block_MostFreqSimilarSubsq
            |> find_block_MostFreqSimilarSubsq
            |> find_block_MostFreqSimilarSubsq
            |> find_block_MostFreqSimilarSubsq
            |> find_block_MostFreqSimilarSubsq
);

##

B = build_block_init(patts) ;
Profile.init(n = 10^9, delay = 0.0002)
Profile.clear()
@profview B  = find_block_MostFreqSimilarSubsq(B) ;

##

@time B  = find_block_MostFreqSimilarSubsq(B) ;

@assert is_valid_block(B)

##

codeinv = revert(code) ;

#Profile.init(n = 10^9, delay = 0.001)
#Profile.clear()
#@profview parse_file!(0, B, lines, lines1, codeinv) ;

@time parse_file!(0, B, lines, lines1, codeinv) ;

@assert is_valid_block(B)
