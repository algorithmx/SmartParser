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
    #B  = find_block(B) ;
    #B  = loop_correct_1_1_until_stable(B) ;
    return lines, lines1, B, code
end


fns000=[
    "./test/test4.pw.x.out" ,
    "./test/test3.pwdry.x.out" ,
    "./test/test1.pw.x.out" ,
    "./test/test2.ph.x.out"
]


for RT ∈ ["/data/ReO3_phonon_configs","/data/ScF3_phonon_configs",]
    fns=vcat([[ "$RT/$fd/$ff/$fout" for ff in readdir("$RT/$fd") if isdir("$RT/$fd/$ff") 
                                        for fout in readdir("$RT/$fd/$ff") if endswith(fout,".out") ]
                                            for fd ∈ readdir(RT) if isdir("$RT/$fd") ]...)
    DATA = []
    skip = [""]
    for fn in fns
        if fn ∉ skip
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
    end
end


##

blks = block_by_kw(DATA[3][1], "£") ;
blks = block_by_kw(DATA[3][1], "__CHEM__") ;
blks = block_by_kw(DATA[3][1], "__SYMBOL__") ;

##


#

Bt = typical_blocks(BDATA, M=1) ;

##

for i=1:length(Bt)
    block_print(Bt[i], lines1, offset=0) ;
end

##


collect_action_dfs(Bt[5], x->((x isa Singleline) ? x.p : Int[-1]))

collect_action_dfs(Bt[2], hash)

##

#: ===================================================== :#

@inline patt_dfs(t) = collect_action_dfs(t, x->((x isa Singleline) ? x.p : Int[-1]))

@inline patt_bfs(t) = collect_action_bfs(t, x->((x isa Singleline) ? x.p : Int[-1]))

@inline dot_patts(p1,p2,f)  = (length(p1)==length(p2) ? (length(p1)==0 ? 1.0 : f(sum(p1.==p2)/length(p2))) : 0.0)

@inline dot_patt_lists(b1,b2,f) = (length(b1)==length(b2) ? sum(dot_patts(x,y,f) for (x,y) ∈ zip(b1,b2))/length(b1) : 0.0)

@inline similarity(t1::Block,t2::Block; f=identity) = dot_patt_lists(patt_dfs(t1), patt_dfs(t2), f)

#: ===================================================== :#

similarity(Bt[26], Bt[27])

##


function search_kw_in_tree_data(t::Multiline, kw)
    f(x) = ((x isa Multiline) ? [[]] : ([[v for (k,v) in data if k==kw] for data in x.DATA]))
    return [(i,x) for (i,x) in enumerate(collect_action_dfs(t,f)) if unique(x)!=[[]]]
end


function block_by_kw(t::Multiline, kw)
    @inline kw_in_sl(kw,sl) = length([1 for data in sl.DATA for (k,v) ∈ data if k==kw])>0
    h(x) = ((x[2] isa Multiline) 
                ? vcat( # pick the correct block (labelled by 1)
                        [CD[first.(CD).==1] for CD in x[1]]...,  
                        # and itself if there is any children returns [(0,nothing)]
                        (any([kw_in_sl(kw,sl) for sl in children(x[2]) if (sl isa Singleline)]) ? [(1,x[2])] : []) )
                : [] )
    DFS(t, x->nothing, x->nothing, h)
end


function generate_line(patt::Vector{Int}, codeinv::Dict, data)
    if patt==[999999999,]
        @assert unique(first.(data))==["£",]
        return join(string.(last.(data)), "  ")
    else
        line = []
        idata = 1
        Ndata = length(data)
        #@show [codeinv[p] for p ∈ patt]
        for p ∈ patt
            w = codeinv[p]
            @assert  w != "£++++++++++++++++"
            if idata<=Ndata && w==data[idata][1]  # found data,
                #  replace p by data
                push!(line, string(data[idata][2]))  
                idata += 1
            else
                push!(line, w)
            end
        end
        return join(line, "  ")
    end
end


function reconstruct_file(DATATREE::Multiline, codeinv::Dict)
    single_line_reconstr(y) = [generate_line(y[2].p, codeinv, y[2].DATA[i]) for i=1:y[2].n]
    multi_line_reconstr(y)  = vcat(y[1]...)
    line_reconstr(y) = ((y[2] isa Singleline) ? single_line_reconstr(y) : multi_line_reconstr(y))
    DFS(DATATREE, identity, identity, line_reconstr)
end

