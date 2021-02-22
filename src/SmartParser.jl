__precompile__()

module SmartParser

using DataStructures

export mask, tokenize, load_file, encode_line
include("tokenize.jl")

export Block, Singleline, MultiDict, tree_print
export hash, copy
export children, label, num_nodes
export DFS
include("Tree.jl")

export nonoverlapping
include("substring.jl")

export MFS
include("MFS.jl")

export restructure_children
export loop_find_block_until_stable, find_block
export correct_1_1
export build_block_init
export typical_blocks
include("find_block.jl")

export block_print, treep
include("block_print.jl")


end # module
