__precompile__()

module SmartParser


using DataStructures

include("types_and_settings.jl")

export MASK_RULES, MASK_RULES_DIC_INV
include("rules.jl")

export mask, tokenize, load_file, encode_line, revert
include("tokenize.jl")

export Block, Singleline, MultiDict, tree_print
export khash, copy, isequal
export DFS
export children, label, num_nodes
export max_depth, min_depth
export collect_action_dfs, collect_action_bfs
export is_multi, is_single
export Block
include("Tree.jl")

include("special_dict_op.jl")

export similarity
export MostFreqSimilarSubsq
include("block_similarity.jl")


export find_block_MostFreqSimilarSubsq
export loop_until_stable
export verify_block, is_valid_block, is_valid_x, is_valid_C
export build_block_init_by_linebreak
export build_block_init, typical_blocks
export merge_children
include("find_block.jl")

export block_print, treep
include("block_print.jl")

export parse_file!
include("parse_file.jl")

export search_kw_in_tree_data
export search_x_in_tree
export next_block_by_id
export block_contains_kw_data
include("search.jl")

end # module
