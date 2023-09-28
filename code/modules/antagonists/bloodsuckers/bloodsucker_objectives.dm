/datum/objective/bloodsucker/monsterhunter
	name = "destroymonsters"

// EXPLANATION
/datum/objective/bloodsucker/monsterhunter/update_explanation_text()
	. = ..()
	explanation_text = "Destroy all monsters on [station_name()]."

// WIN CONDITIONS?
/datum/objective/bloodsucker/monsterhunter/check_completion()
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
