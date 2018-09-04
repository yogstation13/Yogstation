/datum/antagonist/spythief
	name = "Spy Thief"
	roundend_category = "spy thieves"
	antagpanel_category = "Spy Thief"
	job_rank = ROLE_SPY_THIEF
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_SPY_THIEF
	var/employer = "The Syndicate"
	can_hijack = HIJACK_HIJACKER
	var/obj/item/uplink_holder

/datum/antagonist/spythief/on_gain()
	SSticker.mode.spythieves += owner
	owner.special_role = special_role
	equip_spy()
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

/datum/antagonist/spythief/proc/equip_spy()
	uplink_holder = owner.equip_traitor(uplink_owner = src)
	var/list/slots = list (
			"backpack" = SLOT_IN_BACKPACK,
			"left pocket" = SLOT_L_STORE,
			"right pocket" = SLOT_R_STORE
		)
	var/mob/living/carbon/human/H = owner.current
	var/obj/item/telebeacon/T = new(H)
	var/where = H.equip_in_one_of_slots(T, slots)
	if (!where)
		to_chat(H, "The Syndicate were unfortunately unable to get you a telebeacon.")
	else
		to_chat(H, "The telebeacon in your [where] will help you complete bounties for The Syndicate.")