//Shadowling
/datum/admins/proc/makeShadowling()
	var/datum/game_mode/shadowling/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(ROLE_DARKSPAWN in applicant.client.prefs.be_special)
			if(!applicant.stat || !applicant.mind)
				continue
			if(applicant.mind.special_role)
				continue
			if(is_banned_from(applicant.ckey, "shadowling") || is_banned_from(applicant.ckey, "Syndicate"))
				continue
			if(!temp.age_check(applicant.client) || (applicant.job in temp.restricted_jobs))
				continue
			if(is_shadow_or_thrall(applicant))
				continue
			candidates += applicant
	if(candidates.len)
		H = pick(candidates)
		H.add_sling()
		return TRUE
	return FALSE

//Darkspawn
/datum/admins/proc/makeDarkspawn()
	var/datum/game_mode/darkspawn/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(ROLE_SHADOWLING in applicant.client.prefs.be_special)
			if(!applicant.stat || !applicant.mind)
				continue
			if(applicant.mind.special_role)
				continue
			if(is_banned_from(applicant.ckey, "darkspawn") || is_banned_from(applicant.ckey, "Syndicate"))
				continue
			if(!temp.age_check(applicant.client) || (applicant.job in temp.restricted_jobs))
				continue
			if(is_darkspawn_or_veil(applicant))
				continue
			candidates += applicant
	if(candidates.len)
		H = pick(candidates)
		if(H.add_darkspawn())
			message_admins("[key_name(usr)] made [ADMIN_LOOKUPFLW(H)] a darkspawn!")
			log_admins("[key_name(usr)] made [ADMIN_LOOKUPFLW(H)] a darkspawn!")
			return TRUE
	return FALSE

/datum/admins/proc/makeVampire()
	var/datum/game_mode/vampire/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if((ROLE_VAMPIRE in applicant.client.prefs.be_special) && !applicant.stat && applicant.mind && !applicant.mind.special_role)
			if(!is_banned_from(applicant.ckey, "vampire") && !is_banned_from(applicant.ckey, "Syndicate"))
				if(temp.age_check(applicant.client) && !(applicant.job in temp.restricted_jobs) && !is_vampire(applicant))
					candidates += applicant
	if(LAZYLEN(candidates))
		H = pick(candidates)
		add_vampire(H)
		return TRUE
	return FALSE

/client/proc/subtlemessage_faction() // Thanks GenericDM very cool
	set name = "SM to Faction"
	set desc = "Allows you to send a mass SM to every member of a particular faction or antagonist type."
	set category = "Admin.Player Interaction"

	var/list/choices = list() //This list includes both factions in the "mob.factions" sense
	// and also factions as in, types of /datum/antagonist/

	//First, lets generate a list of possible factions for this admin to choose from
	for(var/mob/living/player in GLOB.player_list)
		if(player.faction)
			for(var/i in player.faction)
				choices |= i
		var/list/antagstuffs = player.mind.antag_datums
		if(antagstuffs && antagstuffs.len)
			for(var/antagdatum in antagstuffs)
				choices |= "[antagdatum]"
	message_admins("[key_name_admin(src)] has started a SM to Faction.")
	var/chosen = input("Select faction or antag type you would like to contact:","SM to Faction") in choices
	if(!chosen)
		message_admins("[key_name_admin(src)] has decided not to SM to Faction.")
		return
	message_admins("[key_name_admin(src)] has chosen SM to Faction: [chosen].")
	var/msg = input("Message:", text("Subtle PM to [chosen]")) as text|null
	if(!msg)
		message_admins("[key_name_admin(src)] has decided not to SM to Faction.")
		return
	log_admin("SubtleMessage Faction: [key_name_admin(src)] -> Faction [chosen] : [msg]")
	message_admins("SubtleMessage Faction: [key_name_admin(src)] -> Faction [chosen] : [msg]")
	var/text // The real HTML-and-text we will send to the SM'd.
	if(chosen == "Clock Cultist")
		text = "[span_large_brass("You hear a booming voice in your head... ")][span_heavy_brass("[msg]")]"
	else if(chosen == "Cultist")
		text = "[span_cultlarge("You hear a booming voice in your head... ")][span_cult("[msg]")]"
	else if(chosen == "swarmer")
		text = "<i>You are receiving a message from the masters... <b>[msg]</i></b>"
	else
		text = "<i>You hear a booming voice in your head... <b>[msg]</b></i>"

	for(var/mob/living/player in GLOB.player_list)
		var/done = FALSE
		if(player.faction)
			for(var/i in player.faction)
				if(i == chosen)
					to_chat(player,text)
					done = TRUE
					break
		if(done)
			continue
		var/list/antagstuffs = player.mind.antag_datums
		if(antagstuffs && antagstuffs.len)
			for(var/antagdatum in antagstuffs)
				if("[antagdatum]" == chosen)
					to_chat(player,text)
					break

/datum/admins/proc/makeInfiltratorTeam()
	var/datum/game_mode/infiltration/temp = new
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for a infiltration team being sent in?", ROLE_INFILTRATOR, temp)
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null

	if(LAZYLEN(candidates))
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle_inplace(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = j
				candidates.Remove(theghost)
				chosen += theghost
				agentcount++
				break
		//Making sure we have atleast 3 Nuke agents, because less than that is kinda bad
		if(agentcount < 3)
			return FALSE

		//Let's find the spawn locations
		var/datum/team/infiltrator/TI = new/datum/team/infiltrator/
		for(var/mob/c in chosen)
			var/mob/living/carbon/human/new_character=makeBody(c)
			new_character.mind.add_antag_datum(/datum/antagonist/infiltrator, TI)
		TI.update_objectives()
		return TRUE
	return FALSE
