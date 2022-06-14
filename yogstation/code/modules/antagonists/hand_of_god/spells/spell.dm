/obj/effect/proc_holder/hog
	name = "Magiiiiiic"
	panel = "HoG Spells"
	has_action = TRUE
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_alien"
	var/energy_cost = 0
	var/charges = 1 
	var/max_charges = HOG_CULTIST_MAX_SPELLS 
	var/preparation_time = 1 SECONDS
	var/availible = TRUE

/obj/effect/proc_holder/hog/Initialize()
	. = ..()
	action = new(src)

/obj/effect/proc_holder/hog/Click()
	var/mob/living/user = usr
	var/datum/antagonist/hog/antag_d = IS_HOG_CULTIST(user)
	if(!antag_d)
		return 1
	if(cost_check(antag_d, user))
		if(fire(user) && user) 
			antag_d.energy -= energy_cost
			charges -= 1
			if(charges <= 0)
				qdel(src)
	return 1

/obj/effect/proc_holder/hog/get_panel_text()
	. = ..()
	if(energy_cost > 0)
		return "[energy_cost]"


/obj/effect/proc_holder/hog/proc/cost_check(var/datum/antagonist/hog/hog, mob/living/user)
	if(!hog)
		return FALSE
	if(user.stat)
		to_chat(user, span_notice("You must be conscious to do this."))
		return FALSE
	if(hog.energy < energy_cost)
		to_chat(user, span_notice("Not enough energy."))
		return FALSE
	return TRUE

/obj/effect/proc_holder/hog/fire(mob/living/carbon/user)
	return 1

/obj/effect/proc_holder/hog/proc/prepare(obj/item/hog_item/book/book, mob/living/user, datum/antagonist/hog/hog)
	if(!do_after(user, preparation_time, book) || !hog)
		qdel(src)
		return FALSE
	var/sus = 0
	for(var/obj/effect/proc_holder/hog/spell in hog.prepared_spells)
		if(istype(spell, src))
			if(spell.charges < max_charges)
				spell.charges++
				to_chat(user, span_notice("[spell] now has [spell.charges] charges."))	
				qdel(src)
				return FALSE
			else
				to_chat(user, span_notice("[spell] has alredy maximum charges."))	
				qdel(src)
				return FALSE
		else
			continue
		sus += spell.charges
	if(sus > HOG_CULTIST_MAX_SPELLS)
		to_chat(user, span_notice("You can have maximum summary of [HOG_CULTIST_MAX_SPELLS] charges."))	
		qdel(src)
		return FALSE
	user.AddAbility(src)
	hog.prepared_spells += src
	return TRUE
										
