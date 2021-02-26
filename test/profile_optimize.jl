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

@time B  = find_block_MostFreqSimilarSubsq(B) ;

@assert is_valid_block(B)

codeinv = revert(code) ;

Profile.init(n = 10^9, delay = 0.001)

Profile.clear()

#@profview parse_file!(0, B, lines, lines1, codeinv) ;

@time parse_file!(0, B, lines, lines1, codeinv) ;

@assert is_valid_block(BD)
