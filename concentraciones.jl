if length(ARGS) !== 5
  error("Necesito 5 argumentos: particulas_por_lado_cubico::Int64   pasos_temporales::Int64  exponente_error_inicial::Int64  saltos_exponente::Int64  exponente_error_final::Int64")
end

using PyPlot
push!(LOAD_PATH, pwd()*"/src")
using LennardGas

function sondeo!{T<:Int64}(reg_primeros::Matrix{Float64}, reg_ultimos::Matrix{Float64},
                              estado::Vector{T}, largo_coords::T, cajitas::T, t::T, i::T = 1)
        izq_prim = 0.0
        der_prim = 0.0
        izq_ult = 0.0
        der_ult = 0.0

        for x in sub(estado, i:3:largo_coords÷2) ### i = 1 --> x
           (x > cajitas÷2) ? der_prim += 1.0 : izq_prim += 1.0
        end
        for x in sub(estado, (largo_coords÷2 +i):3:largo_coords) ### i = 1 --> x
           (x > cajitas÷2) ? der_ult += 1.0 : izq_ult += 1.0
        end
        tot_prim = izq_prim + der_prim
        reg_primeros[t,1] = izq_prim/tot_prim
        reg_primeros[t,2] = der_prim/tot_prim

        tot_ult = izq_ult + der_ult
        reg_ultimos[t,1] = izq_ult/tot_ult
        reg_ultimos[t,2] = der_ult/tot_ult
end

function casi_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                      pasos::T, lado_caja::Float64, cajitas::Int64,
                                        r_c::Float64, h::Float64, exp_error::T; eje::ASCIIString = "x")

    X_inicial = copy(X0) #prueba_rev
    largo_coord = length(X0)
    divisiones = Int64(cld(lado_caja, r_c)) #Cajas de ancho ~ radio_critico que habrá por lado.
    rc_entero = cld(cajitas, divisiones) #El radio crítico en unidades de cajitas (2^60 enteros).

    X2 = zeros(Int64, largo_coord)
    fuerzas = zeros(Int64, largo_coord)

    rango = 1:divisiones
    zonas = Vector{Int64}[[] for i = rango, j = rango, k = rango] # Predefine la matriz "directorio".
    vecindario = Int64[] # Predefine el arreglo con vecinos.

    reg_primeros = zeros(Float64, 3pasos+1, 2)
    reg_ultimos  = zeros(Float64, 3pasos+1, 2)

    if eje == "x" ; i = 1
    elseif eje == "y" ; i = 2
    elseif eje == "z" ; i = 3
    else error("Los valores posibles de eje son: \"x\", \"y\" y \"z\"")
    end

    sondeo!(reg_primeros, reg_ultimos, X0, largo_coord, cajitas, 1, i)
    #sondeo!(reg_primeros, reg_ultimos, X1, largo_coord, cajitas, 2, i)

    for t in 1:3pasos
        paso_verlet!(X2, X1, X0, zonas, vecindario, fuerzas,
                            largo_coord, lado_caja, cajitas, r_c, rc_entero, divisiones, h)
        if t < pasos
            sondeo!(reg_primeros, reg_ultimos, X1, largo_coord, cajitas, t+1, i)
            (X0, X1, X2) = (X1, X2, X0)

        elseif t == pasos
            sondeo!(reg_primeros, reg_ultimos, X1, largo_coord, cajitas, t+1, i)
            (X0, X1, X2) = (X2, X1, X0)
            if exp_error != -1
                X0[1] = mod(X0[1] + 10^exp_error, cajitas)
                X0[2] = mod(X0[2] + 10^exp_error, cajitas)
                X0[3] = mod(X0[3] + 10^exp_error, cajitas)
            end
        else
            if t == 2pasos
                if X2 == X_inicial
                    println("El proceso fue reversible.")
                else
                    println("El proceso no fue reversible.")
                end
            end
            sondeo!(reg_primeros, reg_ultimos, X2, largo_coord, cajitas, t+1, i)
            (X0, X1, X2) = (X1, X2, X0)
        end
    end
    tiempo = 1:3pasos+1
    exp_error == -1 ? etiqueta = "Nulo" : etiqueta = "10^$exp_error"

    axarr[1][:plot](tiempo, reg_primeros[:,1], label = etiqueta)
    axarr[1][:plot](tiempo, reg_ultimos[:,1])

    axarr[2][:plot](tiempo, reg_primeros[:,2], label = etiqueta)
    axarr[2][:plot](tiempo, reg_ultimos[:,2])
end


  raiz_cub_part = parse(Int64, ARGS[1])
  pasos = parse(Int64, ARGS[2])
  rango_exp_errores = parse(Int64, ARGS[3]):parse(Int64, ARGS[4]):parse(Int64, ARGS[5])

  if raiz_cub_part % 2 != 0
      error("La implementación actual requiere un número de partículas par.")
  end

  #Parámetros
  @show r_c = 2.5
  @show L   = r_c * 100
  @show cajitas = 2^60
  @show h = 0.005

  # Incrementando las partículas se nota que los "arboles" sí funcionan.
  @show particulas = raiz_cub_part^3

  #Condicion inicial (en Float64)
  inicial = bifase(raiz_cub_part, L) # Probar con otros ejes.
  segundo = fluctuacion_gaussiana(inicial, L, 0.0, 1.0)

  f , axarr = subplots(2, sharex = true)

  for exp in rango_exp_errores
      #Condición inicial (en Int64)
      X0 = flotante_a_entero(inicial, L, cajitas)
      X1 = flotante_a_entero(segundo, L, cajitas)
      casi_reversible(X0, X1, pasos, L, cajitas, r_c, h, exp)
  end

  axarr[1][:axvline](pasos+1, linestyle = "dashdot", color = "black")
  axarr[2][:axvline](pasos+1, linestyle = "dashdot", color = "black")

  axarr[1][:axvline](2pasos+1, linestyle = "dotted", color = "black")
  axarr[2][:axvline](2pasos+1, linestyle = "dotted", color = "black")

  axarr[1][:legend](loc = "center left", bbox_to_anchor=(1, 0.5), title = "Errores", fontsize = 9)
  axarr[2][:legend](loc = "center left", bbox_to_anchor=(1, 0.5), title = "Errores", fontsize = 9)

  axarr[1][:set_title]("Concentración lado izquierdo")
  axarr[2][:set_title]("Concentración lado derecho")

  part = raiz_cub_part^3
  savefig("concen_p_$part\_t_$pasos.pdf",  bbox_inches = "tight")
  show()
