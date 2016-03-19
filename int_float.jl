# De Float64 a Int64.
# Obs: Hay que tener cuidado que la conversión no sea mayor a 2^63, ya que tiene problemas al convertir.
function flotante_a_entero(flotante:: Float64, lado_caja::Float64, cajitas::Int64 = res)
    Int64(ceil(cajitas*flotante/lado_caja))
end

# De Array{Float64,1} a Array{Int64,1}
function flotante_a_entero(vector_flotante::Vector{Float64}, lado_caja::Float64, cajitas::Int64 = res)
    
    largo = length(vector_flotante)
    vector_entero = Vector{Int64}(largo)
    
    for (i,flotante) in enumerate(vector_flotante)
        vector_entero[i] = flotante_a_entero(flotante,lado_caja,cajitas)
    end
    vector_entero
end

# De Int64 a Float64
function entero_a_flotante(entero:: Int64,lado_caja::Float64, cajitas::Int64 = res)
    Float64(entero*lado_caja/cajitas) #Por alguna razón el poner Float64() cambia los resultados...
end

# De Array{Int64,1} a Array{Float64,1}
function entero_a_flotante(vector_entero:: Vector{Int64},lado_caja::Float64, cajitas::Int64 = res)
    largo = length(vector_entero)
    vector_flotante = Vector{Float64}(largo)
    
    for (i,entero) in enumerate(vector_entero)
        #         vector_flotante[i] = Float64(entero*lado_caja/cajitas)  #Esto resulta en algo inesperado... :(
        vector_flotante[i] = entero_a_flotante(entero,lado_caja,cajitas)
    end
    vector_flotante
end