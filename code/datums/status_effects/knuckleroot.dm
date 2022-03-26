/datum/status_effect/root
	id = "snared"
	duration = 100
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/root
	var/icon/cube
	var/can_melt = TRUE

/obj/screen/alert/status_effect/root
	name = "grasped"
	desc = "You're held in place by some hellish force! Fight back while you can!"
	icon_state = "grip"

/datum/status_effect/root/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, .proc/owner_resist)
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become caught in blood!"))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.add_overlay(cube)
	owner.update_mobility()
	return ..()

/datum/status_effect/root/proc/owner_resist()
	to_chat(owner, "You start breaking out of the ice cube!")
	if(do_mob(owner, owner, 40))
		if(!QDELETED(src))
			to_chat(owner, "You break out of the ice cube!")
			owner.remove_status_effect(/datum/status_effect/root)
			owner.update_mobility()

/datum/status_effect/root/on_remove()
	if(!owner.stat)
		to_chat(owner, "Your bindings are gone!")
	owner.cut_overlay(cube)
	owner.update_mobility()
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)

/datum/status_effect/root/watcher
	duration = 8
	can_melt = FALSE
