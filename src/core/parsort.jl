
abstract type Ordering end
struct Forward <: Ordering end
struct Reverse <: Ordering end

@inline isless(::Forward, a, b) = a < b
@inline isless(::Reverse, a, b) = a > b
@inline lt(o::Ordering, a, b) = isless(o, a, b)
@inline midpoint(lo::Int, hi::Int) = lo + ((hi - lo) >>> 1)

const PARALLEL_THRESHOLD = 10_000
const SMALL_THRESHOLD = 64
const task_queue = Channel{Tuple{Vector,Int,Int,Ordering,Int}}(Inf)

"""
    sort_numeric!(v::Vector{T}, o::Ordering = Forward()) where {T <: Real}

Efficient in-place parallel sorting for numeric vectors `v`, using a hybrid introsort strategy with multithreading.

This function dynamically selects the most efficient sorting method depending on the vector's size and order:

- Uses `insertion_sort!` for small vectors (`length ≤ SMALL_THRESHOLD`)
- Detects already sorted or reverse-sorted input for early return
- Uses a **parallel introsort** (quicksort + heapsort + insertion sort) for general cases
- Automatically parallelizes using native Julia threads (`Threads.@spawn` + `Channel`)

### Arguments
- `v`: A vector of real numbers (`Vector{T}` where `T <: Real`), such as `Vector{Int}` or `Vector{Float64}`
- `o`: An `Ordering`, either `Forward()` (ascending, default) or `Reverse()` (descending)

### WARNING:
- The parallel introsort uses **quicksort and heapsort**, which are **not stable** sorting algorithms.  
- This means equal elements may not keep their original order.


### Example
```julia
v1 = rand(Int, 1_000_000)
sort_numeric!(v1)  # Ascending sort

v2 = randn(1_000_000)
sort_numeric!(v2, Reverse())  # Descending sort
```
"""
function sort_numeric!(v::Vector{T}, o::Ordering=Forward()) where {T<:Real}
    n = length(v)
    n <= SMALL_THRESHOLD && return insertion_sort!(v, o)

    if issorted_custom(v, o)
        return v
    elseif issorted_custom(v, reverse_ordering(o))
        reverse!(v)
        return v
    end

    return introsort_queue!(v, o)
end


"""
    insertion_sort!(v::Vector, o::Ordering)

In-place insertion sort of vector `v` using ordering `o`.
"""

function insertion_sort!(v::Vector, o::Ordering)
    return insertion_sort!(v, 1, length(v), o)
end

"""
    insertion_sort!(v::Vector, o::Ordering)

Simple in-place insertion sort for small arrays.
Stable and adaptive to nearly-sorted data.
"""
function insertion_sort!(v::Vector, lo::Int, hi::Int, o::Ordering)
    @inbounds for i in (lo+1):hi
        temp = v[i]
        j = i - 1
        while j >= lo && isless(o, temp, v[j])
            v[j+1] = v[j]
            j -= 1
        end
        v[j+1] = temp
    end
    return v
end

function issorted_custom(v, o::Ordering)
    n = length(v)
    if o isa Forward
        @inbounds for i in 2:n
            v[i] < v[i-1] && return false
        end
    else
        @inbounds for i in 2:n
            v[i] > v[i-1] && return false
        end
    end
    return true
end

function reverse_ordering(o::Ordering)
    o isa Forward && return Reverse()
    o isa Reverse && return Forward()
end



@inline function selectpivot!(v::AbstractVector, lo::Int, hi::Int, o::Ordering)
    mi = midpoint(lo, hi)
    if lt(o, v[lo], v[mi])
        v[mi], v[lo] = v[lo], v[mi]
    end
    if lt(o, v[hi], v[lo])
        if lt(o, v[hi], v[mi])
            v[hi], v[lo], v[mi] = v[lo], v[mi], v[hi]
        else
            v[hi], v[lo] = v[lo], v[hi]
        end
    end
    return v[lo]
end


function partition!(v::AbstractVector, lo::Int, hi::Int, o::Ordering)
    pivot = selectpivot!(v, lo, hi, o)
    i, j = lo, hi
    while true
        i += 1
        j -= 1
        while i <= hi && lt(o, v[i], pivot)
            i += 1
        end
        while j >= lo && lt(o, pivot, v[j])
            j -= 1
        end
        if i >= j
            break
        end
        v[i], v[j] = v[j], v[i]
    end
    v[lo], v[j] = v[j], pivot
    return j
end




function worker_loop(task_queue, active_tasks)
    while true
        task = try
            take!(task_queue)
        catch
            break
        end
        v, lo, hi, o, depth = task
        parallel_introsort_step!(task_queue, active_tasks, v, lo, hi, o, depth)
        Threads.atomic_sub!(active_tasks, 1)
    end
end

function parallel_introsort_step!(task_queue, active_tasks, v, lo, hi, o, depth)
    if hi - lo <= SMALL_THRESHOLD
        insertion_sort!(v, lo, hi, o)
        return
    elseif depth <= 0
        heapsort!(v, lo, hi, o)
        return
    end

    j = partition!(v, lo, hi, o)

    if (hi - lo + 1) > 2 * PARALLEL_THRESHOLD
        Threads.atomic_add!(active_tasks, 2)
        put!(task_queue, (v, lo, j, o, depth - 1))
        put!(task_queue, (v, j + 1, hi, o, depth - 1))
    else
        parallel_introsort_step!(task_queue, active_tasks, v, lo, j, o, depth - 1)
        parallel_introsort_step!(task_queue, active_tasks, v, j + 1, hi, o, depth - 1)
    end
end

function parallel_introsort_queue!(v::Vector{T}, o::Ordering=Forward()) where {T}
    task_queue = Channel{Tuple{Vector,Int,Int,Ordering,Int}}(Inf)
    active_tasks = Threads.Atomic{Int}(0)

    n = length(v)
    maxdepth = 2 * floor(Int, log2(n))
    Threads.atomic_add!(active_tasks, 1)
    put!(task_queue, (v, 1, n, o, maxdepth))

    workers = [Base.Threads.@spawn worker_loop(task_queue, active_tasks) for _ in 1:Threads.nthreads()]

    while active_tasks[] > 0
        sleep(0.001)
    end
    close(task_queue)
    foreach(wait, workers)
end

function introsort_queue!(v::Vector{T}, o::Ordering=Forward()) where {T}
    parallel_introsort_queue!(v, o)
end




function heapsort!(v::Vector, lo::Int, hi::Int, o::Ordering)
    n = hi - lo + 1
    @inbounds for start in div(n, 2):-1:1
        sift_down(v, lo, hi, start, o)
    end
    @inbounds for last in n:-1:2
        v[lo], v[lo+last-1] = v[lo+last-1], v[lo]
        sift_down(v, lo, lo + last - 2, 1, o)
    end
    return v
end

@inline function sift_down(v::Vector, lo::Int, hi::Int, start::Int, o::Ordering)
    root = start
    n = hi - lo + 1
    @inbounds while 2 * root <= n
        child = 2 * root
        if child < n && isless(o, v[lo+child-1], v[lo+child])
            child += 1
        end
        if isless(o, v[lo+root-1], v[lo+child-1])
            v[lo+root-1], v[lo+child-1] = v[lo+child-1], v[lo+root-1]
            root = child
        else
            break
        end
    end
end