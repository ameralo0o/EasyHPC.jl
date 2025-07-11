# Parallel sum
"""
    parsum(data; nchunks = nthreads())

Compute the sum of all elements in `data` **in parallel** using multithreading.

The input is split into chunks using `OhMyThreads.index_chunks`, and each chunk is summed in a separate task. A thread-safe atomic accumulator is used for combining the results.

### Arguments
- `data`: A collection (e.g. `Vector`, `Range`, etc.) of numeric elements

### Keyword Arguments
- `nchunks`: Number of chunks (parallel tasks). Default is `nthreads()`

### Returns
- The total sum of all elements in `data`, computed in parallel

### Example
```julia
parsum(1:1_000_000)  # returns 500000500000
```

### Notes
- Automatically adapts to the number of threads via `nchunks`
- Most efficient on large numeric collections (`Vector{Int}`, `Vector{Float64}`, etc.)
"""
function parsum(data; nchunks=nthreads())
    eltype(data) <: Number || throw(ArgumentError("parsum expects a collection of Numbers"))
    acc = Atomic{eltype(data)}(zero(eltype(data)))
    @sync for idcs in OhMyThreads.index_chunks(data; n=nchunks)
        @spawn atomic_add!(acc, sum(@view data[idcs]))
    end
    return acc[]
end

