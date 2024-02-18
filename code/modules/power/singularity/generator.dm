/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF

	// You can buckle someone to the singularity generator, then start the engine. Fun!
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

	var/energy = 0
	var/creation_type = /obj/singularity/gravitational

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, W, 0)
	else
		return ..()

/obj/machinery/the_singularitygen/update_icon(updates=ALL, power)
	. = ..()
	if(!power)
		return
	if(power>150)
		animate(src, icon_state = "[initial(icon_state)]_3", 10)
	else if(power>100)
		animate(src, icon_state = "[initial(icon_state)]_2", 10)
	else if(power>50)
		animate(src, icon_state = "[initial(icon_state)]_1", 10)
	else
		animate(src, icon_state = initial(icon_state), 10)

/obj/machinery/the_singularitygen/process(delta_time)
	if(energy > 0)
		if(energy >= 200)
			var/turf/T = get_turf(src)
			SSblackbox.record_feedback("tally", "engine_started", 1, type)
			var/obj/singularity/S = new creation_type(T, 50)
			transfer_fingerprints_to(S)
			qdel(src)
		else
			energy -= delta_time * 0.5
			update_icon(power = energy)
