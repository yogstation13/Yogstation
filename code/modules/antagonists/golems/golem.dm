/datum/antagonist/golem
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	var/old_species
	var/golem_species
	var/antag_hud
	var/antag_hud_name
	var/removing = FALSE //whether we're already in the process of removing this antag datum (needed for remove_innate_effects() on admin_remove())

/datum/antagonist/golem/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.current.set_species(golem_species)
	.=..()

/datum/antagonist/golem/admin_remove(mob/admin)
	removing = TRUE
	owner.current.set_species(/datum/species/golem/adamantine)
	.=..()

/datum/antagonist/golem/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_icons(M, "join")

/datum/antagonist/golem/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_icons(M, "leave")

/datum/antagonist/golem/proc/update_icons(var/mob/living/carbon/human/golem, leave_or_join)
	var/datum/atom_hud/antag/antagHud = GLOB.huds[antag_hud]
	if(leave_or_join == "join")
		antagHud.join_hud(golem)
		set_antag_hud(golem, antag_hud_name)
	else if(leave_or_join == "leave")
		antagHud.leave_hud(golem)
		set_antag_hud(golem, null)

/datum/antagonist/golem/capitalist
	name = "Capitalist Golem"
	golem_species = /datum/species/golem/capitalist
	antag_hud = ANTAG_HUD_CAPITALIST
	antag_hud_name = "capitalist"

/datum/antagonist/golem/communist
	name = "Communist Golem"
	golem_species = /datum/species/golem/soviet
	antag_hud = ANTAG_HUD_COMMUNIST
	antag_hud_name = "communist"
