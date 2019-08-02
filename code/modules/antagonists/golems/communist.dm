/datum/antagonist/communist
	name = "Communist Golem"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/communist/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(/datum/antagonist/communist)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/communist/admin_remove(datum/mind/new_owner,mob/admin)
	new_owner.remove_antag_datum(/datum/antagonist/communist)

/datum/antagonist/communist/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_communist_icons_added(M)
	M.set_species(/datum/species/golem/soviet)

/datum/antagonist/communist/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_communist_icons_removed(M)
	M.set_species(/datum/species/human) //human master race

/datum/antagonist/communist/proc/update_communist_icons_added(var/mob/living/carbon/human/communist)
	var/datum/atom_hud/antag/communisthud = GLOB.huds[ANTAG_HUD_COMMUNIST]
	communisthud.join_hud(communist)
	set_antag_hud(communist, "communist")

/datum/antagonist/communist/proc/update_communist_icons_removed(var/mob/living/carbon/human/communist)
	var/datum/atom_hud/antag/communisthud = GLOB.huds[ANTAG_HUD_COMMUNIST]
	communisthud.leave_hud(communist)
	set_antag_hud(communist, null)