function paso_verlet!{T<:Int64}(coord_futuras::Vector{T}, coord_actuales::Vector{T}, coord_previas::Vector{T},
                                  zonas::Array{Vector{T},3}, fuerzas::Vector{T}, largo_coord::T,
                                    lado_caja::Float64, cajitas::T, radio_critico::Float64,
                                      rc_entero::T, divisiones::T, paso_temporal::Float64)

    vector_fuerzas!(zonas, fuerzas, coord_actuales, largo_coord, lado_caja, cajitas,
                      radio_critico, rc_entero, divisiones, paso_temporal)
    for i in 1:largo_coord
        coord_futuras[i] = -coord_previas[i] + 2*coord_actuales[i] + fuerzas[i]
        #hay que revisar que no se salgan de la cajita, el rollo es periodico.
        if (coord_futuras[i] > cajitas) || (coord_futuras[i] < 1)
            coord_futuras[i] = mod1(coord_futuras[i], cajitas)
        end
    end
    coord_futuras
end

function evolucion{T<:Int64}(X0::Vector{T}, X1::Vector{T}, pasos::T, lado_caja::Float64,
                                cajitas::T, radio_critico::Float64, paso_temporal::Float64)
    largo_coord = length(X0)
    divisiones = Int64(cld(lado_caja, radio_critico))
    rc_entero = cld(cajitas, divisiones)

    registro = Matrix{Int64}(pasos+2, largo_coord)
    registro[1,:] = X0
    registro[2,:] = X1

    X2 = zeros(Int64, largo_coord)
    fuerzas = zeros(Int64, largo_coord)

    rango = 1:divisiones
    zonas = Vector{Int64}[[] for i = rango, j = rango, k = rango]

    for t in 3:pasos+2
        paso_verlet!(X2, collect(registro[t-1,:]), collect(registro[t-2,:]), zonas, fuerzas,
                      largo_coord, lado_caja, cajitas, radio_critico, rc_entero, divisiones, paso_temporal)
        registro[t,:] = X2
    end
    registro
end

function prueba_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
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
