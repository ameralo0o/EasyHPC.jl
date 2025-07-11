# EasyHPC.jl

 
This package provides fast and simple parallel operations for CPU-bound workloads, including:

- `parmap`: Parallel `map`
- `parreduce`: Parallel `reduce`
- `parsum`: Parallel sum
- `parcount`: Parallel count
- `parany` / `parall`: Parallel logical checks
- `sort_numeric!`: High-performance hybrid parallel sort

## Features

- Thread-safe, allocation-efficient implementations
- Automatic chunking via [`OhMyThreads.jl`](https://github.com/juliohm/OhMyThreads.jl)
- In-place and out-of-place support
- Works with `Int`, `Float64`, and other numeric types
- Scales well on multi-core machines

## Installation

```julia
pkg> add EasyHPC
```

## Getting Started

Here's a simple example using `parmap` and `parreduce`:

```julia
using EasyHPC

data = 1:1_000_000

# Square all elements in parallel
squares = parmap(x -> x^2, data)

# Sum them using parallel reduction
total = parreduce(+, squares)
```

## Table of Contents

```@contents
Pages = ["index.md", "api.md"]
Depth = 2
```

For detailed function reference, see the API Reference.
