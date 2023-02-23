/datum/hud
	var/atom/movable/screen/zombie_infection/infection_display

/datum/hud/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	infection_display = new /atom/movable/screen/zombie_infection

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	infection_display = new /atom/movable/screen/zombie_infection
	infodisplay += infection_display

/datum/hud/Destroy()
	. = ..()
	infection_display = null

//////////////////////////// for brainy simplemob //////////////////////////

/datum/hud/zombie
	ui_style = 'icons/mob/screen_midnight.dmi'

/datum/hud/zombie/New(mob/owner)
	. = ..()
	infection_display = new /atom/movable/screen/zombie_infection
	infodisplay += infection_display

/datum/hud/zombie/Destroy()
	. = ..()
	QDEL_NULL(infection_display)

