GLOBAL_LIST_INIT(xeno_mutations, subtypesof(/datum/xeno_mutation))

/datum/xeno_mutation
	var/name = "Brain cancer"

	///XENO_MUT_COMMON - coexists with mutations with same mut_type, XENO_MUT_UNIQUE - doesn't coexist.
	var/coexisting = XENO_MUT_COMMON
	var/mut_type = XENO_MUT_GENERIC
	
	///What mob does have this mutation?
	var/mob/living/simple_animal/hostile/retaliate/xenobio/mymob

	///Is this mutation active, or no?
	var/inert = FALSE

	///If the mutation becomes broken, it turns into one of this. Otherwise mutates into any negative mutation.
	var/list/damaged_mutations = list()

	///If the mutation sucessfully mutates, it mutates into one of this. Otherwise mutates into any mutation that can be mutated.
	var/list/mutates_into = list()

	///Is this mutation bad, good or just neutral
	var/list/usefulness = XENO_MUT_NEUTRAL

	///Can it mutate into other mutation?
	var/can_mutate = TRUE

	///Does it do something every owners Life() tick?
	var/continous = FALSE

/datum/xeno_mutation/proc/AddToMob(mob/living/simple_animal/hostile/retaliate/xenobio/mutant, is_inert = FALSE, force = FALSE)
	if(!force && !CanMutate(mutant))
		return FALSE
	mymob = mutant
	if(is_inert)
		inert = is_inert
		mymob.inert_mutations |= src
	else
		mymob.current_mutations |= src
		Activate()
	return TRUE

/datum/xeno_mutation/proc/CanMutate(mob/living/simple_animal/hostile/retaliate/xenobio/mutant)
	for(var/datum/xeno_mutation/mutation in mutant.get_all_muts())
		if(!istype(mutation))
			continue
		if(istype(src, mutation))
			return FALSE
		if((mutation.coexisting == XENO_MUT_UNIQUE || coexisting == XENO_MUT_UNIQUE) && mut_type == mutation.mut_type)
			return FALSE
		if(mutant.mutation_whitelist.len && !is_type_in_typecache(src, mutant.mutation_whitelist))
			return FALSE
		if(mutant.mutation_blacklist.len && is_type_in_typecache(src, mutant.mutation_blacklist))
			return FALSE
	return TRUE

/datum/xeno_mutation/proc/Activate()
	if(inert)
		inert = FALSE
		mymob.inert_mutations -= src
	mymob.current_mutations |= src
	if(continous)
		RegisterSignal(mymob, COMSIG_LIVING_BIOLOGICAL_LIFE, .proc/on_mob_life)

/datum/xeno_mutation/proc/on_mob_life()
	return

/datum/xeno_mutation/proc/Deactivate(remove = FALSE)
	inert = TRUE
	if(!remove)
		mymob.inert_mutations |= src
	mymob.current_mutations -= src
	if(continous)
		UnregisterSignal(mymob, COMSIG_LIVING_BIOLOGICAL_LIFE)

/datum/xeno_mutation/Destroy()
	Deactivate(remove = TRUE)
	. = ..()

/datum/xeno_mutation/proc/AttemptChange(can_do_nothing = TRUE) ///Attempt to do something, alike mutating into something new or like that
	if(can_do_nothing && prob(40))
		return
	var/list/things_to_hapen = list("change_inert_state", "die", "meltdown", "mutate_me", "mutate_new")
	switch(pick(things_to_hapen))
		if("change_inert_state")
			if(inert)
				Activate()
			else
				Deactivate(FALSE)
		if("die")
			qdel(src)
		if("meltdown")
			var/datum/xeno_mutation/newmut
			if(damaged_mutations.len)
				newmut = pick(damaged_mutations)
			else
				var/list/valid_bad_muts = list()
				for(var/mut_type in GLOB.xeno_mutations)
					var/datum/xeno_mutation/possible_mut = new mut_type
					if(!istype(possible_mut))
						qdel(possible_mut)
						continue
					if(!possible_mut.CanMutate(mymob))
						qdel(possible_mut)
						continue
					if(possible_mut.usefulness == XENO_MUT_NEGATIVE)
						valid_bad_muts |= possible_mut.type
					qdel(possible_mut)

				newmut = pick(valid_bad_muts)
			mymob.AddMut(newmut, inert)
		if("mutate_me")
			mutate_new_mutation()
			qdel(src)
		if("mutate_new")
			mutate_new_mutation()

/datum/xeno_mutation/proc/mutate_new_mutation()
	var/datum/xeno_mutation/newmut
	if(mutates_into.len)
		newmut = pick(mutates_into)
	else
		var/list/valid_muts = list()
		for(var/mut_type in GLOB.xeno_mutations)
			var/datum/xeno_mutation/possible_mut = new mut_type
			if(!istype(possible_mut))
				qdel(possible_mut)
				continue
			if(!possible_mut.CanMutate(mymob))
				qdel(possible_mut)
				continue
			valid_muts |= possible_mut.type
			qdel(possible_mut)

		newmut = pick(valid_muts)
	mymob.AddMut(newmut, inert)
		