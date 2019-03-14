function sivia(p₀::IntervalBox{M,T},
               f::Function,
               Y::IntervalBox{N,T},
               ϵ::T;
               feas::Function=p->true,
               bisector::Function=bisect,
               memlim::Integer=2^30) where {M,N,T<:Real}


    solutions = Vector{IntervalBox{M,T}}()
    L = Vector{IntervalBox{M,T}}(p₀)

    while length(L) != 0
        p = pop!(L)
        feasable = feas(p)

        if feasable
            image = f(p)
            if image ⊂ Y
                push!(solutions, p)
                if sizeof(solutions) > memlim
                    solutions = merge_sort_merge(solutions)
                end
            elseif isempty(image ∩ Y)
            elseif diam(p) < ϵ
            else
                p₁, p₂ = bisector(p)
                push!(L, p₁)
                push!(L, p₂)
            end
        end
    end

    return solutions
end


function dsivia(p₀::IntervalBox{M,T},
                f::Function,
                Y::IntervalBox{N,T},
                ϵ::T,
                numWorkers::Integer;
                feas::Function=p->true,
                sivfun::Function=sivia) where {N,M,T<:Real}


    L = Vector{IntervalBox{M,T}}([p₀])
    while length(L) < numWorkers
        L = bisect.(L)
        L = reduce(vcat, [collect(i) for i in L])
    end

    futures = (p -> @spawn sivfun(p, f, Y, ϵ, feas=feas)).(L)
    results = fetch.(futures)
    reduce(vcat, results)
end

function example()
    f(p) = IntervalBox(p[1]^2 + p[2]^2 + p[1] * p[2])
    Y = IntervalBox(1.0..2.0)
    x₀ = (-10.0..10.0) × (-10.0..10.0)
    sivia(x₀, f, Y, 0.001)
end
