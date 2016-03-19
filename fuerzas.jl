 #Fuerza para un gas de Lennard
function fuerza(r::Float64,  r_c::Float64 = 2.5 )
    if r < 0.35 
    #Hay que tomar en cuenta que diverge para distancias suficientemente pequeñas
    #Esto tiene la justificación física de que las partículas tienen dimensión y no pueden superponerse.    
        return 48(0.37^(-13)-0.37^(-7) - ((r_c)^(-13) - r_c^(-7))/2)/r_c
    else  
        return 48(r^(-13)-r^(-7) - ((r_c)^(-13) - r_c^(-7))/2)/r_c
    end
end

#Calcula la fuerza vectorial entre la partícula "i" y la "j"
function fuerzas!{T<:Int64}(fuerzas::Vector{T}, coord_enteras::Vector{T}, i::T, j::T , lado_caja::Float64, radio_critico::Float64, h::Float64)
    #Primero operamos con enteros
    x_i = coord_enteras[i-2]
    y_i = coord_enteras[i-1]
    z_i = coord_enteras[i]

    x_j = coord_enteras[j-2]
    y_j = coord_enteras[j-1]
    z_j = coord_enteras[j]

    #Pasamos a flotantes para el cálculo de la distancia y la fuerza
    x_ij = entero_a_flotante(x_j - x_i, lado_caja, res)
    y_ij = entero_a_flotante(y_j - y_i, lado_caja, res)
    z_ij = entero_a_flotante(z_j - z_i, lado_caja, res)

    #Hay que considerar que la distancia se ve afectada por las fronteras periódicas.
    #Esta solución sólo funciona si hay más que tres divisiones por lado.
    
    #El factor de 2 está bien porque estamos considerando cada coordenada por separado.
    rad_max = 2radio_critico  
    
    #Si la distancia es negativa la periodicidad la vuelve positiva, y viceversa.
    if x_ij > rad_max 
        x_ij -= lado_caja
    elseif x_ij < -rad_max
        x_ij += lado_caja
    end
    if y_ij > rad_max 
        y_ij -= lado_caja
    elseif y_ij < -rad_max
        y_ij += lado_caja
    end
    if z_ij > rad_max 
        z_ij -= lado_caja
    elseif z_ij < -rad_max
        z_ij += lado_caja
    end
    
    r_ij = sqrt(x_ij^2 + y_ij^2 + z_ij^2)

    f_ij = fuerza(r_ij, radio_critico)

    fx = f_ij * x_ij
    fy = f_ij * y_ij
    fz = f_ij * z_ij
    
    h2 = h^2
    
    #println("el valor de r_ij es: ", r_ij)
    #println("el valor de fx*h2 es: ", fx * h2)
    
    #Volvemos a enteros
    fxh = flotante_a_entero(fx * h2, lado_caja, res)
    fyh = flotante_a_entero(fy * h2, lado_caja, res)
    fzh = flotante_a_entero(fz * h2, lado_caja, res)

    fuerzas[i-2] += fxh
    fuerzas[i-1] += fyh
    fuerzas[i] += fzh

    fuerzas[j-2] -= fxh
    fuerzas[j-1] -= fyh
    fuerzas[j] -= fzh
end

# El algoritmo de Verlet no ocupa las velocidades de las partículas.
# Suponemos que todas las masas son iguales
function vector_fuerzas{T<:Float64}(coord_enteras::Vector{Int64}, lado_caja::T, radio_critico::T = 2.5, h::T = 0.005) 
    
    # coordenadas es el arreglo con las posiciones X = (x1,y1,z1, x2,y2,z2, ...)
    largo = length(coord_enteras)
    suma_fuerzas = zeros(Int64, largo)
    
    ##### Creo que aquí está el error #####
    divisiones_flotante = lado_caja/radio_critico #De preferencia que lado_caja sea múltiplo de radio_crítico
    divisiones = Int64(ceil(divisiones_flotante))
    zonas = teselador_mat(coord_enteras, divisiones)
    
    for m = 1:divisiones, n = 1:divisiones, l = 1:divisiones
        zona = zonas[m,n,l]
        vecindario = vecinos(zonas,m,n,l)
        
        #Aquí aseguramos que las fuerzas dentro de zona sólo se calculen una ocasión.
        #Si ambas partículas están dentro de zona hay que imponer i<j para lo anterior.
    
        for i in zona, j in zona
            if i<j  #Para no calcular dos veces la misma fuerza.
                fuerzas!(suma_fuerzas, coord_enteras, i, j, lado_caja, radio_critico, h) 
            end
        end
        #Si en cambio una está en zona y la otra en vecinos i<j no es necesario.
        for i in zona, j in vecindario
            fuerzas!(suma_fuerzas, coord_enteras, i, j, lado_caja, radio_critico, h) 
        end
    end
    suma_fuerzas
end

