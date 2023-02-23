/*
* Defines on _DEFINES/zombies.dm
*/

/datum/zombie_mutation
	var/sector = SECTOR_COMMON
	var/name = "sse=wellpsl"
	var/id = ""
	var/desc = "make a bug report if you see this"
	var/mutation_cost = 0
	var/owned = FALSE
	var/datum/antagonist/zombie/zombie_owner
	var/owner_class

/*
* See darkspawn_upgrade.dm for these
*/
/datum/zombie_mutation/New(zombie_datum)
	..()
	zombie_owner = zombie_datum

/datum/zombie_mutation/proc/on_purchase()
	if(sector == SECTOR_CLASS)
		switch(zombie_owner.class_chosen)
			if(null)
				return FALSE
			if(SMOKER)
				if(!(owner_class & SMOKER_BITFLAG))
					return FALSE
			if(RUNNER)
				if(!(owner_class & RUNNER_BITFLAG))
					return FALSE
			if(SPITTER)
				if(!(owner_class & SPITTER_BITFLAG))
					return FALSE
			if(JUGGERNAUT)
				if(!(owner_class & JUGGERNAUT_BITFLAG))
					return FALSE
			if(BRAINY)	
				if(!(owner_class & BRAINY_BITFLAG))
					return FALSE
	if(!zombie_owner)
		return FALSE
	apply_effects()
	qdel(src)
	return TRUE

/datum/zombie_mutation/proc/apply_effects()
	zombie_owner.mutation_rate++

//These are common abilities between all classes

/datum/zombie_mutation/additional_infection
	name = "Storage Glands"
	id = "additional_infection"
	desc = "Gain additional 20 max infection points."
	mutation_cost = 1

/datum/zombie_mutation/additional_infection/apply_effects()
	. = ..()
	zombie_owner.infection_max += 20
	zombie_owner.update_infection_hud() //just incase

/datum/zombie_mutation/less_infection_usage //these passive ones are checked during the actual proc of the abilities to see if they are present to reduce costs and whatnot
	name = "Efficient Chemical Management"
	id = "reduced_cost"
	desc = "Halves the cost of infection points to first use non instant abilities."
	mutation_cost = 1

/datum/zombie_mutation/last_resort
	sector = SECTOR_CLASS
	name = "Explosive Glands"
	id = "reduced_cost"
	desc = "Gains the escape ability, which kills your current but makes you into a tumor carrying worm."
	mutation_cost = 1
	owner_class = SMOKER_BITFLAG | RUNNER_BITFLAG | SPITTER_BITFLAG | JUGGERNAUT_BITFLAG

/datum/zombie_mutation/last_resort/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/last_resort/L = new
	L.Grant(zombie_owner.owner?.current)
