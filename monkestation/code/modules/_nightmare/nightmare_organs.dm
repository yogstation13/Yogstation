/obj/item/organ/internal/brain/shadow/nightmare/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(length(owner.all_wounds) && SPT_PROB(10, seconds_per_tick))
		var/turf/owner_turf = get_turf(owner)
		if(owner_turf.get_lumcount() < SHADOW_SPECIES_LIGHT_THRESHOLD)
			var/datum/wound/wound = pick(owner.all_wounds)
			to_chat(owner, span_green("The darkness soothes the [lowertext(wound.name)] in your [wound.limb.plaintext_zone]!"))
			qdel(wound) // Occasionally heal a random wound while in the dark.
