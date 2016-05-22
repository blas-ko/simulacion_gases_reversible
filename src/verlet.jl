function paso_verlet!{T<:Int64}(coord_futuras::Vector{T}, coord_actuales::Vector{T}, coord_previas::Vector{T},
                                  zonas::Array{Vector{T},3}, vecindario::Vector{T}, fuerzas::Vector{T}, largo_coord::T,
                                    lado_caja::Float64, cajitas::T, radio_critico::Float64,
                                      rc_entero::T, divisiones::T, paso_temporal::Float64)

    #Modifica: zonas, fuerzas y vecindario.
    vector_fuerzas!(zonas, fuerzas, coord_actuales, vecindario, largo_coord, lado_caja, cajitas,
                      radio_critico, rc_entero, divisiones, paso_temporal)
    for i in 1:largo_coord
        coord_futuras[i] = -coord_previas[i] + 2*coord_actuales[i] + fuerzas[i]
        #Imponer periodicidad si algo salió de la caja mayor.
        if (coord_futuras[i] > cajitas) || (coord_futuras[i] < 1)
            coord_futuras[i] = mod1(coord_futuras[i], cajitas)
        end
    end
    coord_futuras
end

function evolucion{T<:Int64}(X0::Vector{T}, X1::Vector{T}, pasos::T, lado_caja::Float64,
                                cajitas::T, radio_critico::Float64, paso_temporal::Float64)
    largo_coord = length(X0)
    divisiones = Int64(cld(lado_caja, radio_critico)) #Cajas de ancho ~ radio_critico que habrá por lado.
    rc_entero = cld(cajitas, divisiones) #El radio crítico en unidades de cajitas (2^60 enteros).

    registro = Matrix{Int64}(pasos+2, largo_coord)
    registro[1,:] = X0
    registro[2,:] = X1

    coord_futuras = zeros(Int64, largo_coord)
    fuerzas = zeros(Int64, largo_coord)

    rango = 1:divisiones
    zonas = Vector{Int64}[[] for i = rango, j = rango, k = rango] # Predefine la matriz "directorio".
    vecindario = Int64[] # Predefine el arreglo con vecinos.

    for t in 3:pasos+2
        # Modifica: el arreglo de coord_futuras, zonas, vecindario y fuerzas.
        paso_verlet!(coord_futuras, collect(registro[t-1,:]), collect(registro[t-2,:]), zonas, vecindario, fuerzas,
                      largo_coord, lado_caja, cajitas, radio_critico, rc_entero, divisiones, paso_temporal)
        registro[t,:] = coord_futuras
    end
    registro
end

function evolucion_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                          pasos::T, lado_caja::Float64, cajitas::T,
                                            radio_critico::Float64, paso_temporal::Float64)

    registro_ida = evolucion(X0, X1, pasos, lado_caja, cajitas, radio_critico, paso_temporal)
    X_ultima = collect(registro_ida[end,:])
    X_penultima = collect(registro_ida[end-1,:])

    registro_vuelta = evolucion(X_ultima, X_penultima, pasos, lado_caja, cajitas, radio_critico, paso_temporal)
    X_original = collect(registro_vuelta[end,:])

    if X0 == X_original
        println("El proceso fue reversible.")
    else
        println("El proceso no fue reversible.")
    end
    registro_ida, registro_vuelta
end

function prueba_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                          pasos::T, lado_caja::Float64,
                                              cajitas::Int64, r_c::Float64, h::Float64)

    X_inicial = copy(X0)
    largo_coord = length(X0)
    divisiones = Int64(cld(lado_caja, r_c)) #Cajas de ancho ~ radio_critico que habrá por lado.
    rc_entero = cld(cajitas, divisiones) #El radio crítico en unidades de cajitas (2^60 enteros).

    X2 = zeros(Int64, largo_coord)
    fuerzas = zeros(Int64, largo_coord)

    rango = 1:divisiones
    zonas = Vector{Int64}[[] for i = rango, j = rango, k = rango] # Predefine la matriz "directorio".
    vecindario = Int64[] # Predefine el arreglo con vecinos.

    for t in 1:2pasos
        @time paso_verlet!(X2, X1, X0, zonas, vecindario, fuerzas,
                            largo_coord, lado_caja, cajitas, r_c, rc_entero, divisiones, h)
        if t == pasos-1
            (X0, X1, X2) = (X2, X1, X0)
        else
            (X0, X1, X2) = (X1, X2, X0)
        end
    end
    if X2 == X_inicial
        println("El proceso fue reversible.")
    else
        println("El proceso no fue reversible.")
    end
end
