/datum/antagonist/changeling/select_dna(var/prompt, var/title)
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return
	var/list/names = list("Drop Flesh Disguise" = image(icon = 'icons/effects/effects.dmi', icon_state = "blank"))
	for(var/entry in stored_snapshots)
		var/datum/icon_snapshot/snap = stored_snapshots[entry]
		var/image/dummy = image(snap.icon, src, snap.icon_state)
		dummy.overlays = snap.overlays
		names[entry] = dummy

	var/chosen_name = show_radial_menu(owner.current, owner.current, names, radius = 42, tooltips = TRUE)
	if(!chosen_name)
		return

	if(chosen_name == "Drop Flesh Disguise")
		for(var/slot in GLOB.slots)
			if(istype(user.vars[slot], GLOB.slot2type[slot]))
				qdel(user.vars[slot])

	var/datum/changelingprofile/prof = get_dna(chosen_name)
	return prof
