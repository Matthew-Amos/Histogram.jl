# Histograms.jl

This is a simple package for describing a continuous variable with a set of contiguous bins.

# Examples

```julia
julia> using Histograms

julia> b = Bin(1, 20.5)
Bin(1, 20.5, >=, <)

julia> b(2)
true

julia> b.([0, 1, 20.5, 30])
4-element BitArray{1}:
 0
 1
 0
 0

julia> Bin(0.5, 0.8, >, <=)
Bin(0.5, 0.8, >, <=)

julia> h = Histogram([Bin(1, 5), Bin(5, 10)])
Histogram(Bin[Bin(1, 5, >=, <), Bin(5, 10, >=, <)])

julia> h[1]
Bin(1, 5, >=, <)

julia> h([2, 2, 6, 9])
2-element Array{Float64,1}:
 0.5
 0.5

julia> h = Histogram(randn(500), 4)
Histogram(Bin[Bin(-Inf, -0.6970630349428795, >=, <), Bin(-0.6970630349428795, 0.059893308055948793, >=, <), Bin(0.059893308055948793, 0.612623377088124, >=, <), Bin(0.612623377088124, 4.053317940567178, >=, <), Bin(4.053317940567178, Inf, >=, <)])

julia> h(randn(500))
5-element Array{Float64,1}:
 0.252
 0.282
 0.21
 0.256
 0.0
```
