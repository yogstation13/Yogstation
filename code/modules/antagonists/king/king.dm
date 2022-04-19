#define MARTYR_OBJECTIVE 2
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
	var/list/obj/structure/flag/flags_owned = list()


/datum/antagonist/king/apply_innate_effects(mob/living/mob_override)
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/kingo = owner.current
		if(kingo && istype(kingo))
			if(!silent)
				to_chat(kingo, "Your will to rule allows you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			kingo.dna.remove_mutation(CLOWNMUT)
	var/mob/living/carbon/human/user = owner
	if(!(user.dna.species == /datum/species/human))
		user.grant_language(/datum/language/english) //Yes.

/datum/antagonist/king/remove_innate_effects(mob/living/mob_override)
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/kingo = owner.current
		if(kingo && istype(kingo))
			kingo.dna.add_mutation(CLOWNMUT)
	var/mob/living/carbon/human/user = owner
	if(!(user.dna.species == /datum/species/human))
		user.grant_language(/datum/language/english) //Yes.

/datum/antagonist/king/on_gain()
	forge_king_objectives()
	update_king_icons_added(owner.current)

/datum/antagonist/king/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("You are the King!"))
	owner.announce_objectives()

/datum/antagonist/king/farewell()
	to_chat(owner.current, span_userdanger("<FONT size = 3>Suddenly, you understand that all this time you were just mentally ill. You do not longer consider yourself as a king.</FONT>"))

//Procs
/datum/antagonist/king/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/king/proc/remove_objectives(datum/objective/removed_objective)
	objectives -= removed_objective

/datum/antagonist/king/proc/forge_king_objectives()   //Many shitcode
	var/list/possible_objectives = list(/datum/objective/assassinate/kingtoking, /datum/objective/leadership, /datum/objective/royalguard, /datum/objective/empire, /datum/objective/assassinate/head)
	var/list/possible_roundend = list(/datum/objective/hijack/king, /datum/objective/survive, /datum/objective/escape)
	var/datum/objective/roundend_obj = /datum/objective/hijack/king
	var/rolledobjective
	var/list/rolled_objectives = list()
	if(rand(1,5) == MARTYR_OBJECTIVE)
		roundend_obj = /datum/objective/martyr
		for(var/datum/objective/O in possible_objectives)
			if(O.martyr_compatible == 0)
				possible_objectives -= O
	else roundend_obj = pick(possible_roundend)
	rolledobjective = pick(possible_objectives)
	possible_objectives -= rolledobjective
	objectives += rolledobjective
	rolledobjective = pick(possible_objectives)
	possible_objectives -= rolledobjective
	objectives += rolledobjective
	for(var/datum/objective/obj in rolled_objectives)
		obj.owner = owner
		objectives += obj
	roundend_obj.owner = owner
	objectives += roundend_obj



/datum/mind/proc/can_make_king(datum/mind/convertee, datum/mind/converter)
	var/mob/living/carbon/human/user = convertee.current
	if(converter)
		message_admins("[convertee] has become a King, and was created by [converter].")
		log_admin("[convertee] has become a King, and was created by [converter].")
	return TRUE

/datum/mind/proc/make_king(datum/mind/king)
	if(!can_make_king(king))
		return FALSE
	add_antag_datum(/datum/antagonist/king)
	return TRUE

/datum/mind/proc/remove_king()
	var/datum/antagonist/king/removed_king = has_antag_datum(/datum/antagonist/king)
	if(removed_king)
		remove_antag_datum(/datum/antagonist/king)
		special_role = null

/**
 * # HUD
 */
/datum/antagonist/king/proc/update_king_icons_added(datum/mind/m)
	var/datum/atom_hud/antag/kinghud = GLOB.huds[ANTAG_HUD_KING]
	kinghud.join_hud(owner.current)
	set_antag_hud(owner.current, "king")

/datum/antagonist/king/proc/update_king_icons_removed(datum/mind/m)
	var/datum/atom_hud/antag/kinghud = GLOB.huds[ANTAG_HUD_KING]
	kinghud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)