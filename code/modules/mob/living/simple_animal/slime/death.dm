/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new(loc, colour)
			M.rabid = TRUE
			M.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive(full_heal = 1)
			regenerate_icons()
			update_appearance(UPDATE_NAME)
			return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	set_stat(DEAD)
	cut_overlays()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib(no_brain, no_organs, no_bodyparts, no_items)
	death(TRUE)
	qdel(src)
