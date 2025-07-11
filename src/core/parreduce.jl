"""
    parreduce(f, data; nchunks = nthreads(), init)

Parallel reduction over `data` using binary function `f`.

This function splits the input `data` into `nchunks`, reduces each chunk independently using `f`, and then combines the partial results in a final reduction step. Useful for large datasets and CPU-bound reductions.

### Arguments
- `f`: A binary function, e.g. `+`, `max`, `min`, etc.
- `data`: A collection supporting indexing (e.g. `Vector`, `Range`)
- `nchunks`: Number of chunks (default: `nthreads()`)
- `init`: Optional initial value for reduction. Required if `data` may be empty.

### Returns
- The final reduction result of applying `f` across `data`, computed in parallel.

### Example
```julia
parreduce(+, 1:1_000_000)                 # → 500000500000
parreduce(max, [1, 7, 3, 5]; init = 0)    # → 7
parreduce(*, [1, 2, 3, 4]; init = 1)      # → 24
```

### Notes
- Only use for computationally expensive functions — parallel overhead may outweigh benefits for cheap operations or small inputs
- Returns `init` if `data` is empty and `init` is provided
- Throws an error if `data` is empty and no `init` is given
- Internally uses `OhMyThreads.index_chunks` for chunking and `Threads.@spawn` for parallelism
"""

function parreduce(f, data; nchunks=nthreads(), init=nothing)
    isempty(data) && init === nothing &&
        throw(ArgumentError("Cannot reduce empty collection without `init`"))

    chunks = OhMyThreads.index_chunks(data; n=nchunks)
    T = init === nothing ? eltype(data) : typeof(init)
    partials = Vector{T}(undef, nchunks)
    has_result = falses(nchunks)

    @sync for (c, idcs) in enumerate(chunks)
        @spawn begin
            part = view(data, idcs)
            if isempty(part)
                has_result[c] = false
            else
                partials[c] = init === nothing ? reduce(f, part) : reduce(f, part; init=init)
                has_result[c] = true
            end
        end
    end

    # Combine partials that are valid
    result_set = false
    acc = init

    for (i, valid) in enumerate(has_result)
        if valid
            if result_set
                acc = f(acc, partials[i])
            else
                acc = partials[i]
                result_set = true
            end
        end
    end

    return acc
end
