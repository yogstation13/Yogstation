//shadow store datums (upgrades and abilities)
/datum/psi_web
	///Name of the effect
	var/name = "Basic knowledge"
	///Description of the effect
	var/desc = "Basic knowledge of forbidden arts."
	///Fancy description about the effect
	var/lore_description = ""
	///Icon file used for the tgui menu
	var/icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	///Specific icon used for the tgui menu
	var/icon_state = null
	///Cost of to learn this
	var/willpower_cost = 0
	///What specialization can buy this
	var/shadow_flags = NONE
	///what ability is granted if any
	var/list/datum/action/learned_abilities = list()
	///what tab of the antag menu does it fall under
	var/menu_tab
	///The owner of the psi_web datum that effects will be applied to
	var/datum/mind/owner
	///The human mob of darkspawn
	var/mob/living/carbon/human/shadowhuman
	///The antag datum of the owner(used for modifying)
	var/datum/antagonist/darkspawn/darkspawn
	///If it can be bought infinite times for incremental upgrades
	var/infinite = FALSE

///When the button to purchase is clicked
/datum/psi_web/proc/on_purchase(datum/mind/user, silent = FALSE)
	if(!istype(user, /datum/mind))
		return
	owner = user
	if(!owner.current || !ishuman(owner.current))
		to_chat(user, span_warning("You can only research as a human"))
		return
	shadowhuman = owner.current
	darkspawn = owner.has_antag_datum(/datum/antagonist/darkspawn)
	if(!darkspawn)
		CRASH("[owner] tried to gain a psi_web datum despite not being a darkspawn")
	if(darkspawn.willpower < willpower_cost)
		return

	darkspawn.willpower -= willpower_cost
	if(willpower_cost && !silent)
		to_chat(user, span_velvet("You have unlocked [name]"))
	on_gain()
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = new ability(owner)
			action.Grant(shadowhuman)
	return TRUE

///If the purchase goes through, this gets called
/datum/psi_web/proc/on_gain()
	return

/datum/psi_web/proc/on_loss()
	return

/datum/psi_web/proc/remove(refund = FALSE)
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = locate(ability) in owner.current.actions
			if(action)
				if(shadowhuman)
					action.Remove(shadowhuman)
				qdel(action)

	on_loss()

	if(refund && darkspawn)
		darkspawn.willpower += willpower_cost
	
	return QDEL_HINT_QUEUE

/datum/psi_web/Destroy(force, ...)
	remove()
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//---------------------Darkspawn innate Upgrades----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/innate_darkspawn
	name = "darkspawn progression abilities"
	desc = "me no think so good"
	shadow_flags = ALL_DARKSPAWN_CLASSES
	learned_abilities = list(/datum/action/cooldown/spell/sacrament, /datum/action/cooldown/spell/touch/restrain_body, /datum/action/cooldown/spell/touch/devour_will)

////////////////////////////////////////////////////////////////////////////////////
//----------------------Specialization innate Upgrades----------------------------//
////////////////////////////////////////////////////////////////////////////////////
//fighter
/datum/psi_web/fighter
	name = "fighter innate abilities"
	desc = "me no think so good"
	shadow_flags = DARKSPAWN_FIGHTER
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_tendril)

/datum/psi_web/fighter/on_gain()
	darkspawn.brute_mod *= 0.7
	darkspawn.dark_healing += 2 //so they're just a little bit faster at healing since they're gonna take damage the most

/datum/psi_web/fighter/on_loss()
	darkspawn.brute_mod /= 0.7
	darkspawn.dark_healing -= 2

//scout
/datum/psi_web/scout
	name = "scout innate abilities"
	desc = "GO FAST, TOUCH GRASS"
	shadow_flags = DARKSPAWN_SCOUT
	learned_abilities = list(/datum/action/cooldown/spell/toggle/light_eater)

/datum/psi_web/scout/on_gain()
	shadowhuman.LoadComponent(/datum/component/walk/shadow)

/datum/psi_web/scout/on_loss()
	qdel(shadowhuman.GetComponent(/datum/component/walk/shadow))

//warlock
/datum/psi_web/warlock
	name = "warlock innate abilities"
	desc = "apartment \"complex\"... really? I find it quite simple"
	shadow_flags = DARKSPAWN_WARLOCK
	learned_abilities = list(/datum/action/cooldown/spell/touch/thrall_mind, /datum/action/cooldown/spell/release_thrall, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_cam, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye, /datum/action/cooldown/spell/toggle/dark_staff)

/datum/psi_web/warlock/on_gain()
	darkspawn.psi_cap *= 2
	darkspawn.psi_per_second *= 2
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls += 3

/datum/psi_web/warlock/on_loss()
	darkspawn.psi_cap /= 2
	darkspawn.psi_per_second /= 2
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls -= 3

////////////////////////////////////////////////////////////////////////////////////
//-------------------------Helper for ability upgrades----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/ability_upgrade
	name = "Upgrades ability"
	desc = "you shouldn't be seeing this, let a coder or maintainer know."
	var/flag_to_add

/datum/psi_web/ability_upgrade/on_gain()
	if(flag_to_add)
		SEND_SIGNAL(owner, COMSIG_DARKSPAWN_UPGRADE_ABILITY, flag_to_add)

/datum/psi_web/ability_upgrade/on_loss()
	if(flag_to_add)
		SEND_SIGNAL(owner, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, flag_to_add)
