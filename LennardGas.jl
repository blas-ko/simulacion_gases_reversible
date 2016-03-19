module LennardGas

using Distributions 
export evolucion_verlet, fluctuacion_gaussiana

# res == resolución == cajitas
const res = 2^60

#Esta sirve para poder dar 2 condiciones iniciales (verlet lo necesita)
function fluctuacion_gaussiana(X_0, media = 0.0, desv_std = 0.1)
    largo = length(X_0)
    distribucion = Normal(media, desv_std)
    fluctuaciones = rand(distribucion, largo)
    X_0 + fluctuaciones
end

include("int_float.jl")
include("teselación_y_vecinos.jl")
include("fuerzas.jl")
include("verlet.jl")

end