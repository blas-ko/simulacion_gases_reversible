function bifase(raiz_cubica_particulas::Int64, lado::Float64; eje_division = "x")

    Δ = lado/raiz_cubica_particulas
    δ = Δ/2

    xs = linspace( δ, lado-δ, raiz_cubica_particulas )
    ys = linspace( δ, lado-δ, raiz_cubica_particulas )
    zs = linspace( δ, lado-δ, raiz_cubica_particulas )

    particulas = raiz_cubica_particulas ^ 3
    coordenadas = Float64[]
    sizehint!(coordenadas, 3*particulas)

    if eje_division == "x"

      for x in xs, y in ys, z in zs
          push!(coordenadas, x, y ,z)
      end
    elseif eje_division == "y"

      for y in ys, x in xs ,z in zs
          push!(coordenadas, x, y ,z)
      end
    elseif eje_division == "z"

      for z in zs, x in xs, y in ys
          push!(coordenadas, x, y ,z)
      end
    else
      error("Los ejes posibles son: \"x\", \"y\", \"z\".")
    end
    return coordenadas
end

function cubito(raiz_cubica_particulas::Int64, centro::Vector{Float64}, lado::Float64)

    mitad = lado/2
    x_cen, y_cen, z_cen = centro

    xs = linspace(x_cen - mitad, x_cen + mitad, raiz_cubica_particulas)
    ys = linspace(y_cen - mitad, y_cen + mitad, raiz_cubica_particulas)
    zs = linspace(z_cen - mitad, z_cen + mitad, raiz_cubica_particulas)

    particulas = raiz_cubica_particulas ^ 3
    coordenadas = Float64[]
    sizehint!(coordenadas, 3*particulas)

    for x in xs, y in ys, z in zs
        push!(coordenadas, x, y ,z)
    end
    coordenadas
end

function fluctuacion_gaussiana{T<:Float64}(X_0::Vector{T}, lado_caja::T ,media::T = 0.0, desv_std::T = 0.1)
    largo = length(X_0)
    X_1 = zeros(largo)
    distribucion = Normal(media, desv_std)
    fluctuaciones = rand(distribucion, largo)
    for i in 1:largo
        X_1[i] = mod1(X_0[i] + fluctuaciones[i], lado_caja)
    end
    return X_1 #X_0 + fluctuaciones
end
