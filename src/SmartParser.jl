__precompile__()

module SmartParser


using DataStructures


export TPattern, SIMILARITY_LEVEL
export RTYPE, __DEFAULT__R__
include("types_and_settings.jl")


include("__REFDIC__.jl")


export MASK_RULES, MASK_RULES_DIC_INV
include("rules.jl")


export mask, tokenize, tokenize0, load_file, encode_line, revert
export preprocess_raw_input
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


export increaseindex!
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
export extract_DATA
include("parse_file.jl")


export StructuredOutputFile
export structurize_file
include("structurize_file.jl")


export lookup_codes,            lookup_code
export get_DATA_by_codes,       get_DATA_by_code
export get_n_blocks_by_codes,   get_n_blocks_by_code
export next_block_by_codes,     next_block_by_code
export get_blocks_max_by_codes, get_blocks_max_by_code
export select_block_by_patt
export get_DATA_by_patt
include("search.jl")


end # module
