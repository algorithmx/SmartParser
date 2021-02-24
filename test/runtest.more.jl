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
    #B  = loop_correct_1_1_until_stable(B) ;
    return lines, lines1, B, code
end

RT = "/home/dabajabaza/jianguoyun/Workspace/SmartParser"

fns = [
    ("$RT/test/test4.pw.x.out", :QE),
    ("$RT/test/test3.pwdry.x.out", :QE) ,
    ("$RT/test/test1.pw.x.out", :QE) ,
    ("$RT/test/test2.ph.x.out", :QE),
    ("$RT/test/lammps.log", :LAMMPS) ,
    ("$RT/test/CALYPSO.log", :CALYPSO) ,
]


DATA = []


for fn_md in fns
    (fn,md) = fn_md
    @info fn
    lines, lines1, B, code = build_structure_tree(fn) ;
    codeinv = revert(code) ;
    BD = parse_file(B, lines, lines1, codeinv) ;
    push!(DATA, (BD, B, code, codeinv, lines, lines1))
    NL = block_print(B, lines1, offset=0, mute=true) ;
    open("$(fn).replaced.txt","w") do f
        write(f,join(NL,"\n"))
    end
end

##
