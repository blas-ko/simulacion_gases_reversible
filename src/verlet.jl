function paso_verlet{T<:Int64}(coord_previas::Vector{T}, coord_actuales::Vector{T},
                              lado_caja::Float64, cajitas::T, r_c::Float64, h::Float64)
    largo = length(coord_previas)
    coord_futuras = zeros(Int64, largo)
    fuerzas = vector_fuerzas(coord_actuales, lado_caja, cajitas ,r_c, h)
    for i in 1:largo
        coord_futuras[i] = -coord_previas[i] + 2*coord_actuales[i] + fuerzas[i]
        #Hay que revisar que no se salgan de la cajita, el rollo es periodico.
        if (coord_futuras[i] > cajitas) | (coord_futuras[i] < 1)
            coord_futuras[i] = mod1(coord_futuras[i],cajitas)
        end
    end
    coord_futuras
end

function evolucion{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                            pasos::T, lado_caja::Float64,
                            cajitas::Int64, r_c::Float64, h::Float64)
    largo = length(X0)
    registro = Matrix{Int64}(pasos+2,largo)
    registro[1,:] = X0
    registro[2,:] = X1

    for t in 3:pasos+2
        registro[t,:] = paso_verlet(collect(registro[t-2,:]),collect(registro[t-1,:]), lado_caja, cajitas, r_c, h)
    end
    registro
end

function prueba_reversible{T<:Int64}(X0::Vector{T}, X1::Vector{T},
                                    pasos::T, L::Float64, cajitas::T,
                                    r_c::Float64, h::Float64)

    registro_ida = evolucion(X0, X1, pasos, L, cajitas, r_c, h)
    X_ultima = collect(registro_ida[end,:])
    X_penultima = collect(registro_ida[end-1,:])

    registro_vuelta = evolucion(X_ultima, X_penultima, pasos, L, cajitas, r_c, h)
    X_original = collect(registro_vuelta[end,:])

    if X0 == X_original
        println("El proceso fue reversible.")
    else
        println("El proceso no fue reversible.")
    end
    registro_ida, registro_vuelta
end
