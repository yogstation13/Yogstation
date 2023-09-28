/datum/objective/monsterhunter
	name = "destroymonsters"

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

// GENERATE
/datum/objective/vassal/New()
	update_explanation_text()
	..()

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

//////////////////////////////////////////////////////////////////////////////////////
/// Vassalize someone in charge (Head of Staff + QM)
/datum/objective/vassal/protege

	var/list/heads = list(
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Research Director",
		"Chief Engineer",
		"Chief Medical Officer",
		"Quartermaster",
	)

	var/list/departments = list(
		"Security",
		"Supply",
		"Science",
		"Engineering",
		"Medical",
	)

	var/target_department	// Equals "HEAD" when it's not a department role.
	var/department_string

// GENERATE!
/datum/objective/vassal/protege/New()
	switch(rand(0, 2))
		// Vasssalize Command/QM
		if(0)
			target_amount = 1
			target_department = VASSALIZE_COMMAND
		// Vassalize a certain department
		else
			target_amount = rand(2, 3)
			target_department = pick(departments)
	..()

// EXPLANATION
/datum/objective/vassal/protege/update_explanation_text()
	if(target_department == VASSALIZE_COMMAND)
		explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."
	else
		explanation_text = "Have [target_amount] Vassal[target_amount == 1 ? "" : "s"] in the [target_department] department."

// WIN CONDITIONS?
/datum/objective/vassal/protege/check_completion()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum || !bloodsuckerdatum.vassals.len)
		return FALSE

	// Get list of all jobs that are qualified (for HEAD, this is already done)
	var/list/valid_jobs
	if(target_department == VASSALIZE_COMMAND)
		valid_jobs = heads
	else
		valid_jobs = list()
		var/list/alljobs = subtypesof(/datum/job) // This is just a list of TYPES, not the actual variables!
		for(var/listed_jobs in alljobs)
			var/datum/job/all_jobs = SSjob.GetJobType(listed_jobs)
			if(!istype(all_jobs))
				continue
			// Found a job whose Dept Head matches either list of heads, or this job IS the head. We exclude the QM from this, HoP handles Cargo.
			if((target_department in all_jobs.department_head) || target_department == all_jobs.title)
				valid_jobs += all_jobs.title

	// Check Vassals, and see if they match
	var/objcount = 0
	var/list/counted_roles = list() // So you can't have more than one Captain count.
	for(var/datum/antagonist/vassal/bloodsucker_vassals in bloodsuckerdatum.vassals)
		if(!bloodsucker_vassals || !bloodsucker_vassals.owner)	// Must exist somewhere, and as a vassal.
			continue

		var/this_role = "none"

		// Mind Assigned
		if((bloodsucker_vassals.owner.assigned_role in valid_jobs) && !(bloodsucker_vassals.owner.assigned_role in counted_roles))
			//to_chat(owner, span_userdanger("PROTEGE OBJECTIVE: (MIND ROLE)"))
			this_role = bloodsucker_vassals.owner.assigned_role
		// Mob Assigned
		else if((bloodsucker_vassals.owner.current.job in valid_jobs) && !(bloodsucker_vassals.owner.current.job in counted_roles))
			//to_chat(owner, span_userdanger("PROTEGE OBJECTIVE: (MOB JOB)"))
			this_role = bloodsucker_vassals.owner.current.job
		// PDA Assigned
		else if(bloodsucker_vassals.owner.current && ishuman(bloodsucker_vassals.owner.current))
			var/mob/living/carbon/human/vassal_users = bloodsucker_vassals.owner.current
			var/obj/item/card/id/id_cards = vassal_users.wear_id ? vassal_users.wear_id.GetID() : null
			if(id_cards && (id_cards.assignment in valid_jobs) && !(id_cards.assignment in counted_roles))
				//to_chat(owner, span_userdanger("PROTEGE OBJECTIVE: (GET ID)"))
				this_role = id_cards.assignment

		// NO MATCH
		if(this_role == "none")
			continue

		// SUCCESS!
		objcount++
		if(target_department == VASSALIZE_COMMAND)
			counted_roles += this_role // Add to list so we don't count it again (but only if it's a Head)

	return objcount >= target_amount
	/**
	 * # IMPORTANT NOTE!!
	 *
	 * Look for Job Values on mobs! This is assigned at the start, but COULD be changed via the HoP
	 * ALSO - Search through all jobs (look for prefs earlier that look for all jobs, and search through all jobs to see if their head matches the head listed, or it IS the head)
	 * ALSO - registered_account in _vending.dm for banks, and assigning new ones.
	 */

//////////////////////////////////////////////////////////////////////////////////////
/datum/objective/vassal/target
	var/target_department_type = FALSE

/datum/objective/vassal/target/New()
	var/list/possible_targets = return_possible_targets()
	find_target(possible_targets)
	..()

// EXPLANATION
/datum/objective/vassal/target/update_explanation_text()
	. = ..()
	if(target?.current)
		explanation_text = "Ensure [target.name], the [!target_department_type ? target.assigned_role : target.special_role], is Vassalized via the Persuasion Rack."
	else
		explanation_text = "Free Objective"

/datum/objective/vassal/target/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

// WIN CONDITIONS?
/datum/objective/vassal/target/check_completion()
	if(!target || target.has_antag_datum(/datum/antagonist/vassal))
		return TRUE
	return FALSE
