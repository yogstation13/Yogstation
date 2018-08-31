/datum/antagonist/spythief
	name = "Spy Thief"
	roundend_category = "spy thieves"
	antagpanel_category = "Spy Thief"
	job_rank = ROLE_SPY_THIEF
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_SPY_THIEF
	var/employer = "The Syndicate"
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/spythief/on_gain()
	SSticker.mode.spythieves += owner
	owner.special_role = special_role
	..()

/datum/antagonist/spythief/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/spy_mob = owner.current
		if(spy_mob && istype(spy_mob))
			if(!silent)
				to_chat(spy_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			spy_mob.dna.remove_mutation(CLOWNMUT)

/datum/antagonist/spythief/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/spy_mob = owner.current
		if(spy_mob && istype(spy_mob))
			spy_mob.dna.add_mutation(CLOWNMUT)

/datum/antagonist/spythief/on_removal()
	SSticker.mode.spythieves -= owner
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()