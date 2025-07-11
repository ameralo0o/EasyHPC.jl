# Parallel maximum
"""
    parmax(data)

Compute the maximum value in `data` using parallel reduction.

### Arguments
- `data`: An indexable collection (e.g. `Vector`, `Range`) of numeric or orderable values

### Returns
- The maximum element of `data`, computed in parallel

### Throws
- `ArgumentError` if `data` is empty

### Example
```julia
parmax([1, 5, 3, 9])  # → 9
```
"""
function parmax(data)
    isempty(data) && throw(ArgumentError("Cannot reduce empty collection"))
    return parreduce(max, data)
end

# Parallel minimum
"""
    parmin(data)

Compute the minimum value in `data` using parallel reduction.

### Arguments
- `data`: An indexable collection of orderable values

### Returns
- The minimum element of `data`, computed in parallel

### Throws
- `ArgumentError` if `data` is empty

### Example
```julia
parmin([3, 7, -2, 10])  # → -2
```
"""
function parmin(data)
    isempty(data) && throw(ArgumentError("Cannot reduce empty collection"))
    return parreduce(min, data)
end

# Parallel all - boolean array
"""
    parall(data::AbstractVector{Bool})

Check in parallel whether **all elements** in the boolean vector `data` are `true`.

Returns early as soon as a `false` is found (short-circuiting).

### Returns
- `true` if all elements are `true`, otherwise `false`

### Example
```julia
parall([true, true, true])    # → true
parall([true, false, true])   # → false
```
"""
function parall(data::AbstractVector{Bool}; nchunks=nthreads())
    result = Atomic{Bool}(true)

    @sync for idcs in OhMyThreads.index_chunks(data; n=nchunks)
        Threads.@spawn begin
            for x in @view data[idcs]
                !result[] && break
                if !x
                    result[] = false
                    break
                end
            end
        end
    end

    return result[]
end

# Parallel all - predicate version
"""
    parall(f, data; nchunks = nthreads())

Check in parallel whether `f(x)` returns `true` for **all** elements `x` in `data`.

Short-circuits and returns `false` as soon as a failing element is found.

### Arguments
- `f`: A predicate function
- `data`: A collection of values
- `nchunks`: Number of chunks for parallel evaluation (default: `nthreads()`)

### Returns
- `true` if `f(x)` is true for all elements, otherwise `false`

### Example
```julia
parall(iseven, [2, 4, 6])     # → true
parall(iseven, [2, 3, 4])     # → false
```
"""
function parall(f::Function, data; nchunks=nthreads())
    result = Atomic{Bool}(true)

    @sync for idcs in OhMyThreads.index_chunks(data; n=nchunks)
        @spawn begin
            for x in @view data[idcs]
                !result[] && break
                if !f(x)
                    result[] = false
                    break
                end
            end
        end
    end

    return result[]
end

# Parallel all - fallback
"""
    parall(data)

Error fallback method if `data` is not a `Vector{Bool}`.

### Throws
- `ArgumentError`: Always

### Example
```julia
parall("hello")  # throws error
```
"""
function parall(data::Any)
    throw(ArgumentError("Expected a Bool vector for parall(data), got $(typeof(data))"))
end

# Parallel any - boolean array
"""
    parany(data::AbstractVector{Bool})

Check in parallel whether **any element** in the boolean vector `data` is `true`.

Returns early as soon as a `true` is found (short-circuiting).

### Returns
- `true` if any element is `true`, otherwise `false`

### Example
```julia
parany([false, false, true])   # → true
parany([false, false])         # → false
```
"""
function parany(data::AbstractVector{Bool}; nchunks=nthreads())
    result = Atomic{Bool}(false)

    @sync for idcs in OhMyThreads.index_chunks(data; n=nchunks)
        @spawn begin
            for x in @view data[idcs]
                result[] && break
                if x
                    result[] = true
                    break
                end
            end
        end
    end

    return result[]
end

# Parallel any - predicate version
"""
    parany(f, data; nchunks = nthreads())

Check in parallel whether `f(x)` returns `true` for **any** element in `data`.

Short-circuits as soon as a `true` result is found.

### Arguments
- `f`: A predicate function
- `data`: A collection of values
- `nchunks`: Number of chunks for parallel evaluation (default: `nthreads()`)

### Returns
- `true` if any element satisfies the predicate, otherwise `false`

### Example
```julia
parany(isodd, [2, 4, 6])       # → false
parany(isodd, [2, 3, 4])       # → true
```
"""
function parany(f::Function, data; nchunks=nthreads())
    result = Atomic{Bool}(false)

    @sync for idcs in OhMyThreads.index_chunks(data; n=nchunks)
        @spawn begin
            for x in @view data[idcs]
                result[] && break
                if f(x)
                    result[] = true
                    break
                end
            end
        end
    end

    return result[]
end

# Parallel any - fallback
"""
    parany(data)

Error fallback method if `data` is not a `Vector{Bool}`.

### Throws
- `ArgumentError`: Always

### Example
```julia
parany(42)  # throws error
```
"""
function parany(data::Any)
    throw(ArgumentError("Expected a Bool vector for parany(data), got $(typeof(data))"))
end

# Parallel count
"""
    parcount(f, data; nchunks = nthreads())

Count the number of elements in `data` for which the predicate `f(x)` returns `true`, using parallel reduction.

Falls back to serial `count` for small inputs.

### Arguments
- `f`: A predicate function returning `Bool`
- `data`: A collection of values
- `nchunks`: Number of chunks (default: `nthreads()`)

### Returns
- `Int`: The number of elements satisfying `f(x)`

### Throws
- `TypeError`: If `f(x)` does not return a `Bool` (checked on the first element)

### Example
```julia
parcount(iseven, 1:10)                 # → 5
parcount(x -> x > 100, [10, 20, 150])  # → 1
```
"""
function parcount(f, data; nchunks=nthreads())
    n = length(data)
    n < 10_000 && return count(f, data)

    !isempty(data) && check_first(f, data[begin])

    counts = zeros(Int, nchunks)
    chunks = OhMyThreads.index_chunks(data; n=nchunks)

    Threads.@threads :static for i in 1:nchunks
        idcs = chunks[i]
        local cnt = 0
        @inbounds for j in idcs
            cnt += f(data[j]) ? 1 : 0
        end
        counts[i] = cnt
    end
    return sum(counts)
end

# Internal type check
@inline check_first(f, x) = (fx = f(x); fx isa Bool || throw_typeerr(fx))
@noinline throw_typeerr(fx) = throw(TypeError(:parcount, Bool, typeof(fx)))
