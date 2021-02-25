@inline patt_dfs(t) = collect_action_dfs(t, x->(is_single(x) ? x.p : Int[-1]))

@inline patt_bfs(t) = collect_action_bfs(t, x->(is_single(x) ? x.p : Int[-1]))

@inline dot_patts(p1,p2,f)  = (length(p1)==length(p2) ? (length(p1)==0 ? 1.0 : f(sum(p1.==p2)/length(p2))) : 0.0)

@inline dot_patt_lists(b1,b2,f) = (length(b1)==length(b2) ? sum(dot_patts(x,y,f) for (x,y) ∈ zip(b1,b2))/length(b1) : 0.0)

similarity(t1::Block,t2::Block; f=identity) = dot_patt_lists(patt_dfs(t1), patt_dfs(t2), f)


