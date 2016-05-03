using PyPlot , Distributions

#ENV["MPLBACKEND"] = "module://gr.matplotlib.backend_gr"

push!(LOAD_PATH, pwd())
using LennardGas

#Parámetros
r_c = 2.5
L   = r_c * 100
cajitas = 2^60
h = 0.005

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
    estilo = "go"
    PyPlot.ion() #Modo interactivo

    foto(X0, cajitas, 0, estilo, 1.0)

    for t in 1:4pasos
        X2 = paso_verlet(X0, X1, lado_caja, cajitas, r_c, h)
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

pasos = 50
# Incrementando las partículas se nota que los "arboles" sí funcionan.
raiz_cub_part = 10
@show particulas = raiz_cub_part^3

#Condicion inicial (en Float64)
inicial = cubito(raiz_cub_part, [L/2,L/2,L/2], L/6)
segundo = fluctuacion_gaussiana(inicial, 0.0, 1.0)

#Condición inicial (en Int64)
X0 = flotante_a_entero(inicial, L, cajitas)
X1 = flotante_a_entero(segundo, L, cajitas)
#@time pelicula = rollo_fotos(X0, X1, pasos, L, cajitas, r_c, h)
@time pelicula = rollo_fotos_reversible(X0, X1, pasos, L, cajitas, r_c, h)