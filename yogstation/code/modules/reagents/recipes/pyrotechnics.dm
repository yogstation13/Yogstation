/datum/chemical_reaction/dilithium
	name = "Dilithium Gas Creation"
	id = "dilithiumgascreation"
	required_reagents = list(/datum/reagent/dilithium = 1, /datum/reagent/water = 1) // Just add water!

/datum/chemical_reaction/dilithium/on_reaction(datum/reagents/holder, created_volume)//Based on the on_reaction proc for phlogiston
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	var/turf/open/T = get_turf(holder.my_atom)
	if(istype(T))
		T.atmos_spawn_air("dilithium=[created_volume*2];TEMP=750")
	holder.clear_reagents()
	return
