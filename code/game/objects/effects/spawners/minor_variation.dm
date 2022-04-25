/*
Makes variations possible with code only.
This is mainly to prevent creating new map files when creating smaller variations that aren't worth a map file. - Hopek
*/

/obj/effect/variation
	name = "variation"
	icon = 'icons/effects/landmarks_variation.dmi'
	icon_state = "generic_green"
	var/variations // number of variations
	var/choice // chosen variation by choice()
	var/chosen // has a choice been made for this place?
	var/location_place // location of placement calculated from reference
	var/ref_x // x of reference
	var/ref_y // y of reference
	var/ref_z // z of reference

/obj/effect/variation/Initialize()
	. = ..()
	chosen = FALSE
	placement()

/obj/effect/variation/proc/placement()
	return

/obj/effect/variation/proc/place(x = 0, y = 0 , item , direction)
	if(!x)
		x = 0
	if(!y)
		y = 0
	if(item)
		location_place = locate((ref_x + x) , (ref_y + y) , ref_z)
		if(islist(item))
			for(var/I in item)
				if(direction)
					var/obj/H = new I(location_place)
					H.dir = direction
					
				else
					new I(location_place)
		else
			if(direction)
				var/obj/H = new item(location_place)
				H.dir = direction
			else
				new item(location_place)
	

/obj/effect/variation/proc/choice()
	if(!choice)
		choice = 1
	if(!chosen)
		ref_x = src.x
		ref_y = src.y
		ref_z = src.z
		qdel(src) // deletes the landmark after storing location values in choice() so it doesn't show up on the final product
		chosen = TRUE
		choice = rand(1, variations)
		log_world("Chosen variation [choice] out of [variations] for [name]. Spawning on [ref_x],[ref_y],[ref_z].")
	return choice
