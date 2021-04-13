
#: -------------------------------
IntRange = UnitRange{Int}

TCode = Int
TPattern = Vector{TCode}
global const __DEFAULT_PATT__ = TCode[]
empty_TPattern() = TCode[]
global const __M0_PATT__  = TCode[]
one_elem_TPattern(x) = TCode[x,]
global const __M1_PATT__  = one_elem_TPattern(-1)
# reserved token 999999999 for all number line
# used by tokenize
global const __PATT__all_number_line__ = one_elem_TPattern(999999999)

global const __DEFAULT_HASH_CODE__ = UInt64(0x0)
global const __DEFAULT__R__ = (__DEFAULT_HASH_CODE__, TPattern[])  #+ modify
global const RTYPE = typeof(__DEFAULT__R__)

global const SIMILARITY_LEVEL = 0.7

import Base.copy

copy(x::RTYPE) = (x[1],copy(x[2]))

TokenValueLine = Vector{Pair{String,Any}}
DATATYPE = Vector{Pair{IntRange,Vector{TokenValueLine}}}

#: -------------------------------