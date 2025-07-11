using BenchmarkTools
using Random
using Statistics
using Dates
using DelimitedFiles
using EasyHPC  

function run_simple_benchmark()
    @info "Threads: $(Threads.nthreads())"
    sizes = [10^5, 10^6, 10^8]
    types = [Int16, Int32, Int64, Float16, Float32, Float64]
    results = []

    header = ["Threads", "Size", "Type", "DataPattern", "Algorithm", "TimeMedian_ns", "Memory_Bytes", "Allocations"]
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    csvfile = "sorting_benchmark_$timestamp.csv"
    open(csvfile, "w") do f
        writedlm(f, [header], ',')
    end

    println("\n" * "="^70)
    println(" SORTING BENCHMARK: Float + Random Data")
    println("="^70 * "\n")

    for N in sizes
        println("\n" * "-"^60)
        println("ARRAY SIZE: $N")
        println("-"^60)

        for T in types
            println("\n> Type: $(T)")
            data = rand(T, N) * 10^7

            b_base = @benchmark sort!($(deepcopy(data)))
            base_stats = median(b_base)

            b_seq = @benchmark sort_numeric_seq!($(deepcopy(data)))
            seq_stats = median(b_seq)

            b_par = @benchmark sort_numeric!($(deepcopy(data)))
            par_stats = median(b_par)

            base_time, seq_time, par_time = base_stats.time, seq_stats.time, par_stats.time
            base_mem, seq_mem, par_mem = base_stats.memory, seq_stats.memory, par_stats.memory
            base_allocs, seq_allocs, par_allocs = base_stats.allocs, seq_stats.allocs, par_stats.allocs

            threads = Threads.nthreads()
            push!(results, (threads, N, T, "random", "base", base_time, base_mem, base_allocs))
            push!(results, (threads, N, T, "random", "custom_seq", seq_time, seq_mem, seq_allocs))
            push!(results, (threads, N, T, "random", "custom_par", par_time, par_mem, par_allocs))

            speedup_base_seq = round(base_time / seq_time, digits=2)
            speedup_seq_par = round(seq_time / par_time, digits=2)
            println("  base=$(base_time/1e6) ms, seq=$(seq_time/1e6) ms, par=$(par_time/1e6) ms")
            println("    => base/seq: $(speedup_base_seq)x, seq/par: $(speedup_seq_par)x")
        end
    end

    open(csvfile, "a") do f
        for row in results
            writedlm(f, [row], ',')
        end
    end

    println("\nBenchmark completed. Results saved to: $csvfile")
    return csvfile
end

#run_simple_benchmark()


data = rand(Float64, 10^6) * 10^7

display(@benchmark sort_numeric!($data))