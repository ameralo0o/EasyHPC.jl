module EasyHPC

__precompile__()

# ─────────────────────────────────────────────────────────────
# Imports & threading helpers
using Base.Threads: @spawn, @sync, Atomic, atomic_add!, nthreads
using OhMyThreads                      # chunk helpers for parallel loops

# ─────────────────────────────────────────────────────────────
# Core functionality
include("core/parsum.jl")
include("core/parmap.jl")
include("core/parreduce.jl")
include("core/parsort.jl")

export parsum, parmap, parreduce, sort_numeric!, sort_numeric_seq!

# ─────────────────────────────────────────────────────────────
# Logic helpers
include("logic/parlogic.jl")

export parany, parall, parcount, parmin, parmax

end # module EasyHPC
