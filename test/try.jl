using DataStructures

B = [1:5, 6:10, 11:15, 16:20]
B1 = [6:10, 11:15, 16:20]
C = [2:4, 6:10, 11:15, 16:20]
C1 = [2:4, 6:10, 11:15, 16:20, 21:21]

comp(x) = -100length(x) - length(first(x))

H = BinaryHeap(Base.By(comp), Vector{UnitRange{Int}}[]) 

first(H)

push!(H, B)

first(H)
B

