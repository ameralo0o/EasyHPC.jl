using BenchmarkTools
using Random
using EasyHPC

data = rand(Float64, 10^8)


display(@benchmark sort!(deepcopy($data)))
display(@benchmark sort_numeric!(deepcopy($data)))