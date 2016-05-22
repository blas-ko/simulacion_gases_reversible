function flotante_a_entero(flotante:: Float64, lado_caja::Float64, cajitas::Int64)
    Int64(ceil(cajitas*flotante/lado_caja))
end


function flotante_a_entero(vector_flotante::Vector{Float64}, lado_caja::Float64, cajitas::Int64)
    largo = length(vector_flotante)
    vector_entero = Vector{Int64}(largo)

    for (i,flotante) in enumerate(vector_flotante)
        vector_entero[i] = flotante_a_entero(flotante,lado_caja,cajitas)
    end
    vector_entero
end


function entero_a_flotante(entero:: Int64,lado_caja::Float64, cajitas::Int64)
    Float64(entero*lado_caja/cajitas)
end


function entero_a_flotante(vector_entero:: Vector{Int64},lado_caja::Float64, cajitas::Int64)
    largo = length(vector_entero)
    vector_flotante = Vector{Float64}(largo)

    for (i,entero) in enumerate(vector_entero)
        vector_flotante[i] = entero_a_flotante(entero,lado_caja,cajitas)
    end
    vector_flotante
end
