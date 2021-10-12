GLOBAL_DATUM_INIT(herb_manager,/datum/herb_manager,new)

/datum/herb_manager
	var/list/possible_chems
	var/list/herb_chems
	
/datum/herb_manager/New()
	. = ..()
	initialize_herb_chems()

/datum/herb_manager/Destroy(force, ...)
	message_admins("For some reason herb manager is being deleted, it will SEVERELY fuck up jungleland herb system, what are you even doing?")
	return ..()
	
/datum/herb_manager/proc/initialize_herb_chems()
	var/list/herbs = subtypesof(/obj/structure/herb)
	var/picked_chem = pick(possible_chems)
	herb_chems[pick(herbs)] = picked_chem
	possible_chems -= picked_chem

/datum/herb_manager/proc/get_chem(type)
	return herb_chems[type]

// reagents

/datum/reagent/jungle
	name = "Impossible Jungle Chem"
	description = "A reagent that is impossible to make in the jungle."
	can_synth = FALSE
	taste_description = "It tastes like a jungle."

/datum/reagent/jungle/retrosacharide
	name = "Retrosacharide"
	description = "Sacharide with a twisting structure that resembles the golden spiral."
	taste_description = "It tastes like a sugar you've never had before."

/datum/reagent/jungle/retrosacharide/on_mob_metabolize(mob/living/L)
	. = ..()
	
