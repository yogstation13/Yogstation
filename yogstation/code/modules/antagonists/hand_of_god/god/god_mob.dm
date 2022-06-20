/mob/camera/hog_god
	name = "God"
	real_name = "God"
	desc = "It is a god."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	see_in_dark = 20
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	color = "#00a7ff"

	pass_flags = PASSBLOB
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/datum/team/hog_cult/cult
	var/is_recall_on_cooldown = FALSE
	var/cool_name = "God"
	var/lights_breaked_recently = 0
	var/list/spells = list()


/mob/camera/hog_god/Initialize()	
	. = ..()
	for(var/datum/hog_god_interaction/targeted/spell in typesof(/datum/hog_god_interaction/targeted))
		spell = new
		src.spells += spell


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

/mob/camera/hog_god/proc/recall(mob/living/target)
	to_chat(target, span_notice("You feel yourself get pulled..."))
	to_chat(src, span_notice("You start recalling [target]..."))
	sleep(7 SECONDS) ///Sorry, sleeping is necessary here for some checks
	if(!istype(target, /mob/living))
		return	FALSE
	if(!IS_HOG_CULTIST(target))
		return	FALSE
	if(target.stat == DEAD)
		return	FALSE
	if(!cult.nexus)
		return	FALSE
	target.forceMove(get_turf(cult.nexus))	
	target.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
	target.clear_fullscreen("flash", 5)
	return TRUE
 
/mob/camera/hog_god/proc/mass_recall()
	if(!cult.recalls)
		to_chat(src, "You don't have any mass recalls left")
		return
	var/yes = FALSE
	for(var/datum/mind/guy in cult.members)
		if(!guy.has_antag_datum(/datum/antagonist/hog))
			continue
		if(!guy.current)
			continue
		var/mob/living/man = guy.current
		if(!man)
			continue
		if(man.stat == DEAD)
			continue
		INVOKE_ASYNC(src, man, .proc/recall)
		yes = TRUE
	if(yes)
		cult.message_all_dudes("<span class='cultlarge'><b>Your god has innitiated mass recall! Soon, all of you will be teleported to your nexus.</b></span>", FALSE)
		to_chat(src, "You initiate mass recall")
		cult.recalls--
		return TRUE
	else
		to_chat(src, "You fail to initiate mass recall")
		return FALSE

