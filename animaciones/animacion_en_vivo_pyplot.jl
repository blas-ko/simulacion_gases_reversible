length(ARGS) == 2 || error("Necesito 2 argumentos: particulas_por_lado_cubico::Int64   pasos_temporales::Int64")

#ENV["MPLBACKEND"] = "module://gr.matplotlib.backend_gr"

using PyPlot , Distributions
push!(LOAD_PATH, dirname(pwd())*"/src")
using LennardGas

function rollo_fotos{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                pasos::T, lado_caja::Float64,
                                  cajitas::Int64, r_c::Float64, h::Float64)
    for t in 1:pasos
        cla()
        X2 = paso_verlet(X0,X1, lado_caja, cajitas, r_c, h)
        x,y,z = organizador(X2)
        lin, = plot3D(x, y, z, "bo", markersize = 4.0)
        xlim(1,cajitas)
        ylim(1,cajitas)
        zlim(1,cajitas)
        #display(gcf())
        draw()
        pause(0.001)
        (X0, X1, X2) = (X1, X2, X0)
    end
end

function foto{T<:Int64}(X::Vector{T}, cajitas::T, tiempo::T,
                        estilo:: ASCIIString, pausa::Float64)
  x,y,z = organizador(X)
  plot3D(x, y, z, estilo, markersize = 4.0)
  title("Tiempo = $tiempo\h")
  xlim(1,cajitas)
  ylim(1,cajitas)
  zlim(1,cajitas)
  draw()
  pause(pausa)
  cla()
end


function rollo_fotos_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
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

    estilo = "go"
    PyPlot.ion() #Modo interactivo

    foto(X0, cajitas, 0, estilo, 1.0)

    for t in 1:4pasos
        #@time X2 = paso_verlet(X0, X1, lado_caja, cajitas, r_c, h)
        @time paso_verlet!(X2, X1, X0, zonas, vecindario, fuerzas,
                      largo_coord, lado_caja, cajitas, r_c, rc_entero, divisiones, h)
        if t<pasos
          foto(X1, cajitas, t, estilo, 0.01)
        elseif t<2pasos-2
          estilo = "mo"
          foto(X2, cajitas, t, estilo, 0.01)
        else
          estilo = "bo"
          foto(X2, cajitas, t, estilo, 0.01)
        end

        if t == pasos-1
          (X0, X1, X2) = (X2, X1, X0)
        else
          (X0, X1, X2) = (X1, X2, X0)
        end
    end

end

function proyector(raiz_cub_part::Int64, pasos::Int64)
  #Parámetros
  @show r_c = 2.5
  @show L   = r_c * 100
  @show cajitas = 2^60
  @show h = 0.005

  #pasos = parse(Int64, ARGS[2])

  # Incrementando las partículas se nota que los "arboles" sí funcionan.
  #raiz_cub_part = parse(Int64, ARGS[1])
  @show particulas = raiz_cub_part^3

  #Condicion inicial (en Float64)
  inicial = cubito(raiz_cub_part, [L/2,L/2,L/2], L/6)
  segundo = fluctuacion_gaussiana(inicial, 0.0, 1.0)

  #Condición inicial (en Int64)
  X0 = flotante_a_entero(inicial, L, cajitas)
  X1 = flotante_a_entero(segundo, L, cajitas)

  #@time pelicula = rollo_fotos(X0, X1, pasos, L, cajitas, r_c, h)
  @time pelicula = rollo_fotos_reversible(X0, X1, pasos, L, cajitas, r_c, h)
end

proyector(parse(Int64, ARGS[1]), parse(Int64, ARGS[2]))
