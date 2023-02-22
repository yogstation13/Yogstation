#define MIN_POWER_DRAIN 25000000
#define MAX_POWER_DRAIN 100000000

GLOBAL_LIST_INIT(infiltrator_kidnap_areas, typecacheof(list(/area/shuttle/yogs/stealthcruiser, /area/yogs/infiltrator_base)))

/datum/objective/infiltrator
	explanation_text = "Generic Infiltrator Objective!"
	martyr_compatible = FALSE
	var/item_type

/datum/objective/infiltrator/New()
	..()
	if(item_type)
		for(var/turf/T in GLOB.infiltrator_objective_items)
			if(!(item_type in T.contents))
				new item_type(T)

/datum/objective/infiltrator/proc/is_possible()
	return TRUE

/datum/objective/infiltrator/exploit
	explanation_text = "Ensure there is at least 1 hijacked AI."
	item_type = /obj/item/ai_hijack_device


/datum/objective/infiltrator/exploit/find_target(dupe_search_range, blacklist)
	var/list/possible_targets = active_ais(TRUE)
	for (var/mob/living/silicon/ai/AI in possible_targets)
		if (AI.mind.quiet_round)
			possible_targets -= AI
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/infiltrator/exploit/is_possible()
	var/list/possible_targets = active_ais(TRUE)
	for (var/mob/living/silicon/ai/AI in possible_targets)
		if (AI.mind.quiet_round)
			possible_targets -= AI
	return LAZYLEN(possible_targets)

/datum/objective/infiltrator/exploit/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Hijack [station_name()]'s AI unit, [target.name]."
	else
		explanation_text = "Ensure there is at least 1 hijacked AI on [station_name()]."

/datum/objective/infiltrator/exploit/check_completion()
	if(!target)
		return LAZYLEN(get_antag_minds(/datum/antagonist/hijacked_ai))
	if(istype(target, /datum/mind))
		var/datum/mind/A = target
		return A && A.has_antag_datum(/datum/antagonist/hijacked_ai)
	return FALSE


/datum/objective/infiltrator/power
	explanation_text = "Drain power from the station with a power sink."

/datum/objective/infiltrator/power/New()
	target_amount = rand(MIN_POWER_DRAIN, MAX_POWER_DRAIN) //I don't do this in find_target(), because that is done AFTER New().
	for(var/turf/T in GLOB.infiltrator_objective_items)
		if(!(item_type in T.contents))
			var/obj/item/powersink/infiltrator/PS = new(T)
			PS.target = target_amount
	update_explanation_text()

/datum/objective/infiltrator/power/update_explanation_text()
	..()
	if(target_amount)
		explanation_text = "Drain [DisplayPower(target_amount)] from [station_name()]'s powernet with a special transmitter powersink. You do not need to bring the powersink back once the objective is complete."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/power/check_completion()
	return !target_amount || (GLOB.powersink_transmitted >= target_amount)


/datum/objective/infiltrator/kidnap
	explanation_text = "You were supposed to kidnap someone, but we couldn't find anyone to kidnap!"

/datum/objective/infiltrator/kidnap/proc/potential_targets()
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(!M || !considered_alive(M) || considered_afk(M) || !M.current || !M.current.client || !ishuman(M.current) || M.quiet_round)
			continue
		if (M.has_antag_datum(/datum/antagonist/infiltrator) || M.has_antag_datum(/datum/antagonist/traitor) || M.has_antag_datum(/datum/antagonist/nukeop))
			continue
		if(M.assigned_role in GLOB.command_positions)
			possible_targets[M] = 25
		else if(M.assigned_role in GLOB.security_positions)
			possible_targets[M] = 5
		else
			possible_targets[M] = 1
	return possible_targets

/datum/objective/infiltrator/kidnap/is_possible()
	return LAZYLEN(potential_targets())

/datum/objective/infiltrator/kidnap/find_target(dupe_search_range, blacklist)
	target = pickweight(potential_targets())
	update_explanation_text()
	return target

/datum/objective/infiltrator/kidnap/update_explanation_text()
	if(target && target.current)
		explanation_text = "Kidnap [target.name], the [target.assigned_role], and hold [target.current.p_them()] on the shuttle or base."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/kidnap/check_completion()
	var/target_area = get_area(target.current)
	return QDELETED(target) || (target.current && (!target.current.ckey || target.current.suiciding)) || (considered_alive(target) && is_type_in_typecache(target_area, GLOB.infiltrator_kidnap_areas))
