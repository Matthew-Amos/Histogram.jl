module Histograms

export Bin, Histogram

using Statistics: quantile

"""
    Bin(lb, ub; lbf = (>=), ubf = (<))

# Description
A bin specifying a lowerbound, upperbound, and optional comparison operators.

Passing a value to an instantiated `Bin` returns a logical value indicating whether the
value falls within the interval.

# Examples
```jldoctest
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

julia> Bin(0.5, 0.8, lbf=(>), ubf=(<=))
Bin(0.5, 0.8, >, <=)
```
"""
struct Bin
    lb
    ub
    lbf::Function
    ubf::Function
end

Bin(lb, ub; lbf=(>=), ubf=(<)) = Bin(lb, ub, lbf, ubf)
(b::Bin)(v) = b.lbf(v, b.lb) & b.ubf(v, b.ub)

"""
    Histogram([Bin(1, 2), Bin(3, 4)])
    Histogram(randn(1000), 10, lower_tail=true, upper_tail=true; nargs...)

A set of contiguous `Bin` that describes a distribution.

Can be instantiated manually by passing a `Vector{Bin}`, or by passing a data vector
and the number of desired bins. Cut points are determined via `Statistics.quantile` and
by default extends the tails out to infinity. Default behavior will not include positive Inf.

Passing a vector to an instantiated `Histogram` returns a frequency vector indicating the percent
of values that fall into each positional `Bin`.

# Examples

```jldoctest
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
"""
struct Histogram
    bins::Vector{Bin}
end

function Histogram(v, n, lower_tail=true, upper_tail=true; nargs...)
    @assert n > 1

    q = quantile(v, collect(1:n) ./ n)
    if lower_tail q=vcat(-Inf, q) end
    if upper_tail q=vcat(q, Inf) end

    bins = Vector{Bin}(undef, length(q)-1)
    @inbounds for i in 2:length(q)
        bins[i-1] = Bin(q[i-1], q[i]; nargs...)
    end

    Histogram(bins)
end

Base.length(h::Histogram) = length(h.bins)
Base.getindex(h::Histogram, i) = h.bins[i]

function (h::Histogram)(v)
    k = length(h)
    n = length(v)
    freq = Vector{Float64}(undef, k)
    @inbounds for i in 1:k
        freq[i] = sum(h[i].(v))/n
    end
    freq
end

end # module
