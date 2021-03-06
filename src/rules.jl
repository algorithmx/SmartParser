#: ==========================================
#: the stupid part of the SmartParser
#: ==========================================

#! DO NOT CHANGE THE SEQUENCE OF THE LIST BELOW
#! IT IS VERYY DELLICATTE


global const QE_KEYWORDS = [
    #: note the white space !!!
    r"Dynamical RAM for\s+(wfc|wfc\(w\.\s+buffer\)|str\.\s*fact|local\s+pot|nlocal\s+pot|qrad|rho\,v\,vnew|rhoin|rho\*nmix|G\-vectors|h\,s\,v\(r\/c\)|\<psi\|beta\>|psi|hpsi|spsi|wfcinit\/wfcrot|addusdens|addusforce|addusstress)" => " __QEDynRAMfor__ ",
    r"(kinetic|local|nonloc\.|hartree|exc\-cor|corecor|ewald|hubbard|london|DFT\-D3|XDM|dft\-nl|TS\-vdW)\s+stress" => " __QEstressKW__ ",
    r"(local|non\-local|ionic|(core|SCF)\s+corr(ection)?|Hubbard|) contrib(\.|ution)\s+to forces" => " __QEforceKW__ ",
    r"(PWSCF|electrons|forces|stress|sum\_band(\:bec)*|c\_bands|init\_run|update\_pot|wfcinit(\:atom|\:wfcr)*|potinit|hinit0|v\_of\_rho|v\_h|v\_xc|newd|mix\_rho|init\_us\_2|addusdens|\*egterg|[csgh]\_psi(\:pot|\:calbec)*|cdiaghg(\:chol|\:inve|\:para)*|cegterg(\:over|\:upda|\:last)*|vloc\_psi|add\_vuspsi|PAW(\_pot|\_symme)*)\s*\:" => " __QEelROUTINES__ ",
    r"(PHONON|phq(_setup|_init)?|init(_vloc|_us_1)?|dynmat(\d|_us)|phqscf|dynmatrix|solve_linter|drhodv|d2ionq|phqscf|dvqpsi_us|ortho|incdrhoscf|vpsifft|dv_of_drho|mix_pot|ef_shift|localdos|psymdvscf|dvqpsi_us(_on)?|cgsolve|last|add_vuspsi|incdrhoscf)\s*\:" => " __QEphROUTINES__ ",
    r"(calbec|fft(s|w|\_scatt\_xy|\_scatt\_yz)?|davcio|write\_rec)\s*\:" => " __QEgenROUTINES__ ",
    r"stopping\s*\.+"                                                    => " __QESTOPPING__ ",

    # really stupid but they are NOT chemical formulae
    [Regex("(?<![0-9A-Za-z_\\-\\.\\/])$i(?=[^0-9A-Za-z_\\.\\/\\-\\n])")  =>  " __KW$(replace(i,r"(\\\.|\\\-|\d)"=>""))__ " 
            for i ∈ ["PW","PWSCF","PH","PHONON","UPF","SCF","CPU","PBC","INF","FHI98PP", "pw\\.x", "fhi2upf\\.x", "ld1\\.x", "calypso\\.x", "vasp\\.x"] ] ...
]

global const LAMMPS_KEYWORDS = [
    r"\$\{\w+\}" => " __LAMMPSVAR__ ",
]

##

global const __NUM_TO_STERLING__ = [
    r"\d+(\.\d+)\%" => " __PERCENTAGE__ ",

    #: this substitution fucks up a lot of lines
    #: still in development
    r"(?<![\w])([+-]?\d+(\.\d*)?|[+-]?\d*\.\d+)((e|E)[+-]?\d+)?(?=[^\w]|$)"  => "£",

    #: aftermath of the number substitution
    "(£"   =>  "( £",
    "£)"   =>  "£ )",
    "£|"   =>  "£ |",
    "|£"   =>  "| £",
    "£,"   =>  "£ ,",
    ",£"   =>  ", £",

    "£-£"  =>  "£ - £",
    "£+£"  =>  "£ + £",
    
    "£-"   =>  "£ - ",
    "-£"   =>  " - £",
    "£/"   =>  "£ / ",
    "/£"   =>  " / £",
    "£*"   =>  "£ * ",
    "*£"   =>  " * £",
    "£:"   =>  " : £",
    ":£"   =>  "£ : ",
]

