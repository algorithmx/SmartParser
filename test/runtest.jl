using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")
using SmartParser

#

#fn = "/data/ReO3_phonon_configs/ps_GBRV_PBE_kp_8,8,8,1,1,1_kBar_0.0_dg_0.02/ReO3_scf/ReO3.pw.x.out" ;
#fn = "/data/ScF3_phonon_configs/ps_GBRV_PBE_kp_12,12,12,1,1,1_kBar_0.5_dg_0.02/ScF3_relax/ScF3.pw.x.out" ;
fn = "/data/ScF3_phonon_configs/ps_GBRV_LDA_kp_12,12,12,1,1,1_kBar_0.0_dg_0.02/ScF3_relax/ScF3.pw.x.out" ;
#fn = "./src/test_OUTP.txt";

lines, lines1, patts, code = load_file(fn) ;

##

B0 = build_block_init(patts) ;

B1  = find_block(B0) ;
println(max_depth(B1))

B2  = loop_correct_1_1_until_stable(B1) ;
println(max_depth(B2))


NL = block_print(B2, lines1, offset=0, mute=true) ;

open("test000.txt","w") do f
    write(f,join(NL,"\n"))
end

##

findmax([length(children(c)) for c in children(B2)])