/datum/hud
	var/atom/movable/screen/darkspawn_psi/psi_counter

/datum/hud/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	psi_counter = new /atom/movable/screen/darkspawn_psi

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	psi_counter = new /atom/movable/screen/darkspawn_psi
	infodisplay += psi_counter

/datum/hud/Destroy()
	. = ..()
	psi_counter = null