global const __SINGLE_ELEM__str__ = "(A[cglmrstu]|B[aehikr]?|C[adeflmnorsu]?|D[bsy]|E[rsu]|F[elmr]?|G[ade]|H[efgos]?|I[nr]?|Kr?|L[airuv]|M[dgnot]|N[abdeiop]?|Os?|P[abdmortu]?|R[abefghnu]|S[bcegimnr]?|T[abcehilm]|U(u[opst])?|V|W|Xe|Yb?|Z[nr])"

##//global const __CHEMELEM__rstr__ = Regex("(?<![0-9A-Za-z])$(__SINGLE_ELEM__str__)(?=[^0-9A-Za-z])")

global const __CHEMFORMULA__rstr__  = Regex("(?<![0-9A-Za-z_\\.\\-\\/])($(__SINGLE_ELEM__str__)\\d*)+(?=[^0-9A-Za-z_\\.\\-\\/\\n])")

##

global const  MASK_RULES = [  

    QE_KEYWORDS...,

    LAMMPS_KEYWORDS...,

    #: note the white space !!!
    r"MD5\s*check sum\s*:\s*[a-f0-9]{32}"                   => " __CHKSUM__ ",
    r"point\s+group\s+[A-Za-z0-9\_]+(\s*\(m-3m\))?"         => " __POINTGROUP__ ",

    r"Ry\/bohr\*\*3"                                        => " __UNITSTRESS__ ",
    r"Ry\/Bohr"                                             => " __UNITFORCEa__ ",
    r"Ry\/au"                                               => " __UNITFORCEb__ ",
    r"\d\s*pi\/alat"                                        => " __UNITTWOPIALAT__ ",
    r"g\/cm\^3"                                             => " __UNITDENSITY__ ",
    r"(?<![A-Za-z_\-])Ry"                                   => " __Ry__ ",
    r"(?<![\w\d\-\/])\(\s*alat\s*\)(?=[^\w\d\/]|$)"         => " __ALAT__ ",
    r"(?<![\w\d\-\/])ev(?=[^\w\d\/]|$)"                     => " __EV__ ",
    r"(?<![\w\d\-\/])\(bohr\)(?=[^\w\d\/]|$)"               => " __BOHR__ ",
    
    r"http\:\/(\/[^\^\/\s]+)+(\/)?"                         => " __URL__ ",       
    r"(?<![0-9A-Za-z\*])((\/\w[^\^\/\s\$]*)+(\/)?|(\w[^\^\/\s\$]*\/)+)(?=[^\.0-9A-Za-z\(\)]|$)" => " __FULLPATH__ ",

    r"\(a\.u\.\)\^3"                                        => " __UNITVOLa__ ",
    r"a\.u\.\^3"                                            => " __UNITVOLb__ ",
    r"a\.u\."                                               => " __au__ ",

    r"v(\.\d+){2,3}"                                        => " __VERSIONa__ ",
    r"((\d+h\s*)?\d+m\s*)?\d+\.\d+s"                        => " __DURATION__ ",

    #r"[^0-9\^\/\s\.\(\)][^\^\/\s\.\(\)]{1,20}\.([^\^\/\s\.\(\)]{1,20}\.)*[A-Za-z0-9]+"  => " __ABSPATH__ ", 
    #r"[^\^\/\s\.\(\)]{1,20}\w\.([^\^\/\s\.\(\)]{1,20}\.)*[A-Za-z][A-Za-z0-9]*"  => " __ABSPATH__ ", 
    r"(?<![0-9A-Za-z\*\.])[^\^\/\s\.\(\)]{1,20}\w\.([^\^\/\s\.\(\)]{1,20}\.)*[A-Za-z][A-Za-z0-9]*(?=[^\.0-9A-Za-z\/]|$)" => " __RELPATH__ ", 

    r"Ang\^3"                                               => " __UNITVOLc__ ",
    r"kbar"                                                 => " __UNITkbar__ ",
    r"\[cm-1\]"                                             => " __UNITCMINV__ ",

    r"([01]?\d|2[0-3]):([0-5 ]?\d):([0-5 ]?\d)"             => " __HHMMSS__ ",
    r"[1-3 ]\d[A-Za-z]{2,9}(19|20)\d\d"                     => " __DATEa__ ",

    r" P\s*\= "                                             => " __PRESSUREEQS__ ",

    r"\[\s*\-?\d+\s*,\s*\-?\d+\s*,\s*\-?\d+\s*\]"           => " __MILLER__ ",
    r"\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)"                    => " __THREETUPLES__ ",

    __CHEMFORMULA__rstr__ => " __CHEM__ ",
    ##//__CHEMELEM__rstr__ => " __CHEMELEM__ ",

    r"(?<![0-9A-Za-z_\-])[ABTE]\'*\_[1-5]?[ug](?=[^0-9A-Za-z_\-]|$)"                    => " __REPSYMBOL__ " ,
    r"(?<![0-9A-Za-z_\-])([23468]?[CS][2346]'?|i|E|[2346]s_[hd])(?=[^0-9A-Za-z_\-]|$)"  => " __GRPSYMBOL__ " ,
    r"(?<![0-9A-Za-z_\-\/])[1-6][SsPpDdFf](?=[^0-9A-Za-z_\-\/]|$)"                      => " __ATOMORBIT__ ",

    __NUM_TO_STERLING__...,

    r"[A-Za-z][^\_\\\/\%\s]*(\_[A-Za-z][^\_\\\/\%\s]*)+"    => " __SYMBOLtypeA__ ",
    r"[A-Za-z]+\d+[A-Za-z]*"                                => " __SYMBOLtypeB__ ",  #: this is rather unfortunate
    r"[A-Za-z]*\d+[A-Za-z]+"                                => " __SYMBOLtypeC__ ",  #: this is rather unfortunate
]

