function paso_verlet{T<:Int64}(coord_previas::Vector{T}, coord_actuales::Vector{T}, lado_caja::Float64, r_c::Float64 = 2.5, h::Float64 = 0.005)
#     coord_futuras = coord_previas + 2coord_actuales - vector_fuerzas(coord_actuales, r_c, h)
    
    largo = length(coord_previas)
    coord_futuras = zeros(Int64, largo)
    for i in 1:largo
        coord_futuras[i] = coord_previas[i] + 2*coord_actuales[i] - vector_fuerzas(coord_actuales, lado_caja, r_c, h)[i]
        #Hay que revisar que no se salgan de la cajita == res, el rollo es periodico.
        if coord_futuras[i] > res
            coord_futuras[i] -= res
        elseif coord_futuras[i] < 1
            coord_futuras[i] += res
        end
    end
    coord_futuras
end

function evolucion_verlet{T<:Int64}(X0::Vector{T}, X1::Vector{T}, pasos::T, lado_caja::Float64, r_c::Float64 = 2.5, h::Float64 = 0.005)

#     registro = Vector{Int64}[X_0, X_1]
#     sizehint!(registro, pasos+2)
#     println(typeof(registro))

    largo = length(X0)
    registro = Matrix{Int64}(largo,pasos+2)
    registro[:,1] = X0
    registro[:,2] = X1
    

    for t in 3:pasos+2
        registro[:,t] = paso_verlet(collect(registro[:,t-2]),collect(registro[:,t-1]), lado_caja , r_c, h)
 #         push!(registro, X2)
#         X0, X1, X2 = X1, X2, X0
    end
    registro
end