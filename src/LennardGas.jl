module LennardGas

using  Distributions, PyCall, PyPlot
@pyimport matplotlib.animation as anim

export flotante_a_entero, entero_a_flotante,
       cubito, bifase, fluctuacion_gaussiana, vector_fuerzas!,
       paso_verlet!, evolucion, evolucion_reversible, prueba_reversible,
       organizador, fotograma, animador

include("entero_flotante.jl")
include("estados_iniciales.jl")
include("fuerzas.jl")
include("teselas_y_vecinos.jl")
include("verlet.jl")

include( "graficos.jl") #Quizá no se requiera importar estas funciones aquí.

end # module
