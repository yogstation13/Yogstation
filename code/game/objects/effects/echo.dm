/particles/echo
	icon = 'icons/effects/echo.dmi'
	icon_state = list("echo1" = 1, "echo2" = 1, "echo3" = 2)
	width = 480
	height = 480
	count = 1000
	spawning = 0.5
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	gravity = list(0, -0.1)
	position = generator("box", list(-240, -240), list(240, 240), NORMAL_RAND)
	drift = generator("vector", list(-0.1, 0), list(0.1, 0))
	rotation = generator("num", 0, 360, NORMAL_RAND)
	color = "#25a5ea"
