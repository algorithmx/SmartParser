include("/home/dabajabaza/jianguoyun/Workspace/SmartParser/src/SmartParser.jl")


##

#fn = "/data/ReO3_phonon_configs/ps_GBRV_PBE_kp_8,8,8,1,1,1_kBar_0.0_dg_0.02/ReO3_scf/ReO3.pw.x.out" ;
#fn = "/data/ScF3_phonon_configs/ps_GBRV_PBE_kp_12,12,12,1,1,1_kBar_0.5_dg_0.02/ScF3_relax/ScF3.pw.x.out" ;
fn = "/data/ScF3_phonon_configs/ps_GBRV_LDA_kp_12,12,12,1,1,1_kBar_0.0_dg_0.02/ScF3_relax/ScF3.pw.x.out" ;
#fn = "./src/test_OUTP.txt";
S0 = read(fn,String) ;
patts, code = tokenize(mask(S0)) ;
lines = split(S0,"\n") ;
lines1 = split(mask(S0),"\n") ;

##

B0 = build_block_init(patts) ;
B  = find_block(B0) ;
NL1 = block_print(B, lines1, offset=0, mute=true) ;

open("test000.txt","w") do f
    write(f,join(NL1,"\n"))
end

##