# these are used in parse_file for performance optimization
global const  MASK_RULES_DIC_INV = Dict(v=>k for (k,v) ∈ MASK_RULES if (k isa Regex))
global const  MASK_RULES_DIC_INV1 = Dict(strip(v)=>k for (k,v) ∈ MASK_RULES if (k isa Regex))
global const  MASK_RULES_DIC_INV_KEYS_STRIPPED_NO_£ = Set([strip.(x) for x in keys(MASK_RULES_DIC_INV) if x!="£"])

global const __preproc__ = [ 
    r"(\d+)q-points"          => s"\1 q-points",
    r"\#(\s*\d+): "           => s"# \1 : ", 
    r"(\w)\)\:"               =>s"\1 ) :",
    r" (\d+\s*)\*(\s*\d+) "   => s" \1 * \2 ", 
    r"([\<\>\=\+\-\*])(\d+)([\*\+\-])" => s"\1 \2 \3",
    r"(\d)ns(?=[^0-9A-Za-z])" => s"\1 ns ",
    r"N(\s+)xq"               => s"NUM\1 xq",  # QE PH calculation "N       xq(1) ..."
    r"\(\s*ev\s*\)"           => " ( ev ) ",
    "G-vectors)"              => "G-vectors )",
    #r" hinit(\d+) " => s" hinit \1 ", 
    #r" dynmat(\d+) " => s" dynmat \1 ", 
    #r" d(\d+)ionq " => s" d \1 ionq ", 
    #"h,s,v(r/c)" => "h,s,v( r / c )", 
    #"wfcinit/wfcrot" => "wfcinit / wfcrot", 
    #"atoms/cell" => "atoms / cell", 
    #"proc/nbgrp/npool/nimage" => " proc / nbgrp / npool / nimage ", 
]
