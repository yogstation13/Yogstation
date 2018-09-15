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
		if(ROLE_SHADOWLING in applicant.client.prefs.be_special)
			if(!applicant.stat || !applicant.mind)
				continue
			if(applicant.mind.special_role)
				continue
			if(jobban_isbanned(applicant, "shadowling") || jobban_isbanned(applicant, "Syndicate"))
				continue
			if(!temp.age_check(applicant.client) || applicant.job in temp.restricted_jobs)
				continue
			if(is_shadow_or_thrall(applicant))
				continue
			candidates += applicant
	if(candidates.len)
		H = pick(candidates)
		H.add_sling()
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
			if(!jobban_isbanned(applicant, "vampire") && !jobban_isbanned(applicant, "Syndicate"))
				if(temp.age_check(applicant.client) && !(applicant.job in temp.restricted_jobs) && !is_vampire(applicant))
					candidates += applicant
	if(LAZYLEN(candidates))
		H = pick(candidates)
		add_vampire(H)
		return TRUE
	return FALSE