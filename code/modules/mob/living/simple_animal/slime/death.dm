/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new(loc, colour)
			M.happiness = 0
			if(!ckey && happiness < 0 && prob(abs(happiness)*2))//so at -20 its a 40% chance. at -50 happiness it's an 100% chance
				M.death()
				M.desc += " It looks like it was a stillborn..."
				M.happiness = MIN_HAPPY
			M.rabid = TRUE
			M.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			personality = rand(-7,7) //being sliced in twain produces two new babies. New personalities!
			happiness = 0 //a fresh start! If you're stuck with unhappy slimes just kill them until they like each other, lol
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive(full_heal = 1)
			regenerate_icons()
			update_name()
			return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	stat = DEAD
	cut_overlays()

	if(SSticker.mode)
		SSticker.mode.check_win()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)
