/datum/action/cooldown/spell/toggle/maglock
	name = "Maglock"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "magboots0"
	button_icon = 'icons/obj/clothing/shoes.dmi'
	background_icon_state = "bg_default"

/datum/action/cooldown/spell/toggle/maglock/Grant(mob/M)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(UpdateSpeed))

/datum/action/cooldown/spell/toggle/maglock/Remove(mob/M)
	UnregisterSignal(M, COMSIG_MOB_CLIENT_PRE_MOVE)
	return ..()

/datum/action/cooldown/spell/toggle/maglock/Enable()
	ADD_TRAIT(owner, TRAIT_NOSLIPWATER, type)
	ADD_TRAIT(owner, TRAIT_NOSLIPICE, type)
	ADD_TRAIT(owner, TRAIT_MAGBOOTS, type)
	button_icon_state = "magboots1"
	to_chat(owner, span_notice("You enable your mag-pulse traction system."))
	UpdateSpeed()

/datum/action/cooldown/spell/toggle/maglock/Disable()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER, type)
	REMOVE_TRAIT(owner, TRAIT_NOSLIPICE, type)
	REMOVE_TRAIT(owner, TRAIT_MAGBOOTS, type)
	button_icon_state = "magboots0"
	to_chat(owner, span_notice("You disable your mag-pulse traction system."))
	UpdateSpeed()

/datum/action/cooldown/spell/toggle/maglock/proc/UpdateSpeed()
	if(active && !HAS_TRAIT(owner, TRAIT_IGNORESLOWDOWN) && owner.has_gravity())
		owner.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown = 1, blacklisted_movetypes=(FLYING|FLOATING))
	else if(owner.has_movespeed_modifier(type))
		owner.remove_movespeed_modifier(type)
