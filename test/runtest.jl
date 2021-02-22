using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")
using SmartParser


function build_structure_tree(fn)

    lines, lines1, patts, code = load_file(fn) ;
    if length(lines)==0
        return String[], String[], Multiline(), code
    end

    B = build_block_init(patts) ;

    B  = find_block(B) ;
    B  = loop_correct_1_1_until_stable(B) ;

    B  = find_block(B) ;
    B  = loop_correct_1_1_until_stable(B) ;

    return lines, lines1, B, code

end

#

#fn = "/data/ReO3_phonon_configs/ps_GBRV_PBE_kp_8,8,8,1,1,1_kBar_0.0_dg_0.02/ReO3_scf/ReO3.pw.x.out" ;
#fn = "/data/ScF3_phonon_configs/ps_GBRV_PBE_kp_12,12,12,1,1,1_kBar_0.5_dg_0.02/ScF3_relax/ScF3.pw.x.out" ;
fn = "./test/test2.ph.x.out" ;
#fn = "./src/test_OUTP.txt";

lines, lines1, B, code = build_structure_tree(fn) ;

##

NL = block_print(B, lines1, offset=0, mute=true) ;
open("test.txt","w") do f
    write(f,join(NL,"\n"))
end

#

Bt = typical_blocks(B, M=1) ;

##

for i=1:length(Bt)
    block_print(Bt[i], lines1, offset=0) ;
end

##

collect_action_bfs(Bt[2], hash)