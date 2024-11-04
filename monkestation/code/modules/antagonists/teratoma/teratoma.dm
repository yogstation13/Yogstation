/datum/team/teratoma
	name = "Teratomas"
	member_name = "teratoma"

/datum/antagonist/teratoma
	name = "\improper Teratoma"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_to_ghosts = TRUE
	var/datum/team/teratoma/team

/datum/antagonist/teratoma/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_UNCONVERTABLE, REF(src))

/datum/antagonist/teratoma/on_removal()
	REMOVE_TRAIT(owner, TRAIT_UNCONVERTABLE, REF(src))
	return ..()

/datum/antagonist/teratoma/greet()
	var/list/parts = list()
	parts += span_big("You are a living teratoma!")
	parts += span_changeling("By all means, you should not exist. <i>Your very existence is a sin against nature itself.</i>")
	parts += span_changeling("You are loyal to <b>nobody</b>, except the forces of chaos itself.")
	parts += span_info("You are able to easily vault tables and ventcrawl, however you cannot use many things like guns, batons, and you are also illiterate and quite fragile.")
	parts += span_hypnophrase("<span style='font-size: 125%'>Spread misery and chaos upon the station.</span>")
	to_chat(owner.current, examine_block(parts.Join("\n")), type = MESSAGE_TYPE_INFO)

/datum/antagonist/teratoma/can_be_owned(datum/mind/new_owner)
	if(!isteratoma(new_owner.current))
		return FALSE
	return ..()

/datum/antagonist/teratoma/create_team(datum/team/teratoma/new_team)
	var/static/datum/team/teratoma/main_teratoma_team
	if(!new_team)
		if(!main_teratoma_team)
			main_teratoma_team = new
			main_teratoma_team.add_objective(new /datum/objective/teratoma)
		new_team = main_teratoma_team
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team
	objectives |= team.objectives

/datum/antagonist/teratoma/get_team()
	return team

/datum/antagonist/teratoma/get_base_preview_icon()
	RETURN_TYPE(/icon)
	var/static/icon/teratoma_icon
	if(!teratoma_icon)
		var/mob/living/carbon/human/species/teratoma/teratoma = new
		teratoma.setDir(SOUTH)
		teratoma_icon = getFlatIcon(teratoma, no_anim = TRUE)
		QDEL_NULL(teratoma)
	return teratoma_icon

/datum/objective/teratoma
	name = "Spread misery and chaos"
	explanation_text = "Spread misery and chaos upon the station."
	completed = TRUE
