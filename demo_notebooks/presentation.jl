### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ f9a9bacc-5e70-11f0-0bc6-ede822a3e295
using Pkg

# ╔═╡ 079d831f-1cd5-48da-bcae-e9400da98dea
Pkg.add(url="https://github.com/ameralo0o/EasyHPC.jl")

# ╔═╡ cd3915b5-07ee-42f6-a032-d86b79427405
Pkg.add(url="https://github.com/ameralo0o/EasyHPC.jl")

# ╔═╡ 2f7fa30e-b225-4688-9ecf-e2e54a50f02b
using EasyHPC

# ╔═╡ 55185048-d938-4058-8bf6-a74e8889fb16
using BenchmarkTools;

# ╔═╡ 62ec4628-207b-4bcd-b721-d258c53f9b71
using Random

# ╔═╡ fc49b7bf-dec1-4e46-935e-c1fe418d05b6
display(Markdown.parse("Welcome to my presentation on EasyHPC.jl!"))

# ╔═╡ 17ebb91c-87ab-4de6-9ab6-127fc3bf74da
data1 = rand(Float64, 10^6) 

# ╔═╡ 86ef906f-02d8-4428-92b4-5c246ff17787
data2 = deepcopy(data1)

# ╔═╡ 93e1573f-e355-4c3a-af23-2d16c0d36424
display(Markdown.parse("Base.sort! vs EasyHPC.sort_numeric!"))

# ╔═╡ fc6e86ed-3853-4677-843a-89fdfc7a4b86
@benchmark sort!(deepcopy($data1))

# ╔═╡ 28529943-a2aa-47dc-b2d7-0149acb01e21
@benchmark sort_numeric!(deepcopy($data2))

# ╔═╡ 3cf3423a-2b1d-43d4-b23f-a8fb48deade7
display(Markdown.parse("Base.map vs EasyHPC.parmap"))

# ╔═╡ 5d072328-52db-4782-94c8-a70173a8e808
f(x) = sqrt(x) * sin(x)

# ╔═╡ 1c179da9-a91d-49df-b92f-e42f6dfa0e70
 @benchmark map($f, $data1)

# ╔═╡ cceedd9d-f328-4a2e-9cdd-b4c28b3a196e
@benchmark parmap($f, $data1)

# ╔═╡ 8f2479c6-5fb1-49b8-9c3f-c1e809ca7d3a
display(Markdown.parse("reduce vs parreduce"))

# ╔═╡ ab60f70e-bc73-4707-92f8-bae7d737c3a4
@benchmark reduce(/, $data1)

# ╔═╡ 2412c7b5-8232-465b-9e17-359d9986e486
@benchmark parreduce(/, $data1)

# ╔═╡ 5efc0bae-1cbb-4195-a9f2-0cda2b209a9a
display(Markdown.parse("sum vs parsum"))

# ╔═╡ 02eab61c-1c5f-4842-931a-9d12c2994d57
data5 = rand(10^7)

# ╔═╡ f32e401a-2bbf-41bc-bfd6-c09428099c2f
@benchmark sum($data5)

# ╔═╡ 2ad9eb29-0ceb-4460-a8d9-00e645f482ab
@benchmark parsum($data5)

# ╔═╡ b68b02d3-cbd2-4a5d-bad3-01045ec43760
display(Markdown.parse("max, min vs parmax, parmin"))

# ╔═╡ e2e5a686-3c1a-4745-87eb-49a142cd0fda
@benchmark minimum($data1)

# ╔═╡ 85cd76bb-79a2-4214-8dd0-010e8efafa30
@benchmark parmin($data1)

# ╔═╡ 25b8464a-07e0-445e-bab1-a9349cb9b899
@benchmark maximum($data1)

# ╔═╡ 6df3192b-edd7-401f-b1b4-e09b7a257eb7
@benchmark parmax($data1)

# ╔═╡ 76138962-42e8-4838-b781-12e3cafebdca
display(Markdown.parse("count vs parcount"))

# ╔═╡ 122b6085-eeb7-4d1d-8777-96792a0c1868
predicate = x -> begin
    s = 0.0
    for i in 1:10
        s += sin(x)^2 + cos(x)^2
    end
    s > 9.9
end

# ╔═╡ 7554fe31-8c8d-4e3a-b683-6b48ff4dddef
@benchmark count($predicate, $data1)

# ╔═╡ caa18317-4238-4602-9131-8f961019942a
@benchmark parcount($predicate, $data1)

# ╔═╡ 550e31c2-a531-4fe1-8b77-c848b00b9c8c
 

# ╔═╡ 1b6213eb-ab9b-4b3a-abe6-611e62605c72
@benchmark count(x -> x > 0.5, $data1)

# ╔═╡ f6f533ab-f2f8-409e-930a-50337662a4f2
@benchmark parcount(x -> x > 0.5, $data1)

# ╔═╡ f4f49d04-7605-4fe6-a20b-84d04625f1cf


# ╔═╡ 24767e45-519a-4427-8bd8-a0b07826c239
display(Markdown.parse("all, any vs parall, parany"))

# ╔═╡ ec5b9ca6-ef5a-4963-b3cb-e60b5e7cd76e
B = rand(Bool, 10^6)

# ╔═╡ ee645bd0-f462-479b-9030-b43d182b3d88
@benchmark all($B)

