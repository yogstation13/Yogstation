/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	job_rank = ROLE_NIGHTMARE
	count_towards_antag_cap = TRUE

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/nightmare/apply_innate_effects(mob/living/mob_override)
	if(!ishuman(mob_override))
		return
	var/mob/living/carbon/human/antag = mob_override
	antag.set_species(/datum/species/shadow/nightmare)

/datum/antagonist/nightmare/greet()
	owner.announce_objectives()
	playsound(owner.current, 'sound/magic/ethereal_exit.ogg', 50, TRUE)

/datum/antagonist/nightmare/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/nightmaredummy = new
	nightmaredummy.set_species(/datum/species/shadow/nightmare)
	var/icon/nightmare_icon = render_preview_outfit(null, nightmaredummy)
	qdel(nightmaredummy)

	return finish_preview_icon(nightmare_icon)

/datum/antagonist/nightmare/proc/forge_objectives()
	var/datum/objective/new_objective = new
	new_objective.owner = owner
	new_objective.completed = TRUE
	objectives += new_objective
	new_objective.explanation_text = "This station is an insult to the void. Return it to darkness."
	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival // just dont die doing it
