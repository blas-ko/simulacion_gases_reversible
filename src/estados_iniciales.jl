function cubito(raiz_cubica_particulas::Int64, centro::Vector{Float64}, lado::Float64)

    mitad = lado/2
    x_cen, y_cen, z_cen = centro

    xs = linspace(x_cen - mitad, x_cen + mitad, raiz_cubica_particulas)
    ys = linspace(y_cen - mitad, y_cen + mitad, raiz_cubica_particulas)
    zs = linspace(z_cen - mitad, z_cen + mitad, raiz_cubica_particulas)

    particulas = raiz_cubica_particulas ^ 3.0
    res = Float64[]

    for x in xs, y in ys, z in zs
        push!(res, x, y ,z)
    end
    res
end

function fluctuacion_gaussiana{T<:Float64}(X_0::Vector{T}, media::T = 0.0, desv_std::T = 0.1)
    largo = length(X_0)
    distribucion = Normal(media, desv_std)
    fluctuaciones = rand(distribucion, largo)
    X_0 + fluctuaciones
end
