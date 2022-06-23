/obj/structure/destructible/hog_structure/shrine
	name = "shrine"
	desc = "A strange magical energy source."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "shrine"
	anchored = TRUE
	density = TRUE
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	max_integrity = 140
	break_message = span_cult("The nexus explodes in a bright flash of light!") 
	constructor_range = 10
	var/energy_generation = 8
	var/storage = 100

/obj/structure/destructible/hog_structure/shrine/handle_team_change(datum/team/hog_cult/new_cult)
	if(cult)
		cult.energy_regen -= energy_generation
		cult.max_energy -= storage
		cult.change_energy_amount(0)
	new_cult.energy_regen += energy_generation
	new_cult.max_energy += storage
	new_cult.change_energy_amount(0)
	. = ..()
	if(cult && cult.cult_objective && !cult.cult_objective.completed && istype(cult_objective, /datum/hog_objective/holyland))
		cult.cult_objective.check_completion()


/obj/structure/destructible/hog_structure/shrine/Destroy()
	cult.energy_regen -= energy_generation
	cult.max_energy -= storage
	cult.change_energy_amount(0)	
	. = ..()

/obj/structure/destructible/hog_structure/shrine/special_interaction(mob/user)
	if(!user)
		return
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(!cultie)
		return
	if(cultie.cult != src.cult)
		return
	if(cultie.energy >= cultie.max_energy)
		to_chat(user, span_notice("You alredy have enough energy."))
		return	
	if(!do_after(user, src, 1.5 SECONDS))
		to_chat(user, span_warning("You stop drawing energy from [src]."))
		return
	var/energy_to_give = min(min(HOG_ENERGY_TRANSFER_AMOUNT, cult.energy), (cultie.max_energy - cultie.energy))
	if(energy_to_give <= 0)
		to_chat(user, span_warning("You can't get any energy from [src]."))
		return	
	cultie.get_energy(energy_to_give)	
	cult.change_energy_amount(-energy_to_give)
	to_chat(user, span_warning("You sucessfully withdraw [energy_to_give] energy from [src]. You now have [cultie.energy] energy left."))
	if(cultie.energy >= cultie.max_energy)
		to_chat(user, span_warning("You stop drawing energy from [src]."))
		return		
	special_interaction(user)

/datum/hog_god_interaction/targeted/construction/shrine
	name = "Construct a shrine"
	description = "Construct a shrine, that will produce energy for your cult. Note, that it can be constructed only once per area."
	cost = 265
	time_builded = 35 SECONDS
	warp_name = "shrine"
	warp_description = "a pulsating mass of energy in a form of a strange structure"
	structure_type = /obj/structure/destructible/hog_structure/shrine
	max_constructible_health = 65
	integrity_per_process = 5
	icon_name = "shrine_constructing"

/datum/hog_god_interaction/targeted/construction/shrine/can_be_placed(var/turf/open/construction_place, var/datum/team/hog_cult/cult)
	if(!construction_place)
		return FALSE
	var/area/location = get_area(construction_place)
	if(!location)
		return FALSE
	for(var/obj/structure/destructible/hog_structure/structure in location)
		if(istype(structure, /obj/structure/destructible/hog_structure/shrine))
			return FALSE
		if(istype(structure, /obj/structure/destructible/hog_structure/lance/nexus))
			return FALSE
	return TRUE
