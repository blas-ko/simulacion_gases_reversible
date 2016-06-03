if length(ARGS) !== 5
  error("Necesito 5 argumentos: particulas_por_lado_cubico::Int64   pasos_temporales::Int64  exponente_error_inicial::Int64  saltos_exponente::Int64  exponente_error_final::Int64")
end

using PyPlot
push!(LOAD_PATH, pwd()*"/src")
using LennardGas

function registradora(raiz_cub_part::Int64, pasos::Int64, exp_error::Int64, eje::ASCIIString)
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
  inicial = bifase(raiz_cub_part, L, eje_division = eje)
  segundo = fluctuacion_gaussiana(inicial, 0.0, 1.0)

  #Condición inicial (en Int64)
  X0 = flotante_a_entero(inicial, L, cajitas)
  X1 = flotante_a_entero(segundo, L, cajitas)

  @time evolucion_casi_reversible(X0, X1, pasos, L, cajitas, r_c, h, exp_error)
end

function sondeo(evol::Matrix{Int64}, i::Int64 = 1)

    tiempo, coords = size(evol)
    reg_primeros = zeros(Float64, tiempo, 2)
    reg_ultimos = zeros(Float64, tiempo, 2)

    for t in 1:tiempo
        izq_prim = 0.0
        der_prim = 0.0
        izq_ult = 0.0
        der_ult = 0.0

        for x in sub(evol, t, i:3:coords÷2) ### i = 1 --> x
           (x > 2^59) ? der_prim += 1.0 : izq_prim += 1.0
        end
        for x in sub(evol,t, (coords÷2 +i):3:coords) ### i = 1 --> x
           (x > 2^59) ? der_ult += 1.0 : izq_ult += 1.0
        end
        tot_prim = izq_prim + der_prim
        reg_primeros[t,1] = izq_prim/tot_prim
        reg_primeros[t,2] = der_prim/tot_prim

        tot_ult = izq_ult + der_ult
        reg_ultimos[t,1] = izq_ult/tot_ult
        reg_ultimos[t,2] = der_ult/tot_ult
    end
    reg_primeros, reg_ultimos
end


function comparador(raiz_cub_part::Int64, pasos::Int64, exp_error::Int64; eje::ASCIIString = "x")

   ida, vuelta = registradora(raiz_cub_part, pasos, exp_error, eje)

   if eje == "x"
      i = 1
   elseif eje == "y"
      i = 2
   elseif eje == "z"
      i = 3
   else
      error("Los valores posibles de eje son: \"x\", \"y\" y \"z\"")
   end

   primeros_ida, ultimos_ida = sondeo(ida, i)
   primeros_vuelta, ultimos_vuelta = sondeo(vuelta, i)

   primeros = vcat(primeros_ida, primeros_vuelta)
   ultimos = vcat(ultimos_ida, ultimos_vuelta)

   tiempo = 1:size(primeros,1)

   # f , axarr = subplots(2, sharex=true)

   axarr[1][:plot](tiempo, primeros[:,1])
   axarr[1][:plot](tiempo, ultimos[:,1])
   axarr[1][:set_title]("Concentración lado izquierdo")

   axarr[2][:plot](tiempo, primeros[:,2])
   axarr[2][:plot](tiempo, ultimos[:,2])
   axarr[2][:set_title]("Concentración lado derecho")

   # show()
end

raiz_cub_part = parse(Int64, ARGS[1])
pasos = parse(Int64, ARGS[2])
rango = parse(Int64, ARGS[3]):parse(Int64, ARGS[4]):parse(Int64, ARGS[5])

f , axarr = subplots(2, sharex = true)
for exp in rango
    comparador(raiz_cub_part, pasos, exp)
end
show()

# julia concentraciones.jl 10 500 0 3 12
