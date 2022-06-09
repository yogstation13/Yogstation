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
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/datum/team/hog_cult/cult
	var/is_recall_on_cooldown = FALSE
	var/cool_name = "God"
	var/lights_breaked_recently = 0

/mob/camera/hog_god/proc/select_name()
	var/new_name = input(src, "Choose your new name", "Name")
	if(!name)
		to_chat(src, span_notice("Not a valid name."))
		select_name()
		return
	name = new_name
	real_name = new_name
	cult.name = "[new_name]'s Cult"
	cult.member_name = "Servant of [new_name]" ///Zamn they serve new_name, cool guys
	

/mob/camera/hog_god/proc/lighttimer(var/time)
	addtimer(CALLBACK(src, .proc/lightttts), time)

/mob/camera/hog_god/proc/lightttts()
	lights_breaked_recently -= 1
	
 
