/obj/structure/destructible/hog_structure/shrine
	name = "shrine"
	desc = "A strange magical energy source."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "shrine"
	anchored = TRUE
	density = TRUE
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	max_integrity = 500
	cost = 300 ///Zamn
	time_builded = 35
	break_message = span_cult("The nexus explodes in a bright flash of light!") 
	constructor_range = 10
	var/energy_generation = 10

/obj/structure/destructible/hog_structure/shrine/special_interaction(mob/user)
	var/mob/living/carbon/C = user
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

