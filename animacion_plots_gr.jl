if length(ARGS) !== 2
  error("Necesito 2 argumentos: particulas_por_lado_cubico::Int64   pasos_temporales::Int64")
end

using Plots, Distributions
gr()

push!(LOAD_PATH, pwd())
using LennardGas

#Parámetros
@show r_c = 2.5
@show L   = r_c * 100
@show cajitas = 2^60
@show h = 0.005

function creador_gifs{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                pasos::T, lado_caja::Float64,
                                  cajitas::Int64, r_c::Float64, h::Float64)
    #scatter3d(organizador(X0)...)
    #scatter3d(organizador(X1)...)
    @gif for t in 2:pasos

        #=
        if t == 0
          x,y,z = organizador(X0)
          scatter3d(x,y,z, marker = (:circle, :white), background_color = RGB(0.2,0.2,0.2),
          xlims = (1,cajitas), ylims = (1,cajitas))
          continue

        elseif t == 1
          x,y,z = organizador(X0)
          scatter3d(x,y,z, marker = (:circle, :white), background_color = RGB(0.2,0.2,0.2),
          xlims = (1,cajitas), ylims = (1,cajitas))
          continue
        end
        =#

        X2 = paso_verlet(X0, X1, lado_caja, cajitas, r_c, h)
        x,y,z = organizador(X2)
        scatter3d(x,y,z, marker = (:circle, :white), background_color = RGB(0.2,0.2,0.2),
        xlims = (1,cajitas), ylims = (1,cajitas))
        #xlim(1,cajitas)
        #ylim(1,cajitas)
        #zlim(1,cajitas)
        (X0, X1, X2) = (X1, X2, X0)
    end
end

pasos = parse(Int64, ARGS[2])

# Incrementando las partículas se nota que los "arboles" sí funcionan.
raiz_cub_part = parse(Int64, ARGS[1])
@show particulas = raiz_cub_part^3

#Condicion inicial (en Float64)
inicial = cubito(raiz_cub_part, [L/2,L/2,L/2], L/6)
segundo = fluctuacion_gaussiana(inicial, 0.0, 1.0)

#Condición inicial (en Int64)
X0 = flotante_a_entero(inicial, L, cajitas)
X1 = flotante_a_entero(segundo, L, cajitas)

@time creador_gifs(X0, X1, pasos, L, cajitas, r_c, h)
