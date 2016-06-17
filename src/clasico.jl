function fuerzas_clasico!{T<:Int64}(fuerzas::Vector{T}, coord_enteras::Vector{T}, i::T, j::T, cajitas::T,
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
function vector_fuerzas!{T<:Int64}(fuerzas::Vector{T}, coord_enteras::Vector{T}, largo_coord::T,
                                      lado_caja::Float64, cajitas::T, radio_critico::Float64, h::Float64)
    #Un nuevo vector de fuerzas en cada paso temporal.
    for k in eachindex(fuerzas); fuerzas[k] = 0; end

    for i in 3:3:largo_coord-3, j in i+3:3:largo_coord
        fuerzas_clasico!(fuerzas, coord_enteras, i, j, cajitas, lado_caja, radio_critico, h)
    end
end

function paso_verlet!{T<:Int64}(coord_futuras::Vector{T}, coord_actuales::Vector{T}, coord_previas::Vector{T},
                                  fuerzas::Vector{T}, largo_coord::T, lado_caja::Float64, cajitas::T,
                                    radio_critico::Float64, paso_temporal::Float64)

    vector_fuerzas!(fuerzas, coord_actuales, largo_coord, lado_caja, cajitas, radio_critico, paso_temporal)
    for i in 1:largo_coord
        coord_futuras[i] = -coord_previas[i] + 2*coord_actuales[i] + fuerzas[i]
        #Imponer periodicidad si algo salió de la caja mayor.
        if (coord_futuras[i] > cajitas) || (coord_futuras[i] < 1)
            coord_futuras[i] = mod1(coord_futuras[i], cajitas)
        end
    end
    coord_futuras
end

function evolucion_clasica{T<:Int64}(X0::Vector{T}, X1::Vector{T}, pasos::T, lado_caja::Float64,
                                      cajitas::T, radio_critico::Float64, paso_temporal::Float64)
    largo_coord = length(X0)
    registro = Matrix{Int64}(pasos+2, largo_coord)
    registro[1,:] = X0
    registro[2,:] = X1

    coord_futuras = zeros(Int64, largo_coord)
    fuerzas = zeros(Int64, largo_coord)

    for t in 3:pasos+2
        # Modifica: el arreglo de coord_futuras, zonas, vecindario y fuerzas.
        paso_verlet!(coord_futuras, collect(registro[t-1,:]), collect(registro[t-2,:]), fuerzas,
                      largo_coord, lado_caja, cajitas, radio_critico, paso_temporal)
        registro[t,:] = coord_futuras
    end
    registro
end
