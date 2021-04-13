mutable struct StructuredOutputFile{RT}
    B::Block{RT}
    CODE::Dict{String,TCode}
    CODEINV::Dict{TCode,String}
    LINES::Vector{String}
    TOKLINES::Vector{String}
end

# returns the 
# B, # tree-representation of the data
# code, codeinv, # word-token and token-word maps
# lines,  # original file
# lines1  # tokenized file

function structurize_file(fn::String)::StructuredOutputFile{RTYPE}
    @assert isfile(fn)
    lines  = String[]
    lines1 = String[]
    lines, lines1, patts, code = load_file(fn)
    codeinv = revert(code) ;
    if length(lines)==0
        B = Multiline()
    else
        B = (   build_block_init(patts) 
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq
                    |> find_block_MostFreqSimilarSubsq   );
        parse_file!(0, B, lines, lines1, codeinv) ;
        @assert is_valid_block(B)
    end
    return StructuredOutputFile{RTYPE}(B, code, codeinv, lines, lines1)
end