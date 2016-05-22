function organizador(coord::Vector{Int64})

    N = length(coord)÷3 #Funciona si el número de entradas es múltiplo de 3
    x = zeros(N)
    y = zeros(N)
    z = zeros(N)
    for i in 1:N
        x[i] = coord[3i-2]
        y[i] = coord[3i-1]
        z[i] = coord[3i]
    end
    x,y,z
end

function organizador(registro::Matrix{Int64}, tiempo::Int64)

    N = size(registro, 2)÷3 #Funciona si el número de entradas es múltiplo de 3
    coord = registro[tiempo, :]
    x = zeros(N)
    y = zeros(N)
    z = zeros(N)
    for i in 1:N
        x[i] = coord[3i-2]
        y[i] = coord[3i-1]
        z[i] = coord[3i]
    end
    x,y,z
end

function fotograma(registro::Matrix{Int64}, tiempo::Int64; cajitas::Int64 = 0)

    if (tiempo < 0) | (tiempo > size(registro, 1))
        return println("El tiempo solicitado no se encuentra disponible en el registro dado.")
    end

    x,y,z = organizador(registro, tiempo)
    plot3D(x, y, z, "b.", markersize = 4.0)
    #axis("off")

    #Si se especifica cajitas se evita el "zoom" automático.
    if cajitas != 0
        xlim(1,cajitas)
        ylim(1,cajitas)
        zlim(1,cajitas)
    end
end

function animador(registro::Matrix{Int64}, nombre::ASCIIString)

    fig = figure()
    rollo = []

    paso_temp = size(registro, 1)
    for t in 1:paso_temp
        x,y,z = organizador(registro,t)
        fg = plot3D(x, y, z, "b.", markersize = 4.0)
        push!(rollo, collect(fg))
    end

    #axis("off")
    xlim(1,cajitas)
    ylim(1,cajitas)
    zlim(1,cajitas)

    ani = anim.ArtistAnimation(fig, rollo, interval = 100, blit = true, repeat = true, repeat_delay = 2000)
    ani[:save](nombre*".mp4", extra_args=["-vcodec", "libx264", "-pix_fmt", "yuv420p"])
end
