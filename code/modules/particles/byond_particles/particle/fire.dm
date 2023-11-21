///GENERIC FIRE EFEFCT
/particles/fire
	width = 500
	height = 500
	count = 3000
	spawning = 3
	lifespan = 10
	fade = 10
	velocity = list(0, 0)
	position = generator("vector", list(-9,3,0), list(9,3,0), NORMAL_RAND)
	drift = generator("vector", list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.65)
	color = "white"

/particles/embers
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot" = 4,"cross" = 1,"curl" = 1)
	width = 64
	height = 96
	count = 500
	spawning = 5
	lifespan = 3 SECONDS
	fade = 1 SECONDS
	color = 0
	color_change = 0.05
	gradient = list("#FBAF4D", "#FCE6B6", "#FD481C")
	position = generator("box", list(-12,-16,0), list(12,16,0), NORMAL_RAND)
	drift = generator("vector", list(-0.1,0), list(0.1,0.025), UNIFORM_RAND)
	spin = generator("num", list(-15,15), NORMAL_RAND)
	scale = generator("vector", list(0.5,0.5), list(2,2), NORMAL_RAND)

// water is basically inverse fire, right?
// Water related particles.
/particles/droplets
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot"=2,"drop"=1)
	width = 32
	height = 36
	count = 5
	spawning = 0.2
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	color = "#549EFF"
	position = generator("box", list(-9,-9,0), list(9,18,0), NORMAL_RAND)
	scale = generator("vector", list(0.9,0.9), list(1.1,1.1), NORMAL_RAND)
	gravity = list(0, -0.9)
