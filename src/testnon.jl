IntRange = UnitRange{Int}

similarity2(x,y) = Int(x==y)

# search substr in fullstr FROM THE RIGHTEST POSITION
function nonoverlapping(
    substr::Vector{TR}, 
    fullstr::Vector{TR}
    )::Vector{IntRange}  where  TR

    Nsub    = length(substr)
    sim_min = Nsub * 1.000
    sim     = -1.0
    q       = -1
    posL    = length(fullstr)-Nsub+1
    R       = IntRange[]
    while posL >= 1
        q = -1
        # test similarity FROM THE RIGHTEST POSITION
        for p ∈ posL:-1:1
            sim = 0.0
            # going down FROM THE RIGHTEST POSITION
            j = Nsub
            while (j>0)
                sim += similarity2(substr[j], fullstr[p+j-1])^4
                if (sim+j-1+1e-12<sim_min) 
                    # if, even the remaining part all matches exactly (sim+=1 for each)
                    # the sim value still below minimum
                    break
                end
                j -= 1
            end
            if j==0
                # the above while loop reaches the end
                # overall similarity larger than fixed level
                q = p
                push!(R, q:q+Nsub-1)
                posL = q-Nsub
                break
            end
        end
        if q < 0
            break
        end
    end
    return R
end

##

#f0 = [2,1,0,2,2,1,2,0,1,0,2]
#s1 = [1,2]

#nonoverlapping(s1,f0)