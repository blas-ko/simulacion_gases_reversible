function teselador_mat{T<:Int64}(coordenadas::Vector{T}, divisiones::T, cajitas::T)
    #rc_entero = Int64(ceil(cajitas/divisiones))
    rc_entero = cld(cajitas, divisiones)  #El radio crítico en unidades de cajitas (2^60 enteros)
    rango = 1:divisiones
    zonas = [Int64[] for i = rango, j = rango, k = rango]

    largo = length(coordenadas)

    for i in 3:3:largo
        xn = Int64(ceil(coordenadas[i-2]/rc_entero))
        yn = Int64(ceil(coordenadas[i-1]/rc_entero))
        zn = Int64(ceil(coordenadas[i]/rc_entero))
        push!(zonas[xn,yn,zn], i)
    end
    zonas
end


function vecinos{T<:Int64}(zonas::Array{Vector{T},3}, i::T, j::T, k::T)
    imax, jmax, kmax = size(zonas)
    i_plus = mod1(i+1, imax)
    j_plus = mod1(j+1, jmax)
    k_plus = mod1(k+1, kmax)

    #vecindad = zonas[i,j,k]  #Incluyendo la zona inicial.
    vecindad = Int64[]  #Incluyendo sólo a los vecinos de la zona inicial.

    append!(vecindad, zonas[i_plus, j, k])
    append!(vecindad, zonas[i, j_plus, k])
    append!(vecindad, zonas[i_plus, j_plus, k])
    append!(vecindad, zonas[i, j, k_plus])
    append!(vecindad, zonas[i, j_plus, k_plus])
    append!(vecindad, zonas[i_plus, j, k_plus])
    append!(vecindad, zonas[i_plus, j_plus, k_plus])
    vecindad
end
