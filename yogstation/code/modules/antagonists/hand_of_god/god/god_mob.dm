/mob/camera/hog_god
	name = "God"
	real_name = "God"
	desc = "It is a god."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	see_in_dark = 15
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	color = "#00a7ff"

	pass_flags = PASSBLOB
	faction = list(ROLE_HOG_CULTIST)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
  var/datum/team/hog_cult/cult
  var/list/clickaction_servant = list()
 
