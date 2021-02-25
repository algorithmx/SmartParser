__precompile__()

module SmartParser

using DataStructures

export MASK_RULES, MASK_RULES_DIC_INV
include("rules.jl")

export mask, tokenize, load_file, encode_line, revert
include("tokenize.jl")

export Block, Singleline, MultiDict, tree_print
export hash, copy, isequal
export DFS
export children, label, num_nodes, max_depth
export collect_action_dfs, collect_action_bfs
export is_multi, is_single
export Block
include("Tree.jl")

export nonoverlapping
include("substring.jl")

export MFS
include("MFS.jl")

export restructure_children
export find_block_MFS
export build_block_init
export typical_blocks
include("find_block.jl")

export block_print, treep
include("block_print.jl")

export findfirst_spec, parse_file
include("parse_file.jl")

export similarity
include("block_similarity.jl")


end # module
