GLOBAL_LIST_INIT(infiltrator_objective_areas, typecacheof(list(/area/yogs/infiltrator_base, /area/syndicate_mothership, /area/shuttle/yogs/stealthcruiser)))

/datum/objective/assassinate/internal/check_completion()
	if(..())
		return TRUE
	return !considered_alive(target)

/datum/objective/hijack/sole_survivor
	name = "sole survivor"
	explanation_text = "Escape on the shuttle to ensure <b>no one except you</b> escapes alive and out of custody."
	team_explanation_text = "Escape on the shuttle to ensure <b>no one except your team</b> escapes alive and out of custody. Leave no team member behind."
	martyr_compatible = 0 //Technically you won't get both anyway.

/datum/objective/hijack/sole_survivor/check_completion() // Requires all owners to escape.
	if(completed)
		return TRUE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE
	var/list/datum/mind/owners = get_owners()
	for(var/mob/living/player in GLOB.player_list)
		var/datum/mind/M = player.mind
		if(!M)
			continue
		if(M in owners)
			if(!considered_alive(M) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)]) //Teammember in area.
				return FALSE
		else
			if(considered_alive(player.mind) && SSshuttle.emergency.shuttle_areas[get_area(M.current)]) //Non-teammember in area.
				return FALSE
	return TRUE
