using BenchmarkTools
using EasyHPC
using Random


Random.seed!(1234)
A = rand(10^7);
println("=== Benchmark: sum ===")
display(@benchmark sum($A))

println("=== Benchmark: parsum ===")
display(@benchmark parsum($A))