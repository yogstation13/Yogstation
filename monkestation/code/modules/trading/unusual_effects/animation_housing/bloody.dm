/datum/component/particle_spewer/bloodydrip
	unusual_description = "exsanguinating"
	icon_file = 'icons/mob/effects/bleed_overlays.dmi'
	particle_state = "head_2"
	burst_amount = 1
	duration = 6 SECONDS
	random_bursts = TRUE
	spawn_interval = 4 SECONDS

/datum/component/particle_spewer/bloodydrip/animate_particle(obj/effect/abstract/particle/spawned)
	var/chance = rand(1, 12)
	switch(chance)
		if(1 to 2)
			spawned.icon_state = "head_2"
		if(3 to 4)
			spawned.icon_state = "l_leg_2"
		if(5 to 6)
			spawned.icon_state = "r_leg_2"
		if(7 to 8)
			spawned.icon_state = "r_arm_2"
		if(9 to 10)
			spawned.icon_state = "l_arm_2"
		else
			spawned.icon_state = "chest_2"

	spawned.layer = ABOVE_MOB_LAYER
	spawned.pixel_y -= 12
	. = ..()

