/datum/antagonist/capitalist
	name = "Capitalist Golem"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/capitalist/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(/datum/antagonist/capitalist)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/capitalist/admin_remove(datum/mind/new_owner,mob/admin)
	new_owner.remove_antag_datum(/datum/antagonist/capitalist)

/datum/antagonist/capitalist/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_capitalist_icons_added(M)
	M.set_species(/datum/species/golem/soviet)

/datum/antagonist/capitalist/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_capitalist_icons_removed(M)
	M.set_species(/datum/species/human) //human master race

/datum/antagonist/capitalist/proc/update_capitalist_icons_added(var/mob/living/carbon/human/capitalist)
	var/datum/atom_hud/antag/capitalisthud = GLOB.huds[ANTAG_HUD_CAPITALIST]
	capitalisthud.join_hud(capitalist)
	set_antag_hud(capitalist, "capitalist")

/datum/antagonist/capitalist/proc/update_capitalist_icons_removed(var/mob/living/carbon/human/capitalist)
	var/datum/atom_hud/antag/capitalisthud = GLOB.huds[ANTAG_HUD_CAPITALIST]
	capitalisthud.leave_hud(capitalist)
	set_antag_hud(capitalist, null)