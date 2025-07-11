 """
    parmap(f, data; nchunks = nthreads())

Applies the function `f` to each element of `data` in **parallel**, preserving the original order of results.

The input collection is divided into chunks (default: one per thread), and each chunk is processed concurrently using `Threads.@spawn`. The result is a `Vector` of the same length and order as `data`.

### Arguments
- `f`: A function to apply to each element (e.g., `x -> x^2`)
- `data`: An indexable collection (typically a `Vector` or `UnitRange`) of input values

### Keyword Arguments
- `nchunks`: Number of chunks to split the input into (default: `nthreads()`)

### Returns
- `Vector{T}`: A vector where each element is `f(data[i])`, computed in parallel

### Example
```julia
julia> parmap(x -> x^2, 1:5)
5-element Vector{Int64}:
 1
 4
 9
 16
 25
```

### Notes
- Output order always matches input order
- Best suited for pure, side-effect-free functions
- Automatically infers output element type via `Base.promote_op`
"""
function parmap(f, data; nchunks=Threads.nthreads())
    T = Base.promote_op(f, eltype(data))
    result = Vector{T}(undef, length(data))
    @sync for idcs in OhMyThreads.index_chunks(data; n=nchunks)
        @spawn begin
            @inbounds for i in idcs
                result[i] = f(data[i])
            end
        end
    end
    return result
end
