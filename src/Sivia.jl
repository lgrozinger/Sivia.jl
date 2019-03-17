module Sivia

export
    sivia,
    dsivia,
    merge,
    merge!,
    dmerge,
    intersect,
    project,
    IntervalParameter,
    SiviaResults,
    siviaresults

using IntervalArithmetic
using RecipesBase
using Distributed

include("settools.jl")
include("sivia.jl")
include("plotrecipes.jl")

end
