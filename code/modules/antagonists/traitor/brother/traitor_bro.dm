/datum/status_effect/agent_pinpointer/brother
	id = "brother_pinpointer"
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/brother
	var/datum/mind/set_target
	var/list/datum/mind/allowed_targets

	//ree magic numbers
	minimum_range = 2
	range_fuzz_factor = 0

/atom/movable/screen/alert/status_effect/agent_pinpointer/brother
	name = "Blood Brother Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/brother/scan_for_target()
	scan_target = null
	if(set_target)
		scan_target = set_target.current
		return
	var/datum/mind/picked = pick(allowed_targets)
	scan_target = picked.current

/atom/movable/screen/alert/status_effect/agent_pinpointer/brother/Click()
	if(attached_effect)
		var/datum/status_effect/agent_pinpointer/brother/E = attached_effect
		E.set_target = input(usr,"Select target to track","Pinpointer") as null|anything in E.allowed_targets
	..()
