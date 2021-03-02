#* ================================

# DATA is organized as follows
# range => Vector{Pair{String,Any}}[...]
# each v in [...] is a line of data from parsing single line

key_in_data(dt,kw) = length(dt)==0 ? false : any( 
    tx_data_pair->any(  kv_list->any(kv->first(kv)==kw,kv_list), 
                        last(tx_data_pair)   ), 
    dt
)

extract_data_by_kw(x::Block,kw) = ((is_single(x) && key_in_data(x.DATA,kw)) ? x.DATA : Any[])

function search_kw_in_tree_data(t::Block, kw)
    coll = collect_action_dfs(t, x->extract_data_by_kw(x,kw))
    return vcat([ x for x in coll if (vcat(x...)!=[]) && (vcat(vcat(last.(x)...)...)!=[]) ]...)
end


#* ================================

val_in_data(dt,va) = length(dt)==0 ? false : any( 
    tx_data_pair->any(  kv_list->any(kv->last(kv)==va,kv_list), 
                        last(tx_data_pair)   ), 
    dt
)

extract_data_by_val(x::Block,va) = ((is_single(x) && val_in_data(x.DATA,va)) ? x.DATA : Any[])

function search_val_in_tree_data(t::Block, va)
    coll = collect_action_dfs(t, x->extract_data_by_val(x,va))
    return vcat([ x for x in coll if (vcat(x...)!=[]) && (vcat(vcat(last.(x)...)...)!=[]) ]...)
end

#* ================================

line_in_tx(tx,line_id) = (line_id ∈ tx)

lines_in_tx(tx,line_ids) = all(line_in_tx(tx,i) for i ∈ line_ids)

extract_data_by_range(b::Block,line_ids::Vector{Int}) = Any[p=>data for (p,data) ∈ b.DATA 
                                                                    if lines_in_tx(p,line_ids)]

function search_x_in_tree(t::Block, line_ids::Vector{Int})
    coll = collect_action_dfs(t, b->extract_data_by_range(b,line_ids))
    return vcat([ x for x in coll if x!=[] ]...) 
end

#* ================================

#TODO
blck_by_pattern(x::Block, patt) = (x.R[2]==patt ? x : nothing)

function search_by_pattern(t::Block, pattrn_dfs::TPattern)
    coll = collect_action_dfs(t, b->blck_by_pattern(b,pattrn_dfs))
    return vcat([ x for x in coll if x!=[] ]...) 
end

#* ================================

line_id_in_data(x::Block, line_id::Int) = length(x.DATA)==0 ? false : any( 
    tx_data_pair->line_in_tx(first(tx_data_pair),line_id), 
    x.DATA
)

function next_block_by_id(b, line_id::Int; delay=1)
    status = 0
    f(x) = (if line_id_in_data(x,line_id) status=1; end)
    return DFS( b, 
                f,
                x->nothing,
                x->(status>=1+delay 
                        ? (status=0; Any[x[2],])    # hit
                        : (status>0 ? (status+=1; vcat(x[1]...)) : vcat(x[1]...))) ) # not yet
end

#* ================================

key_in_children(ch,kw) = length(ch)==0 ? false : any( 
    c->key_in_data(c.DATA,kw), 
    ch
)

function block_contains_kw_data(b::Block, kw)
    coll = collect_action_dfs(b, x->(key_in_children(children(x),kw) ? [x,] : []))
    return vcat([ x for x in coll if x!=[] ]...) 
end

#* ================================
