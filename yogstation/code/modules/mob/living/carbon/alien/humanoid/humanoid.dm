//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/Initialize()
	AddAbility(new/obj/effect/proc_holder/alien/regurgitate(null))
	. = ..()
