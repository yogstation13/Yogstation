#define HUNTER_SCAN_MIN_DISTANCE 8
#define HUNTER_SCAN_MAX_DISTANCE 15
/// 5s update time
#define HUNTER_SCAN_PING_TIME 20

/datum/action/cooldown/spell/trackmonster
	name = "Track Monster"
	desc = "Take a moment to look for clues of any nearby monsters.<br>These creatures are slippery, and often look like the crew."
	background_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon_state = "power_hunter"
	spell_requirements = null
	cooldown_time = 30 SECONDS
	/// Removed, set to TRUE to re-add, either here to be a default function, or in-game through VV for neat Admin stuff -Willard
	var/give_pinpointer = FALSE

/datum/action/cooldown/spell/trackmonster/before_cast(atom/cast_on)
	to_chat(owner, span_notice("You look around, scanning your environment and discerning signs of any filthy, wretched affronts to the natural order..."))
	if(!do_after(owner, 6 SECONDS))
		to_chat(owner,span_warning("You were interrupted and lost the tracks!"))
		return SPELL_CANCEL_CAST
	return ..()
	
/datum/action/cooldown/spell/trackmonster/cast()
	. = ..()
	/// Return text indicating direction
	display_proximity()
	if(give_pinpointer)
		var/mob/living/user = owner
		user.apply_status_effect(/datum/status_effect/agent_pinpointer/hunter_edition)

/datum/action/cooldown/spell/trackmonster/proc/display_proximity()
	/// Pick target
	var/turf/my_loc = get_turf(owner)
	var/closest_dist = 9999
	var/mob/living/closest_monster

	/// Track ALL living Monsters.
	var/list/datum/mind/monsters = list()
	for(var/mob/living/carbon/all_carbons in GLOB.alive_mob_list)
		if(all_carbons == owner) //don't track ourselves!
			continue
		if(IS_MONSTERHUNTER_TARGET(all_carbons))
			monsters += all_carbons

	for(var/datum/mind/monster_minds in monsters)
		if(!monster_minds.current || monster_minds.current == owner)
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

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Monster Hunter Pinpointer---------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/status_effect/agent_pinpointer/hunter_edition
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/hunter_edition
	minimum_range = HUNTER_SCAN_MIN_DISTANCE
	tick_interval = HUNTER_SCAN_PING_TIME
	duration = 10 SECONDS
	range_fuzz_factor = 5 //PINPOINTER_EXTRA_RANDOM_RANGE

/atom/movable/screen/alert/status_effect/agent_pinpointer/hunter_edition
	name = "Monster Tracking"
	desc = "You always know where the hellspawn are."

/datum/status_effect/agent_pinpointer/hunter_edition/scan_for_target()
	var/turf/my_loc = get_turf(owner)

	var/list/mob/living/carbon/monsters = list()
	for(var/datum/antagonist/monster in GLOB.antagonists)
		var/datum/mind/brain = monster.owner
		if(brain == owner || !brain)
			continue
		if(IS_MONSTERHUNTER_TARGET(brain.current))
			monsters += brain

	if(monsters.len)
		/// Point at a 'random' monster, biasing heavily towards closer ones.
		scan_target = pickweight(monsters)
		to_chat(owner, span_warning("You detect signs of monsters to the <b>[dir2text(get_dir(my_loc,get_turf(scan_target)))]!</b>"))
	else
		scan_target = null

/datum/status_effect/agent_pinpointer/hunter_edition/Destroy()
	if(scan_target)
		to_chat(owner, span_notice("You've lost the trail."))
	. = ..()
