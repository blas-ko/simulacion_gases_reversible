if length(ARGS) !== 2
  error("Necesito 2 argumentos: particulas_por_lado_cubico::Int64   pasos_temporales::Int64")
end

using Plots, Distributions

pyplot(reuse = true)

push!(LOAD_PATH, "../src")
using LennardGas

#Parámetros
@show r_c = 2.5
@show L   = r_c * 25
@show cajitas = 2^60
@show h = 0.005

function creador_gif_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                pasos::T, lado_caja::Float64,
                                  cajitas::Int64, r_c::Float64, h::Float64)
    largo_coord = length(X0)
    divisiones = Int64(cld(lado_caja, r_c)) #Cajas de ancho ~ radio_critico que habrá por lado.
    rc_entero = cld(cajitas, divisiones) #El radio crítico en unidades de cajitas (2^60 enteros).

    X2 = zeros(Int64, largo_coord)
    fuerzas = zeros(Int64, largo_coord)

    rango = 1:divisiones
    zonas = Vector{Int64}[[] for i = rango, j = rango, k = rango] # Predefine la matriz "directorio".
    vecindario = Int64[] # Predefine el arreglo con vecinos.

    @gif for t in 0:3pasos

      if t <= 2
        x,y,z = organizador(X0)
        scatter3d(x,y,z, marker = (:circle, :red), markersize = 4.0, background_color = RGB(0.2,0.2,0.2),
                  xlims = (1,cajitas), ylims = (1,cajitas), zlims = (1,cajitas) )
      else
        paso_verlet!(X2, X1, X0, zonas, vecindario, fuerzas,
                      largo_coord, lado_caja, cajitas, r_c, rc_entero, divisiones, h)

        if t<pasos
          x,y,z = organizador(X1)
          scatter3d(x,y,z, marker = (:circle, :red), markersize = 4.0, background_color = RGB(0.2,0.2,0.2),
                    xlims = (1,cajitas), ylims = (1,cajitas), zlims = (1,cajitas) )
        else
          x,y,z = organizador(X2)
          scatter3d(x,y,z, marker = (:circle, :orange), markersize = 4.0, background_color = RGB(0.2,0.2,0.2),
                    xlims = (1,cajitas), ylims = (1,cajitas), zlims = (1,cajitas) )
        end

        if t == pasos-1
          (X0, X1, X2) = (X2, X1, X0)
        else
          (X0, X1, X2) = (X1, X2, X0)
        end
      end
    end
end


pasos = parse(Int64, ARGS[2])

# Incrementando las partículas se nota que los "arboles" sí funcionan.
raiz_cub_part = parse(Int64, ARGS[1])
@show particulas = raiz_cub_part^3

#Condicion inicial (en Float64)
inicial = cubito(raiz_cub_part, [L/2,L/2,L/2], L/6)
segundo = fluctuacion_gaussiana(inicial, L, 0.0, 1.0)

#Condición inicial (en Int64)
X0 = flotante_a_entero(inicial, L, cajitas)
X1 = flotante_a_entero(segundo, L, cajitas)

#@time creador_gif(X0, X1, pasos, L, cajitas, r_c, h)
@time creador_gif_reversible(X0, X1, pasos, L, cajitas, r_c, h)
