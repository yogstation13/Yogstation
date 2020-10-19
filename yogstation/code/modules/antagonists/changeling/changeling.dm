/datum/antagonist/changeling
	var/list/stored_snapshots = list() //list of stored snapshots


/datum/antagonist/changeling/add_new_profile(mob/living/carbon/human/H, protect = 0)
	.=..()
	var/datum/icon_snapshot/entry = new
	entry.name = H.real_name
	entry.icon = H.icon
	entry.icon_state = H.icon_state
	entry.overlays = H.get_overlays_copy(list(HANDS_LAYER))	//ugh
	stored_snapshots[entry.name] = entry
