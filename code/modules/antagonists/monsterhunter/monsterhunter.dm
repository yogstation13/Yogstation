/datum/antagonist/monsterhunter
	name = "\improper Monster Hunter"
	roundend_category = "Monster Hunters"
	antagpanel_category = "Monster Hunter"
	job_rank = ROLE_MONSTERHUNTER
	antag_hud_name = "monsterhunter"
	preview_outfit = /datum/outfit/monsterhunter
	var/list/datum/action/powers = list()
	var/datum/martial_art/hunterfu/my_kungfu = new
	var/give_objectives = TRUE
	var/datum/action/cooldown/spell/trackmonster/tracking
	var/datum/action/cooldown/spell/toggle/flow/fortitude
	var/list/passive_traits = list(TRAIT_NOSOFTCRIT, TRAIT_NOCRITDAMAGE)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Gain and application--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/monsterhunter/on_gain()
	//Give Monster Hunter powers
	tracking = new(owner)
	tracking.Grant(owner.current)
	fortitude = new(owner)
	fortitude.Grant(owner.current)

	if(give_objectives)
		//Give Hunter Objective
		var/datum/objective/monsterhunter/monsterhunter_objective = new
		monsterhunter_objective.owner = owner
		objectives += monsterhunter_objective
		//Give Theft Objective
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		objectives += steal_objective

	return ..()

/datum/antagonist/monsterhunter/apply_innate_effects(mob/living/mob_override)
	.  = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.add_traits(passive_traits, type)
	owner.unconvertable = TRUE
	my_kungfu.teach(current_mob, make_temporary = FALSE)

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Loss and removal---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/monsterhunter/on_removal()
	//Remove Monster Hunter powers
	tracking.Remove(owner.current)
	qdel(tracking)
	fortitude.Remove(owner.current)
	qdel(fortitude)
	
	to_chat(owner.current, span_userdanger("Your hunt has ended: You enter retirement once again, and are no longer a Monster Hunter."))
	return ..()

/datum/antagonist/monsterhunter/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_traits(passive_traits, type)
	owner.unconvertable = FALSE
	if(my_kungfu)
		my_kungfu.remove(current_mob)

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

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Admin tools-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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


////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Objective-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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
		if(IS_MONSTERHUNTER_TARGET(brain.current))
			monsters += brain
	return completed || !monsters.len

////////////////////////////////////////////////////////////////////////////////////
//------------------------------------Outfit--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/outfit/monsterhunter
	name = "Monster Hunter"

	head = /obj/item/clothing/head/helmet/chaplain/witchunter_hat
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	suit = /obj/item/clothing/suit/armor/riot/chaplain/witchhunter
	l_hand = /obj/item/reagent_containers/food/drinks/bottle/holywater
	r_hand = /obj/item/nullrod/whip
