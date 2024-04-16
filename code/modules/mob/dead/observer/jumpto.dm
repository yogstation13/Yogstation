/datum/jump_menu
	var/mob/dead/observer/owner
	var/auto_observe = FALSE

/datum/jump_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/jump_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/jump_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Jump")
		ui.open()

/datum/jump_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if ("jump")
			if(!isobserver(usr))
				return

			var/ref = params["ref"]
			var/list/pois = GLOB.mob_list
			var/atom/movable/poi = (locate(ref) in pois) || (locate(ref) in GLOB.areas)

			if (!poi)
				. = TRUE
				return

			if(isarea(poi))
				var/area/A = poi
				owner.forceMove(pick(get_area_turfs(A)))
			else
				owner.forceMove(get_turf(poi))
			owner.reset_perspective(null)
		if ("refresh")
			update_static_data(owner, ui)
			. = TRUE

/datum/jump_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/mobs = list()
	var/list/areas

	var/list/mob_list = GLOB.mob_list
	for (var/mob/M in mob_list)
		var/list/serialized = list()
		serialized["name"] = M.name
		serialized["ref"] = REF(M) // Apparently name isn't a direct ref.
		mobs += list(serialized)

	var/list/Alist = GLOB.areas
	for (var/area/A in Alist)
		if(A.hidden)
			continue
		var/list/serialized = list()
		serialized["name"] = A.name
		serialized["ref"] =	REF(A)
		areas += list(serialized)

	data["mobs"] = mobs
	data["areas"] = areas
	return data

/datum/jump_menu/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/orbit)

