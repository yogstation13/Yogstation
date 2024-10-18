/datum/antagonist/heretic
	/// Weakrefs to the minds of monsters have been successfully summoned. Includes ghouls.
	var/list/datum/weakref/monsters_summoned
	/// Lazy assoc list of [weakrefs to minds] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/datum/weakref/current_sac_targets
	/// List of [weakrefs to minds], containing all the minds we've ever had as sacrifice targets. Used for the end-of-round report.
	var/list/datum/weakref/all_sac_targets
	/// Lazy assoc list of [weakrefs to minds] that we've sacrificed. [weakref to mind] = TRUE
	var/list/datum/weakref/completed_sacrifices

/datum/antagonist/heretic/Destroy()
	LAZYNULL(monsters_summoned)
	LAZYNULL(current_sac_targets)
	LAZYNULL(all_sac_targets)
	LAZYNULL(completed_sacrifices)
	return ..()

/**
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob's mind.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(target)
	. = FALSE
	var/datum/mind/target_mind = get_mind(target, include_last = TRUE)
	if(QDELETED(target_mind))
		return FALSE
	var/mob/living/carbon/target_body = target_mind.current
	if(!istype(target_body))
		return FALSE
	var/datum/weakref/target_ref = WEAKREF(target_mind)
	LAZYOR(all_sac_targets, target_ref)
	LAZYSET(current_sac_targets, target_ref, TRUE)
	return TRUE

/**
 * Remove [target] as a sacrifice target for the heretic.
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(target, remove_from_all = FALSE)
	. = FALSE
	var/datum/mind/target_mind = get_mind(target, include_last = TRUE)
	if(!QDELETED(target_mind))
		var/datum/weakref/target_ref = WEAKREF(target_mind)
		LAZYREMOVE(current_sac_targets, target_ref)
		if(remove_from_all)
			LAZYREMOVE(all_sac_targets, target_ref)
		return TRUE

/**
 * Returns a list of minds of valid sacrifice targets from the current living players.
 */
/datum/antagonist/heretic/proc/possible_sacrifice_targets(include_current_targets = TRUE) as /list
	RETURN_TYPE(/list)
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.alive_player_list)
		if(QDELETED(player.mind))
			continue
		var/datum/client_interface/player_client = GET_CLIENT(player)
		if(QDELETED(player_client) || player_client.is_afk())
			continue
		var/datum/mind/possible_target = player.mind
		if(possible_target == owner)
			continue
		if(possible_target.get_effective_opt_in_level() < OPT_IN_YES_KILL)
			continue
		if(!(possible_target.assigned_role?.job_flags & JOB_CREW_MEMBER))
			continue
		var/datum/weakref/target_weakref = WEAKREF(possible_target)
		if(!include_current_targets && LAZYACCESS(current_sac_targets, target_weakref))
			continue
		if(LAZYACCESS(completed_sacrifices, target_weakref))
			continue
		var/turf/player_loc = get_turf(player)
		if(!is_station_level(player_loc?.z))
			continue
		if(player.stat >= SOFT_CRIT)
			continue
		. += possible_target

/**
 * Check to see if the given mob can be sacrificed.
 */
/datum/antagonist/heretic/proc/can_sacrifice(target)
	. = FALSE
	var/datum/mind/target_mind = get_mind(target, include_last = TRUE)
	if(!istype(target_mind))
		return
	var/datum/weakref/mind_weakref = WEAKREF(target_mind)
	if(LAZYACCESS(current_sac_targets, mind_weakref))
		return TRUE
	if(LAZYACCESS(completed_sacrifices, mind_weakref))
		return FALSE
	// You can ALWAYS sacrifice heads of staff if you need to do so.
	var/datum/objective/major_sacrifice/major_sacc_objective = locate() in objectives
	if(major_sacc_objective && !major_sacc_objective.check_completion() && (target_mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
		return TRUE

/datum/antagonist/heretic/proc/get_current_target_bodies() as /list
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/weakref/mind_ref as anything in current_sac_targets)
		var/datum/mind/target_mind = mind_ref?.resolve()
		if(QDELETED(target_mind))
			continue
		if(ishuman(target_mind.current))
			. += target_mind.current

/datum/antagonist/heretic/proc/roundend_sac_list()
	. = @"[ ERROR, PLEASE REPORT TO GITHUB! ]"
	var/list/names = list()
	for(var/datum/weakref/target_ref as anything in all_sac_targets)
		var/datum/mind/target = target_ref?.resolve()
		if(QDELETED(target))
			continue
		names += LAZYACCESS(completed_sacrifices, target_ref) ? "<b>[target.name]</b>" : "[target.name]"
	return english_list(names, nothing_text = "No one")

/datum/objective/heretic_summon/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	return ..() || (LAZYLEN(heretic_datum?.monsters_summoned) >= target_amount)
