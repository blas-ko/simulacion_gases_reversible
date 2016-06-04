if length(ARGS) !== 2
  error("Necesito 2 argumentos: particulas_por_lado_cubico::Int64   pasos_temporales::Int64")
end

push!(LOAD_PATH, pwd()*"/src")
using LennardGas

function velocimetro(raiz_cub_part::Int64, pasos::Int64)
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
  segundo = fluctuacion_gaussiana(inicial, L, 0.0, 1.0)

  #Condición inicial (en Int64)
  X0 = flotante_a_entero(inicial, L, cajitas)
  X1 = flotante_a_entero(segundo, L, cajitas)

  @time prueba_reversible(X0, X1, pasos, L, cajitas, r_c, h)
end

velocimetro(parse(Int64, ARGS[1]), parse(Int64, ARGS[2]))
