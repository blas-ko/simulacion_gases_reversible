# Cajas y Vecinos

# Divide al espacio entero en la resolución dada, eg 2^60, y dice en qué caja está cada partícula.
function teselador_mat(coordenadas::Vector{Int64}, divisiones::Int64)  #De entrada en enteros.
      
    #rc_entero = Int64(ceil(res/divisiones)) #El radio crítico en unidades de res == cajitas (2^60 enteros) 
    rc_entero = cld(res, divisiones)
    rango = 1:divisiones
    zonas = [Int64[] for i = rango, j = rango, k = rango]
    
    largo = length(coordenadas)
    
    for i in 3:3:largo
        xn = Int64(ceil(coordenadas[i-2] / rc_entero))
        yn = Int64(ceil(coordenadas[i-1] / rc_entero))
        zn = Int64(ceil(coordenadas[i]   / rc_entero))
        push!(zonas[xn,yn,zn],i) #probelma de verlet_evolución
    end
    zonas
end

# Dado una caja, nos dice cuales son las cajas vecinas.
function vecinos{T<:Int64}(zonas::Array{Vector{T},3}, i::T, j::T, k::T)
    
    imax, jmax, kmax = size(zonas)
#   vecindad = zonas[i,j,k]  #Incluyendo la zona inicial.
    vecindad = Int64[]  #Incluyendo sólo a los vecinos de la zona inicial.
    
    if i == imax
        append!(vecindad, zonas[1,j,k])
        
        if j == jmax
            append!(vecindad, zonas[i,1,k])
            append!(vecindad, zonas[1,1,k])
            
            if k == kmax 
                append!(vecindad, zonas[i,j,1])
                append!(vecindad, zonas[i,1,1])
                append!(vecindad, zonas[1,j,1])
                append!(vecindad, zonas[1,1,1])
            else
                append!(vecindad, zonas[i,j,k+1])
                append!(vecindad, zonas[i,1,k+1])
                append!(vecindad, zonas[1,j,k+1])
                append!(vecindad, zonas[1,1,k+1])
            end
        else
            append!(vecindad, zonas[i,j+1,k])
            append!(vecindad, zonas[1,j+1,k])
            
            if k == kmax 
                append!(vecindad, zonas[i,j,1])
                append!(vecindad, zonas[i,j+1,1])
                append!(vecindad, zonas[1,j,1])
                append!(vecindad, zonas[1,j+1,1])
            else
                append!(vecindad, zonas[i,j,k+1])
                append!(vecindad, zonas[i,j+1,k+1])
                append!(vecindad, zonas[1,j,k+1])
                append!(vecindad, zonas[1,j+1,k+1])
            end
            
        end
    else
        append!(vecindad, zonas[i+1,j,k])
        
        if j == jmax
            append!(vecindad, zonas[i,1,k])
            append!(vecindad, zonas[i+1,1,k])
            
            if k == kmax 
                append!(vecindad, zonas[i,j,1])
                append!(vecindad, zonas[i,1,1])
                append!(vecindad, zonas[i+1,j,1])
                append!(vecindad, zonas[i+1,1,1])
            else
                append!(vecindad, zonas[i,j,k+1])
                append!(vecindad, zonas[i,1,k+1])
                append!(vecindad, zonas[i+1,j,k+1])
                append!(vecindad, zonas[i+1,1,k+1])
            end
        else
            append!(vecindad, zonas[i,j+1,k])
            append!(vecindad, zonas[i+1,j+1,k])
            
            if k == kmax
                append!(vecindad, zonas[i,j,1])
                append!(vecindad, zonas[i,j+1,1])
                append!(vecindad, zonas[i+1,j,1])
                append!(vecindad, zonas[i+1,j+1,1])
            else
                append!(vecindad, zonas[i,j,k+1])
                append!(vecindad, zonas[i,j+1,k+1])
                append!(vecindad, zonas[i+1,j,k+1])
                append!(vecindad, zonas[i+1,j+1,k+1])
            end
            
        end
    end
    vecindad
end