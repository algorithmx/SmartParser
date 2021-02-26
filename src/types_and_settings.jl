
#: -------------------------------
IntRange = UnitRange{Int}

TCode = Int
TPattern = Vector{TCode}
global const __DEFAULT_PATT__ = TCode[]
empty_TPattern() = TCode[]
one_elem_TPattern(x) = TCode[x,]
global const __M0_HASH__  = hash(empty_TPattern())
global const __M1_PATT__  = one_elem_TPattern(-1)
global const __M1_HASH__  = hash(__M1_PATT__)
global const __PATT__all_number_line__ = one_elem_TPattern(999999999)
global const __HASH__all_number_line__ = hash(__PATT__all_number_line__)

# reserved token 999999999 for all number line
# used by tokenize
global const __DEFAULT_HASH_CODE__ = UInt64(0x0)
#global const __DEFAULT__R__ = __DEFAULT_HASH_CODE__
global const __DEFAULT__R__ = (__DEFAULT_HASH_CODE__, TPattern[])  #+ modify
global const __RTYPE__ = typeof(__DEFAULT__R__)

global const __SIMILARITY_LEVEL__ = 0.9

import Base.copy

copy(x::__RTYPE__) = (x[1],copy(x[2]))

#: -------------------------------