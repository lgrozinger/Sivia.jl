using RecipesBase

## 3d IntervalBox plotting
@recipe function f(v::Vector{T}) where T<:IntervalBox{3}
    xs = Float64[]
    ys = Float64[]
    zs = Float64[]

    seriestype := :surface

    for xyz in v
        (x, y, z) = xyz
        append!(xs, [x.lo, x.hi, x.lo, x.hi, x.lo, x.hi, x.lo, x.hi])
        append!(ys, [y.lo, y.lo, y.hi, y.hi, y.lo, y.lo, y.hi, y.hi])
        append!(zs, [z.lo, z.lo, z.lo, z.lo, z.hi, z.hi, z.hi, z.hi])

    end
    xs, ys, zs

end


## Parameter boxplot
@recipe function f(A::Vector{IntervalParameter}, colour=1, alpha=0.25)

    yticks := (1:length(A), map(p -> p.name, A))
    legend := :none
    xlabel := "Parameter Value"
    lines = []
    for t in 1:length(A)
        p = A[t]
        for i in p.intervals
            push!(lines, ([i.lo, i.hi], repeat([t], 2)))
        end
    end

    ## intervals and markers
    for line in lines
        @series begin
            seriestype := :path
            seriescolor := colour
            linewidth := 5
            linecolor := colour
            line[1], line[2]
        end
        @series begin
            seriestype := :scatter
            seriescolor := colour
            markershape := :vline
            linewidth := 5
            linecolor := colour
            markersize := 5
            line[1], line[2]
        end
    end

    ## searchlights
    ## collect into levels
    levels = [filter(x -> x[2][1] == l, lines) for l in 1:length(A)]
    for i in 1:length(levels)-1
        upper = levels[i]
        lower = levels[i+1]

        for u in upper
            uxs = [u[1][1], u[1][2]]
            uys = [u[2][1], u[2][1]]
            for l in lower
                xs = []
                ys = []
                append!(xs, uxs)
                append!(ys, uys)
                append!(xs, [l[1][2], l[1][1], uxs[1]])
                append!(ys, [l[2][1], l[2][1], uys[1]])
                @series begin
                    seriestype := :shape
                    seriescolor := colour
                    fillalpha := alpha
                    fillcolor := colour
                    linestyle := :dot
                    xs, ys
                end
                @series begin
                    seriestype := :path
                    seriescolor := colour
                    linestyle := :dot
                    [xs[2], xs[3]], [ys[2], ys[3]]
                end
                @series begin
                    seriestype := :path
                    seriescolor := colour
                    linecolor := colour
                    linestyle := :dot
                    [xs[1], xs[4]], [ys[1], ys[4]]
                end
            end
        end
    end
end

function test_plot()
    spaces = example()
    spaces = merge(spaces)
    p1 = complete_merge(projection(spaces, 1))
    p1 = IntervalParameter([merge(p1[1], p1[2]).v[1]], "P1")
    p2 = complete_merge(projection(spaces, 2))
    p2 = IntervalParameter([p2[1].v[1]], "P2")

    plot([p1, p2])
end
