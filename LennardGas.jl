module LennardGas

#using PyPlot, Colors,
using  Distributions
export flotante_a_entero, entero_a_flotante, 
       fluctuacion_gaussiana, vector_fuerzas, 
       paso_verlet, evolucion

###----------------------------------- Dominio Int64<->Float64 ---------------------------------------------###

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

###----------------------------------- Cuadriculado y Periodicidad ---------------------------------------------###

function teselador_mat(coordenadas::Vector{Int64}, divisiones::Int64, cajitas::Int64)
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

#     vecindad = zonas[i,j,k]  #Incluyendo la zona inicial.
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

###----------------------------------- Fuerzas Lennard-Jones ---------------------------------------------###

#Fuerza de Lennard-Jones
function fuerza(r::Float64,  r_c::Float64)
    if r < 0.4 #Este número se encontró empíricamente
        return 48(0.4^(-13)-0.4^(-7) - ((r_c)^(-13) - r_c^(-7))/2)/r_c
    elseif r < r_c
        return 48(r^(-13)-r^(-7) - ((r_c)^(-13) - r_c^(-7))/2)/r_c
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

    #Pasamos a flotantes para el cálculo de la distancia y la fuerza
    x_ij = x_j - x_i
    y_ij = y_j - y_i
    z_ij = z_j - z_i

    #Hay que considerar que la distancia se ve afectada por las fronteras periódicas.
    #Esta solución sólo funciona si hay más que tres divisiones por lado.
    
    
    #El factor de 2 está bien porque estamos considerando cada coordenada por separado.
    rad_max = flotante_a_entero(2radio_critico, lado_caja, cajitas)

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

    x_ij = entero_a_flotante(x_ij, lado_caja, cajitas)
    y_ij = entero_a_flotante(y_ij, lado_caja, cajitas)
    z_ij = entero_a_flotante(z_ij, lado_caja, cajitas)
    
    r_ij = sqrt(x_ij^2 + y_ij^2 + z_ij^2)

    f_ij = fuerza(r_ij, radio_critico)

    fx = f_ij * x_ij
    fy = f_ij * y_ij
    fz = f_ij * z_ij

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
function vector_fuerzas{T<:Float64}(coord_enteras::Vector{Int64}, lado_caja::T,
                                    cajitas::Int64, radio_critico::T, h::T)
    #Coordenadas es el arreglo con las posiciones X = (x1,y1,z1, x2,y2,z2, ...)
    largo = length(coord_enteras)
    suma_fuerzas = zeros(Int64, largo)

    divisiones = Int64(cld(lado_caja, radio_critico))

    zonas = teselador_mat(coord_enteras, divisiones, cajitas)

    for m = 1:divisiones, n = 1:divisiones, l = 1:divisiones
        zona = zonas[m,n,l]
        vecindario = vecinos(zonas,m,n,l)

        #Aquí aseguramos que las fuerzas dentro de zona sólo se calculen una ocasión.
        #Si ambas partículas están dentro de zona hay que imponer i<j para lo anterior.
        for i in zona, j in zona
            if i<j  #Para no calcular dos veces la misma fuerza.
                fuerzas!(suma_fuerzas, coord_enteras, i, j, cajitas, lado_caja, radio_critico, h)
            end
        end
        #Si en cambio una está en zona y la otra en vecinos i<j no es necesario.
        for i in zona, j in vecindario
            fuerzas!(suma_fuerzas, coord_enteras, i, j, cajitas, lado_caja, radio_critico, h)
        end
    end
    suma_fuerzas
end

###----------------------------------- Integradores y Pasos Temporales ---------------------------------------------###

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

function fluctuacion_gaussiana(X_0, media = 0.0, desv_std = 0.1)
    largo = length(X_0)
    distribucion = Normal(media, desv_std)
    fluctuaciones = rand(distribucion, largo)
    X_0 + fluctuaciones
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


end
