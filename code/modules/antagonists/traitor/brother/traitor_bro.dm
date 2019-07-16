/datum/status_effect/agent_pinpointer/brother
	id = "brother_pinpointer"
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/brother
	var/datum/mind/preset_target

	//ree magic numbers
	minimum_range = 2
	range_fuzz_factor = 0
	range_mid = 8
	range_far = 16

/obj/screen/alert/status_effect/agent_pinpointer/brother
	name = "Blood Brother Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/brother/scan_for_target()
	scan_target = null

	if(preset_target)
		scan_target = preset_target.current
		return

	//fallback method
	if(owner && owner.mind)
		for(var/datum/antagonist/brother/Q in owner.mind.has_antag_datum(/datum/antagonist/brother))
			var/datum/mind/list/other_brother = Q.team.members - owner.mind
			for(var/i = 1 to other_brother.len)
				scan_target = other_brother[1].current
				break