# ╔═╡ 08103f52-e0e5-4a19-892f-3b0cb76c7820
@benchmark parall($B)

# ╔═╡ ae046ac0-cddb-4d20-8d77-0e0ef3f2dcdd
@benchmark any($B)

# ╔═╡ 592d5820-986b-4d8a-991b-60751559b21f
@benchmark parany($B)

# ╔═╡ c4f25f2e-47fb-47bc-8653-52edd8942b67
C = fill(true, 10^6)

# ╔═╡ 5c855627-f67e-4023-aa80-7eefefed4fd0
C[end] = false

# ╔═╡ 917d8901-baa3-43dd-a10b-ab3741521621
@benchmark all($C)

# ╔═╡ 8877e845-2d5f-4401-a536-e35b6b71970a
@benchmark parall($C)

# ╔═╡ 86dc93bf-ac9e-4340-8413-a80f0eca94df
D = fill(false, 10^6)

# ╔═╡ d0d5fa93-a9e3-4a95-aae1-fa4ac6cc58db
D[end] = true

# ╔═╡ 22859a01-b0f0-434e-9921-f28ced16a961
@benchmark any($D)

# ╔═╡ 92a1ad94-6b5e-49db-a67b-d1c4949d2061
@benchmark parany($D)

# ╔═╡ Cell order:
# ╠═f9a9bacc-5e70-11f0-0bc6-ede822a3e295
# ╟─079d831f-1cd5-48da-bcae-e9400da98dea
# ╠═cd3915b5-07ee-42f6-a032-d86b79427405
# ╠═2f7fa30e-b225-4688-9ecf-e2e54a50f02b
# ╠═55185048-d938-4058-8bf6-a74e8889fb16
# ╠═62ec4628-207b-4bcd-b721-d258c53f9b71
# ╟─fc49b7bf-dec1-4e46-935e-c1fe418d05b6
# ╠═17ebb91c-87ab-4de6-9ab6-127fc3bf74da
# ╠═86ef906f-02d8-4428-92b4-5c246ff17787
# ╟─93e1573f-e355-4c3a-af23-2d16c0d36424
# ╠═fc6e86ed-3853-4677-843a-89fdfc7a4b86
# ╠═28529943-a2aa-47dc-b2d7-0149acb01e21
# ╟─3cf3423a-2b1d-43d4-b23f-a8fb48deade7
# ╠═5d072328-52db-4782-94c8-a70173a8e808
# ╠═1c179da9-a91d-49df-b92f-e42f6dfa0e70
# ╠═cceedd9d-f328-4a2e-9cdd-b4c28b3a196e
# ╟─8f2479c6-5fb1-49b8-9c3f-c1e809ca7d3a
# ╠═ab60f70e-bc73-4707-92f8-bae7d737c3a4
# ╠═2412c7b5-8232-465b-9e17-359d9986e486
# ╟─5efc0bae-1cbb-4195-a9f2-0cda2b209a9a
# ╠═02eab61c-1c5f-4842-931a-9d12c2994d57
# ╠═f32e401a-2bbf-41bc-bfd6-c09428099c2f
# ╠═2ad9eb29-0ceb-4460-a8d9-00e645f482ab
# ╠═b68b02d3-cbd2-4a5d-bad3-01045ec43760
# ╠═e2e5a686-3c1a-4745-87eb-49a142cd0fda
# ╠═85cd76bb-79a2-4214-8dd0-010e8efafa30
# ╠═25b8464a-07e0-445e-bab1-a9349cb9b899
# ╠═6df3192b-edd7-401f-b1b4-e09b7a257eb7
# ╠═76138962-42e8-4838-b781-12e3cafebdca
# ╠═122b6085-eeb7-4d1d-8777-96792a0c1868
# ╠═7554fe31-8c8d-4e3a-b683-6b48ff4dddef
# ╠═caa18317-4238-4602-9131-8f961019942a
# ╠═550e31c2-a531-4fe1-8b77-c848b00b9c8c
# ╠═1b6213eb-ab9b-4b3a-abe6-611e62605c72
# ╠═f6f533ab-f2f8-409e-930a-50337662a4f2
# ╠═f4f49d04-7605-4fe6-a20b-84d04625f1cf
# ╠═24767e45-519a-4427-8bd8-a0b07826c239
# ╠═ec5b9ca6-ef5a-4963-b3cb-e60b5e7cd76e
# ╠═ee645bd0-f462-479b-9030-b43d182b3d88
# ╠═08103f52-e0e5-4a19-892f-3b0cb76c7820
# ╠═ae046ac0-cddb-4d20-8d77-0e0ef3f2dcdd
# ╠═592d5820-986b-4d8a-991b-60751559b21f
# ╠═c4f25f2e-47fb-47bc-8653-52edd8942b67
# ╠═5c855627-f67e-4023-aa80-7eefefed4fd0
# ╠═917d8901-baa3-43dd-a10b-ab3741521621
# ╠═8877e845-2d5f-4401-a536-e35b6b71970a
# ╠═86dc93bf-ac9e-4340-8413-a80f0eca94df
# ╠═d0d5fa93-a9e3-4a95-aae1-fa4ac6cc58db
# ╠═22859a01-b0f0-434e-9921-f28ced16a961
# ╠═92a1ad94-6b5e-49db-a67b-d1c4949d2061
