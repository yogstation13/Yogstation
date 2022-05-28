/// From 'Cellular Emporium'... somehow?
/datum/action/bloodsucker/trackvamp
	name = "Track Monster"
	desc = "Take a moment to look for clues of any nearby monsters.<br>These creatures are slippery, and often look like the crew."
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon_state = "power_hunter"
	power_flags = BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = NONE
	cooldown = 30 SECONDS
	bloodcost = 0
	/// Removed, set to TRUE to re-add, either here to be a default function, or in-game through VV for neat Admin stuff -Willard
	var/give_pinpointer = FALSE

/datum/action/bloodsucker/trackvamp/ActivatePower()
	. = ..()
	/// Return text indicating direction
	to_chat(owner, span_notice("You look around, scanning your environment and discerning signs of any filthy, wretched affronts to the natural order..."))
	if(!do_mob(owner, owner, 6 SECONDS))
		to_chat(owner,span_warning("You were interrupted and lost the tracks!"))
		DeactivatePower()
		return
	if(give_pinpointer)
		var/mob/living/user = owner
		user.apply_status_effect(/datum/status_effect/agent_pinpointer/hunter_edition)
	display_proximity()
	DeactivatePower()

/datum/action/bloodsucker/trackvamp/proc/display_proximity()
	/// Pick target
	var/turf/my_loc = get_turf(owner)
	var/closest_dist = 9999
	var/mob/living/closest_monster

	/// Track ALL living Monsters.
	var/list/datum/mind/monsters = list()
	for(var/mob/living/carbon/all_carbons in GLOB.alive_mob_list)
		if(all_carbons == owner) //don't track ourselves!
			continue
		if(!all_carbons.mind)
			continue
		var/datum/mind/carbon_minds = all_carbons.mind
		if(IS_HERETIC(all_carbons) || IS_BLOODSUCKER(all_carbons) || iscultist(all_carbons) || is_servant_of_ratvar(all_carbons) || is_wizard(all_carbons))
			monsters += carbon_minds
		if(carbon_minds.has_antag_datum(/datum/antagonist/changeling))
			monsters += carbon_minds
		if(carbon_minds.has_antag_datum(/datum/antagonist/sinfuldemon))
			monsters += carbon_minds
		if(carbon_minds.has_antag_datum(/datum/antagonist/ashwalker))
			monsters += carbon_minds
		if(carbon_minds.has_antag_datum(/datum/antagonist/vampire)) //yogs, still supporting vampires!
			monsters += carbon_minds

	for(var/datum/mind/monster_minds in monsters)
		if(!monster_minds.current || monster_minds.current == owner) // || !get_turf(M.current) || !get_turf(owner))
			continue
		for(var/antag_datums in monster_minds.antag_datums)
			var/datum/antagonist/antag_datum = antag_datums
			if(!istype(antag_datum))
				continue
			var/their_loc = get_turf(monster_minds.current)
			var/distance = get_dist_euclidian(my_loc, their_loc)
			/// Found One: Closer than previous/max distance
			if(distance < closest_dist && distance <= HUNTER_SCAN_MAX_DISTANCE)
				closest_dist = distance
				closest_monster = monster_minds.current
				/// Stop searching through my antag datums and go to the next guy
				break

	/// Found one!
	if(closest_monster)
		var/distString = closest_dist <= HUNTER_SCAN_MAX_DISTANCE / 2 ? "<b>somewhere nearby!</b>" : "somewhere in the distance."
		to_chat(owner, span_warning("You detect signs of monsters [distString]"))

	/// Will yield a "?"
	else
		to_chat(owner, span_notice("There are no monsters nearby."))
