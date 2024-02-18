/datum/antagonist/golem
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	var/old_species
	var/golem_species
	var/antag_hud
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
	add_team_hud(M, antag_hud)

/datum/antagonist/golem/capitalist
	name = "Capitalist Golem"
	golem_species = /datum/species/golem/capitalist
	antag_hud_name = "capitalist"

/datum/antagonist/golem/communist
	name = "Communist Golem"
	golem_species = /datum/species/golem/soviet
	antag_hud_name = "communist"
