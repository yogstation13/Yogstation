#define HUNTER_SCAN_MIN_DISTANCE 8
#define HUNTER_SCAN_MAX_DISTANCE 15
/// 5s update time
#define HUNTER_SCAN_PING_TIME 20

/datum/antagonist/monsterhunter
	name = "\improper Monster Hunter"
	roundend_category = "Monster Hunters"
	antagpanel_category = "Monster Hunter"
	job_rank = ROLE_MONSTERHUNTER
	var/list/datum/action/powers = list()
	var/datum/martial_art/hunterfu/my_kungfu = new
	var/give_objectives = TRUE
	var/datum/action/bloodsucker/trackvamp = new /datum/action/bloodsucker/trackvamp()
	var/datum/action/bloodsucker/fortitude = new /datum/action/bloodsucker/fortitude/hunter()

/datum/antagonist/monsterhunter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	ADD_TRAIT(current_mob, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	ADD_TRAIT(current_mob, TRAIT_NOCRITDAMAGE, BLOODSUCKER_TRAIT)
	owner.unconvertable = TRUE
	my_kungfu.teach(current_mob, make_temporary = FALSE)

/datum/antagonist/monsterhunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	REMOVE_TRAIT(current_mob, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(current_mob, TRAIT_NOCRITDAMAGE, BLOODSUCKER_TRAIT)
	owner.unconvertable = FALSE
	if(my_kungfu)
		my_kungfu.remove(current_mob)


/datum/antagonist/monsterhunter/on_gain()
	//Give Monster Hunter powers
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_MHUNTER]
	trackvamp.Grant(owner.current)
	fortitude.Grant(owner.current)
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "monsterhunter")
	if(give_objectives)
		//Give Hunter Objective
		var/datum/objective/bloodsucker/monsterhunter/monsterhunter_objective = new
		monsterhunter_objective.owner = owner
		objectives += monsterhunter_objective
		//Give Theft Objective
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		objectives += steal_objective

	//Teach Stake crafting
	owner.teach_crafting_recipe(/datum/crafting_recipe/hardened_stake)
	owner.teach_crafting_recipe(/datum/crafting_recipe/silver_stake)
	return ..()

/datum/antagonist/monsterhunter/on_removal()
	//Remove Monster Hunter powers
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_MHUNTER]
	trackvamp.Remove(owner.current)
	fortitude.Remove(owner.current)
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
	to_chat(owner.current, span_userdanger("Your hunt has ended: You enter retirement once again, and are no longer a Monster Hunter."))
	return ..()

/datum/antagonist/monsterhunter/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

	
/// Mind version
/datum/mind/proc/make_monsterhunter()
	var/datum/antagonist/monsterhunter/monsterhunterdatum = has_antag_datum(/datum/antagonist/monsterhunter)
	if(!monsterhunterdatum)
		monsterhunterdatum = add_antag_datum(/datum/antagonist/monsterhunter)
		special_role = ROLE_MONSTERHUNTER
	return monsterhunterdatum

/datum/mind/proc/remove_monsterhunter()
	var/datum/antagonist/monsterhunter/monsterhunterdatum = has_antag_datum(/datum/antagonist/monsterhunter)
	if(monsterhunterdatum)
		remove_antag_datum(/datum/antagonist/monsterhunter)
		special_role = null

/// Called when using admin tools to give antag status
/datum/antagonist/monsterhunter/admin_add(datum/mind/new_owner, mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	new_owner.add_antag_datum(src)

/// Called when removing antagonist using admin tools
/datum/antagonist/monsterhunter/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [key_name(owner)].")
	on_removal()

/datum/antagonist/monsterhunter/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/monsterhunter/proc/remove_objectives(datum/objective/removed_objective)
	objectives -= removed_objective

/datum/antagonist/monsterhunter/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("After witnessing recent events on the station, we return to your old profession, we are a Monster Hunter!"))
	to_chat(owner.current, span_announce("While we can kill anyone in our way to destroy the monsters lurking around, <b>causing property damage is unacceptable</b>."))
	to_chat(owner.current, span_announce("However, security WILL detain us if they discover our mission."))
	to_chat(owner.current, span_announce("In exchange for our services, it shouldn't matter if a few items are gone missing for our... personal collection."))
	owner.current.playsound_local(null, 'sound/effects/his_grace_ascend.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

//////////////////////////////////////////////////////////////////////////
//			Monster Hunter Pinpointer
//////////////////////////////////////////////////////////////////////////

/// TAKEN FROM: /datum/action/changeling/pheromone_receptors    // pheromone_receptors.dm    for a version of tracking that Changelings have!
/datum/status_effect/agent_pinpointer/hunter_edition
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/hunter_edition
	minimum_range = HUNTER_SCAN_MIN_DISTANCE
	tick_interval = HUNTER_SCAN_PING_TIME
	duration = 10 SECONDS
	range_fuzz_factor = 5 //PINPOINTER_EXTRA_RANDOM_RANGE

/obj/screen/alert/status_effect/agent_pinpointer/hunter_edition
	name = "Monster Tracking"
	desc = "You always know where the hellspawn are."

/datum/status_effect/agent_pinpointer/hunter_edition/scan_for_target()
	var/turf/my_loc = get_turf(owner)

	var/list/mob/living/carbon/monsters = list()
	for(var/datum/antagonist/monster in GLOB.antagonists)
		var/datum/mind/brain = monster.owner
		if(brain == owner || !brain)
			continue
		if(IS_HERETIC(brain.current) || IS_BLOODSUCKER(brain.current) || iscultist(brain.current) || is_servant_of_ratvar(brain.current) || is_wizard(brain.current))
			monsters += brain
		if(brain.has_antag_datum(/datum/antagonist/changeling))
			monsters += brain
		if(brain.has_antag_datum(/datum/antagonist/ashwalker))
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