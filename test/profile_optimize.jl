using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/SmartParser/")

using SmartParser

using Profile
#using ProfileView


function build_structure_tree(fn)
    lines, lines1, patts, code = load_file(fn) ;
    if length(lines)==0
        return String[], String[], Multiline(), code
    end
    B = build_block_init(patts) ;
    B  = find_block(B) ;
    B  = loop_correct_1_1_until_stable(B) ;
    #B  = find_block(B) ;
    #B  = loop_correct_1_1_until_stable(B) ;
    return lines, lines1, B, code
end


fns = [
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test4.pw.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test3.pwdry.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test1.pw.x.out" ,
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/test2.ph.x.out",
    "/home/dabajabaza/jianguoyun/Workspace/SmartParser/test/lammps.log" ,
]

Profile.init(n = 10^9, delay = 0.001)
Profile.clear()
@profview  lines, lines1, B, code = build_structure_tree(fns[3]) ;


##

##

##

@profile  lines, lines1, B, code = build_structure_tree(fns[3]) ;

data = copy( Profile.fetch() ) ;

open("profile.use_copy.tree.txt","w") do f 
#open("profile.use_copy.txt","w") do f 
    Profile.print(IOContext(f, :displaysize=>(48,1500)), data, mincount=200)
    #Profile.print(f, data, format=:flat, mincount=400)
end
