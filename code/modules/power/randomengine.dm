/obj/machinery/the_singularitygen/random
	name = "Random Engine" // Blatant code reuse shh
	desc = "Tell Coders if you see this"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "generic_event" // Too Lazy to make sprit so use random questionmark box

/obj/machinery/the_singularitygen/random/Initialize(mapload)
	..()
	switch(prob(50)) // 50% chance to trigger either
		if(0)
			new /obj/machinery/the_singularitygen/tesla(src)
		if(1)
			new /obj/machinery/the_singularitygen(src)
	qdel(src)
