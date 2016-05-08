# Simulación *reversible* de un gas clásico en Julia.

Simulación de un gas de partículas cuya interacción se rige por un potencial de Lennard-Jones modificado para volverse nulo tras una distancia crítica *Rc* de manera suave.

Se utiliza aritmética de enteros `Int64` para evitar errores asociadas a operaciones entre números de punto flotante `Float64`, siguiendo las ideas expuestas en: 

* Levesque, D., & Verlet, L. (1993). Molecular dynamics and time reversibility. Journal of Statistical Physics, 72(3-4), 519-537.

Se implementa una optimización semejante al método de árboles para reducir el tiempo de computo, no introduce aproximaciones.

Las partículas se encuentran en una caja cúbica de lado *L* donde las fronteras son periódicas.

### Animaciones

Por el momento se pueden generar GIFs que ilustran la reversibilidad con el script `animacion_plots_pyplot.jl`, 
que requiere los paquetes `Plots.jl` y `PyPlot.jl` de Julia y `ffmpeg` o `ImageMagick` (*mejor calidad*) del sistema.

Correr dentro del repositorio el siguiente comado:

`$julia animacion_plots_pyplot.jl <raíz_cúbica_del_número_de_partículas> <pasos_temporales>`

Los argumentos deben ser `Int64`. (*raíz_cúbica_del_número_de_partículas* ~ 7 y *pasos_temporales* ~ 50 es razonable)

En el futuro se utilizará un visualizador de tiempo real (tentativamente `GR.jl` o hasta `GLVisualize.jl`), por el momento se puede utilizar `animacion_en_vivo_pyplot.jl` pero es bastante lento.

### Metas

- [x] Reversibilidad
- [ ] Optimización con macros de julia
- [x] Creación de GIFs o videos mp4
- [ ] Animación en tiempo real.

#### Para discutir sobre el proyecto...
[![Gitter](https://badges.gitter.im/blas-ko/simulacion_gases_reversible.svg)](https://gitter.im/blas-ko/simulacion_gases_reversible?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
