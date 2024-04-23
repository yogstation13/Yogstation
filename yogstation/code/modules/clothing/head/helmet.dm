/obj/item/clothing/head/helmet
	var/initial_state

/obj/item/clothing/head/helmet/Initialize(mapload)
	. = ..()
	initial_state = "[initial(icon_state)]"

/obj/item/clothing/head/helmet/update_icon_state()
	. = ..()
	var/state = "[initial_state]"
	if(attached_light)
		if(attached_light.light_on)
			state += "-flight-on" //"helmet-flight-on" // "helmet-cam-flight-on"
		else
			state += "-flight" //etc.

	icon_state = state

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()
