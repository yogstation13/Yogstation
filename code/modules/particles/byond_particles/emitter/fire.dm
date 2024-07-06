/obj/emitter/fire
	alpha = 225
	particles = new/particles/fire
	var/fire_colour = "#FF3300"

//I hate this, i loath everything about having to create an Init because the byond level filters doesn't allow multiple filters to be set at once if this ever gets fixed please ping me -Borbop
/obj/emitter/fire/Initialize(mapload)
	. = ..()
	add_filter(name ="outline", priority = 1, params = list(type = "outline", size = 3,  color = fire_colour))
	add_filter(name = "bloom", priority = 2 , params = list(type = "bloom", threshold = rgb(255,128,255), size = 6, offset = 4, alpha = 255))

/obj/emitter/fire/holy
	fire_colour = "#fff700"
