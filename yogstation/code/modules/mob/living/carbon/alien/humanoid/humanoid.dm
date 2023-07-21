/mob/living/carbon/alien/humanoid/Initialize(mapload, null)
	var/datum/action/cooldown/alien/regurgitate/regurgitate = new(src)
	regurgitate.Grant(src)
	. = ..()
