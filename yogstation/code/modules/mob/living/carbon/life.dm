/mob/living/carbon/handle_brain_damage()
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life()