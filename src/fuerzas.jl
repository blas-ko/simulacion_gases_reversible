#Fuerza de Lennard-Jones
function fuerza(r::Float64,  r_c::Float64)
    if r < 0.4 #Este número se encontró empíricamente
        return 48(0.4^(-13)-0.4^(-7) - ((r_c)^(-13) - r_c^(-7)/2))/0.4
    elseif r < r_c
        return 48(r^(-13)-r^(-7) - ((r_c)^(-13) - r_c^(-7)/2))/r
    else
        return 0
    end
end

function fuerzas!{T<:Int64}(fuerzas::Vector{T}, coord_enteras::Vector{T}, i::T, j::T, cajitas::T,
                            lado_caja::Float64, radio_critico::Float64, h::Float64)
    #Primero operamos con enteros
    x_i = coord_enteras[i-2]
    y_i = coord_enteras[i-1]
    z_i = coord_enteras[i]

    x_j = coord_enteras[j-2]
    y_j = coord_enteras[j-1]
    z_j = coord_enteras[j]

    x_ij = x_j - x_i
    y_ij = y_j - y_i
    z_ij = z_j - z_i

    #Hay que considerar que la distancia se ve afectada por las fronteras periódicas.
    #Esta solución sólo funciona si hay más que tres divisiones por lado.

    #El factor de 2 está bien porque estamos considerando cada coordenada por separado.
    #rad_max = flotante_a_entero(2 * radio_critico, lado_caja, cajitas)
    rad_max = cajitas÷2

    #Si la distancia es negativa la periodicidad la vuelve positiva, y viceversa.
    if x_ij > rad_max
        x_ij -= cajitas
    elseif x_ij < -rad_max
        x_ij += cajitas
    end
    if y_ij > rad_max
        y_ij -= cajitas
    elseif y_ij < -rad_max
        y_ij += cajitas
    end
    if z_ij > rad_max
        z_ij -= cajitas
    elseif z_ij < -rad_max
        z_ij += cajitas
    end

    #Pasamos a flotantes para el cálculo de la distancia y la fuerza
    x_ij_float = entero_a_flotante(x_ij, lado_caja, cajitas)
    y_ij_float = entero_a_flotante(y_ij, lado_caja, cajitas)
    z_ij_float = entero_a_flotante(z_ij, lado_caja, cajitas)

    r_ij = sqrt(x_ij_float^2 + y_ij_float^2 + z_ij_float^2)

    f_ij = fuerza(r_ij, radio_critico)

    fx = f_ij * x_ij_float
    fy = f_ij * y_ij_float
    fz = f_ij * z_ij_float

    h2 = h^2

    #Volvemos a enteros
    fxh = flotante_a_entero(fx * h2, lado_caja, cajitas)
    fyh = flotante_a_entero(fy * h2, lado_caja, cajitas)
    fzh = flotante_a_entero(fz * h2, lado_caja, cajitas)

    fuerzas[i-2] += fxh
    fuerzas[i-1] += fyh
    fuerzas[i] += fzh

    fuerzas[j-2] -= fxh
    fuerzas[j-1] -= fyh
    fuerzas[j] -= fzh
end

# Suponemos que todas las masas son iguales
function vector_fuerzas!{T<:Int64}(zonas::Array{Vector{T},3}, fuerzas::Vector{T}, coord_enteras::Vector{T},
                                      vecindario::Vector{T}, largo_coord::T, lado_caja::Float64, cajitas::T,
                                          radio_critico::Float64, rc_entero::T, divisiones::T, h::Float64)
    #Coordenadas (coord_enteras) es el arreglo con las posiciones X = (x1,y1,z1, x2,y2,z2, ...)

    for i in eachindex(fuerzas); fuerzas[i] = 0; end #Un nuevo vector de fuerzas en cada paso temporal.

    teselador_mat!(zonas, coord_enteras, largo_coord, rc_entero) #Actualiza la matriz de zonas.

    for m = 1:divisiones, n = 1:divisiones, l = 1:divisiones
        zona = zonas[m,n,l]
        vecinos!(vecindario, zonas, m, n, l) # Actualiza el arreglo que contiene los vecinos.

        #Aquí aseguramos que las fuerzas dentro de zona sólo se calculen una ocasión.
        #Si ambas partículas están dentro de zona hay que imponer i<j para lo anterior.
        for i in zona

            for j in zona
                if i<j  #Para no calcular dos veces la misma fuerza.
                    fuerzas!(fuerzas, coord_enteras, i, j, cajitas, lado_caja, radio_critico, h)
                end
            end

            #Si en cambio una partícula está en zona y la otra en vecinos, i<j no es necesario.
            for j in vecindario
                fuerzas!(fuerzas, coord_enteras, i, j, cajitas, lado_caja, radio_critico, h)
            end
        end
    end
end
