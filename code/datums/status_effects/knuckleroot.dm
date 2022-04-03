/datum/status_effect/roots
	id = "roots"
	alert_type = /obj/screen/alert/status_effect/roots
	var/icon/cube
	duration = 20
	var/list/afflicted = list()

/obj/screen/alert/status_effect/roots
	name = "grasped"
	desc = "You're held in place by some hellish force! Fight back while you can!"
	icon_state = "grip"

/datum/status_effect/roots/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/owner_moved)
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become frozen in a cube!"))
	cube = icon('icons/effects/bubblegum.dmi', "smack ya one")
	var/icon/size_check = icon(owner.icon, owner.icon_state)
	cube.Scale(size_check.Width(), size_check.Height())
	owner.add_overlay(cube)
	owner.remove_status_effect(STATUS_EFFECT_KNUCKLED)
	if(!ishuman(owner))
		duration = 100
		owner.adjustBruteLoss(50)
	return ..()

/datum/status_effect/roots/proc/owner_moved()
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/status_effect/roots/on_remove()
	if(!owner.stat)
		to_chat(owner, "Your bindings are gone!")
	owner.cut_overlay(cube)
	owner.update_mobility()
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
