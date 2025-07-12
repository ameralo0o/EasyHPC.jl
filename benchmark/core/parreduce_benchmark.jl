using BenchmarkTools
using EasyHPC
using Random
using SpecialFunctions

data = rand(10^6)


println("=== Benchmark: reduce ===")
display(@benchmark reduce(/, $data))

println("=== Benchmark: parreduce ===")
display(@benchmark parreduce(/, $data))