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
export children, label, num_nodes, max_depth
export collect_action_dfs, collect_action_bfs
export is_multi, is_single
export Block
include("Tree.jl")

#export nonoverlapping
#include("substring.jl")


include("special_dict_op.jl")

export MostFreqSubsq
include("most_frequent_subsequence.jl")

export similarity
export MostFreqSimilarSubsq
include("block_similarity.jl")

export find_block_MostFreqSubsq, find_block_MostFreqSimilarSubsq
export verify_block, is_valid_block, is_valid_x, is_valid_C
export build_block_init, typical_blocks
export merge_children
include("find_block.jl")

export block_print, treep
include("block_print.jl")

export parse_file!
include("parse_file.jl")


end # module
