/datum/psi_complexus/proc/check_latency_trigger(trigger_strength = 0, source, brain_damage = 0, force = FALSE)

	if(!LAZYLEN(latencies))
		return FALSE

	if(brain_damage) //don't force it when it's not had time to rest
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(brain_damage/2, brain_damage))

	if(world.time < next_latency_trigger && !force)
		if(brain_damage)
			to_chat(owner, span_danger("Your head throbs as [source] messes with your brain!"))
		return

	next_latency_trigger = world.time + rand(10 SECONDS, 30 SECONDS)

	if(prob(trigger_strength))
		var/faculty = pick(latencies)

		var/new_rank = PSI_RANK_OPERANT
		switch(rand(0, 10000)) //i intially tried using a weighted list with pickweight, but i kept getting out of bounds errors for some reason
			if(0) //weighted so you can still roll grandmaster, but at a really rare chance
				new_rank = PSI_RANK_GRANDMASTER
			if(1 to 100)
				new_rank = PSI_RANK_MASTER
			if(101 to INFINITY)
				new_rank = PSI_RANK_OPERANT

		owner.set_psi_rank(faculty, new_rank)
		var/datum/psionic_faculty/faculty_decl = SSpsi.get_faculty(faculty)
		to_chat(owner, span_danger("You scream internally as your [faculty_decl.name] faculty is forced into operancy by [source]!"))
		next_latency_trigger = world.time + (rand(60 SECONDS, 180 SECONDS) * new_rank)
	else if(brain_damage)
		to_chat(owner, span_danger("Your head throbs as [source] messes with your brain!"))
		return FALSE

	return TRUE
