/obj/effect/proc_holder/hog
	name = "Magiiiiiic"
	panel = "HoG Spells"
	has_action = TRUE
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_alien"
	var/energy_cost = 0
	var/charges = 1 ///Maximum 4 charges on a spell.

/obj/effect/proc_holder/hog/Initialize()
	. = ..()
	action = new(src)

/obj/effect/proc_holder/hog/Click()
	var/mob/living/user = usr
	var/datum/antagonist/hog/antag_d = IS_HOG_CULTIST(user)
	if(!antag_d)
		return 1
	if(cost_check(antag_d, user))
		if(fire(user) && user) // Second check to prevent runtimes when evolving
			antag_d.energy -= energy_cost
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
		to_chat(user, span_noticealien("Not enough energy."))
		return FALSE
	return TRUE
