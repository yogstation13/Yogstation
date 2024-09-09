/datum/component/particle_spewer/cash
	unusual_description = "cashflow"
	icon_file = 'icons/obj/economy.dmi'
	particle_state = "spacecash1"
	burst_amount = 1
	duration = 2 SECONDS
	random_bursts = TRUE
	spawn_interval = 6 SECONDS

/datum/component/particle_spewer/cash/animate_particle(obj/effect/abstract/particle/spawned)
	var/chance = rand(1, 10)
	switch(chance)
		if(1 to 2)
			spawned.icon_state = "spacecash1"
		if(3 to 4)
			spawned.icon_state = "spacecash10"
		if(5 to 6)
			spawned.icon_state = "spacecash50"
		else
			spawned.icon_state = "spacecash20"

	if(prob(65))
		spawned.layer = LOW_ITEM_LAYER
	spawned.pixel_x += rand(-12, 12)
	spawned.pixel_y += rand(-5, 5)
	. = ..()

/datum/component/particle_spewer/cash/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = matrix(0.5, 0.5, MATRIX_SCALE), alpha = 125, time = 0))

	animate_holder.add_animation_step(list(transform = "RANDOM", time = 2 SECONDS, pixel_y = "RANDOM", pixel_x = "RANDOM", easing = LINEAR_EASING))

	animate_holder.set_random_var(2, "transform", list(-90, 90))
	animate_holder.set_random_var(2, "pixel_x", list(-16, 16))
	animate_holder.set_random_var(2, "pixel_y", list(-16, 16))
	animate_holder.set_transform_type(2, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(alpha = 25, time = 1.5 SECONDS))
