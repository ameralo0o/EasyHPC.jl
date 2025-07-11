### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ f9a9bacc-5e70-11f0-0bc6-ede822a3e295
using Pkg

# ╔═╡ 079d831f-1cd5-48da-bcae-e9400da98dea
Pkg.activate("/home/mahmoud/Desktop/julia_porject/EasyHPC.jl")

# ╔═╡ 2f7fa30e-b225-4688-9ecf-e2e54a50f02b
using EasyHPC

# ╔═╡ 55185048-d938-4058-8bf6-a74e8889fb16
using BenchmarkTools;

# ╔═╡ 62ec4628-207b-4bcd-b721-d258c53f9b71
using Random

# ╔═╡ fc49b7bf-dec1-4e46-935e-c1fe418d05b6
Markdown.parse("Willkommen zu meiner Präsentation über XYZ!")

# ╔═╡ 17ebb91c-87ab-4de6-9ab6-127fc3bf74da
data1 = rand(Float64, 10^6)  

# ╔═╡ 86ef906f-02d8-4428-92b4-5c246ff17787
data2 = deepcopy(data1)

# ╔═╡ 81e8e17b-b68c-40a8-8394-42a51c82f2bc
@benchmark sort!($data1)

# ╔═╡ 28529943-a2aa-47dc-b2d7-0149acb01e21
@benchmark sort_numeric!($data2)

# ╔═╡ Cell order:
# ╠═f9a9bacc-5e70-11f0-0bc6-ede822a3e295
# ╠═079d831f-1cd5-48da-bcae-e9400da98dea
# ╠═2f7fa30e-b225-4688-9ecf-e2e54a50f02b
# ╠═55185048-d938-4058-8bf6-a74e8889fb16
# ╠═62ec4628-207b-4bcd-b721-d258c53f9b71
# ╟─fc49b7bf-dec1-4e46-935e-c1fe418d05b6
# ╠═17ebb91c-87ab-4de6-9ab6-127fc3bf74da
# ╟─86ef906f-02d8-4428-92b4-5c246ff17787
# ╠═81e8e17b-b68c-40a8-8394-42a51c82f2bc
# ╠═28529943-a2aa-47dc-b2d7-0149acb01e21
