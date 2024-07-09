/datum/psi_complexus/proc/check_latency_trigger(trigger_strength = 0, source, redactive = FALSE)

	if(!LAZYLEN(latencies) || world.time < next_latency_trigger)
		return FALSE

	next_latency_trigger = world.time + rand(10 SECONDS, 30 SECONDS)

	if(!redactive)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(trigger_strength, trigger_strength * 2))

	if(prob(trigger_strength))
		var/faculty = pick(latencies)
		var/new_rank = pickweight(list(PSI_RANK_OPERANT = 100, PSI_RANK_MASTER = 10, PSI_RANK_GRANDMASTER = 1)) //weighted so you can still roll grandmaster, but at a really rare chance
		owner.set_psi_rank(faculty, new_rank)
		var/datum/psionic_faculty/faculty_decl = SSpsi.get_faculty(faculty)
		to_chat(owner, span_danger("You scream internally as your [faculty_decl.name] faculty is forced into operancy by [source]!"))
		next_latency_trigger = world.time + (rand(60 SECONDS, 180 SECONDS) * new_rank)
	else if(!redactive)
		to_chat(owner, span_danger("Your head throbs as [source] messes with your brain!"))
		return FALSE

	return TRUE
