/datum/antagonist/king
	name = "\improper King"
	show_in_antagpanel = TRUE
	roundend_category = "kings"
	antagpanel_category = "King"
	job_rank = ROLE_KING
	show_name_in_check_antagonists = TRUE
	can_coexist_with_others = FALSE
	can_hijack = HIJACK_HIJACKER
	show_to_ghosts = TRUE
	var/list/datum/antagonist/servant/servants = list()


/datum/antagonist/king/apply_innate_effects(mob/living/mob_override)
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/kingo = owner.current
		if(kingo && istype(kingo))
			if(!silent)
				to_chat(kingo, "Your will to rule allows you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			kingo.dna.remove_mutation(CLOWNMUT)

/datum/antagonist/king/remove_innate_effects(mob/living/mob_override)
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/kingo = owner.current
		if(kingo && istype(kingo))
			kingo.dna.add_mutation(CLOWNMUT)

/datum/antagonist/king/on_gain()
	forge_king_objectives()
	update_king_icons_added(owner.current)
