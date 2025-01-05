/datum/objective/monsterhunter
	name = "destroymonsters"
	explanation_text = "Destroy all monsters on ."

/datum/objective/monsterhunter/New()
	update_explanation_text()
	..()

// EXPLANATION
/datum/objective/monsterhunter/update_explanation_text()
	. = ..()
	explanation_text = "Destroy all monsters on [station_name()]."

// WIN CONDITIONS?
/datum/objective/monsterhunter/check_completion()
	var/list/datum/mind/monsters = list()
	for(var/datum/antagonist/monster in GLOB.antagonists)
		var/datum/mind/brain = monster.owner
		if(!brain || brain == owner)
			continue
		if(!brain.current || brain.current.stat == DEAD)
			continue
		if(IS_HERETIC(brain.current) || IS_BLOODSUCKER(brain.current) || iscultist(brain.current) || is_servant_of_ratvar(brain.current) || is_wizard(brain.current))
			monsters += brain
		if(brain.has_antag_datum(/datum/antagonist/changeling))
			monsters += brain
	return completed || !monsters.len


//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/survive/bloodsucker
	name = "bloodsuckersurvive"
	explanation_text = "Survive the entire shift without succumbing to Final Death."

//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker_lair
	name = "claim lair"
	explanation_text = "Create a lair by claiming a coffin, and protect it until the end of the shift."
	martyr_compatible = TRUE

// WIN CONDITIONS?
/datum/objective/bloodsucker_lair/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.coffin && bloodsuckerdatum.bloodsucker_lair_area)
		return TRUE
	return FALSE


//////////////////////////////////////////////////////////////////////////////////////
/datum/objective/vassal
	name = "vassalization"
	martyr_compatible = TRUE
	var/target_department_type = FALSE

/// Look at all crew members, and for/loop through.
/datum/objective/vassal/proc/return_possible_targets()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD)
			// Check Two: Am Bloodsucker?
			if(IS_BLOODSUCKER(possible_target.current))
				continue
			possible_targets += possible_target

	return possible_targets

	#define VASSALIZE_COMMAND "command_vassalization"

// GENERATE
/datum/objective/vassal/New()
	var/list/possible_targets = return_possible_targets()
	find_target(possible_targets)
	update_explanation_text()
	..()

// EXPLANATION
/datum/objective/vassal/update_explanation_text()
	. = ..()
	if(target?.current)
		explanation_text = "Ensure [target.name], the [!target_department_type ? target.assigned_role : target.special_role], is Vassalized via the Persuasion Rack."
	else
		explanation_text = "Free Objective"

/datum/objective/vassal/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

// WIN CONDITIONS?
/datum/objective/vassal/check_completion()
	if(!target || target.has_antag_datum(/datum/antagonist/vassal))
		return TRUE
	return FALSE
