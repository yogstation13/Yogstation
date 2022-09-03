/obj/structure/flora/tree/dead/jungle
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "nwtree_1"

/obj/structure/flora/tree/dead/jungle/Initialize()
	. = ..()
	icon_state = "nwtree_[rand(1, 6)]"

/obj/effect/temp_visual/skin_twister_in
	layer = BELOW_MOB_LAYER
	duration = 8
	icon = 'yogstation/icons/effects/64x64.dmi'
	icon_state = "skin_twister_in"
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/skin_twister_out
	layer = BELOW_MOB_LAYER
	duration = 8
	icon = 'yogstation/icons/effects/64x64.dmi'
	icon_state = "skin_twister_out"
	pixel_y = -16
	pixel_x = -16

/obj/effect/tar_king
	layer = BELOW_MOB_LAYER
	icon_state = ""

//For some reason Initialize() doesnt want to get properly overloaded, so I'm forced to use this
/obj/effect/tar_king/New(loc, datum/following, direction)
	. = ..()
	RegisterSignal(following,COMSIG_MOVABLE_MOVED,.proc/follow)
	setDir(direction)

/obj/effect/tar_king/proc/follow(datum/source)
	forceMove(get_turf(source))

/obj/effect/tar_king/rune_attack
	icon = 'yogstation/icons/effects/160x160.dmi'
	pixel_x = -64 
	pixel_y = -64

/obj/effect/tar_king/rune_attack/New(loc, ...)
	. = ..()
	flick("rune_attack",src)
	QDEL_IN(src,13)

/obj/effect/tar_king/slash 
	icon = 'yogstation/icons/effects/160x160.dmi'
	pixel_x = -64
	pixel_y = -64

/obj/effect/tar_king/slash/New(loc, datum/following, direction)
	. = ..()
	flick("slash",src)	 
	QDEL_IN(src,4)

/obj/effect/tar_king/impale
	icon = 'yogstation/icons/effects/160x160.dmi'
	pixel_x = -64
	pixel_y = -64

/obj/effect/tar_king/impale/New(loc, ...)
	. = ..()
	flick("stab",src)	 
	QDEL_IN(src,4)

/obj/effect/tar_king/orb_out	
	pixel_x = -16
	pixel_y = -16
	icon = 'yogstation/icons/effects/64x64.dmi'

/obj/effect/tar_king/orb_out/New(loc, ...)
	. = ..()
	flick("ability1",src)	 
	QDEL_IN(src,4)

/obj/effect/tar_king/orb_in
	pixel_x = -16
	pixel_y = -16
	icon = 'yogstation/icons/effects/64x64.dmi'

/obj/effect/tar_king/orb_in/New(loc, ...)
	. = ..()
	flick("ability0",src)	 
	QDEL_IN(src,4)

/obj/structure/tar_pit
	name = "Tar pit"
	desc = "A pit filled with viscious substance resembling tar, every so often a bubble rises to the top."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_pit"
	layer = SIGIL_LAYER
	anchored = TRUE 
	density = FALSE

/obj/structure/tar_pit/Initialize()
	. = ..()
	GLOB.tar_pits += src

/obj/structure/tar_pit/Destroy()
	GLOB.tar_pits -= src
	return ..()


/obj/effect/timed_attack
	var/replace_icon_state = ""
	var/animation_length = 0

/obj/effect/timed_attack/New(loc, ...)
	. = ..()
	flick(replace_icon_state,src)	 
	addtimer(CALLBACK(src,.proc/finish_attack),animation_length)

/obj/effect/timed_attack/proc/finish_attack()
	qdel(src)

/obj/effect/timed_attack/tar_priest 
	icon = 'yogstation/icons/effects/jungle.dmi'
	animation_length = 13

/obj/effect/timed_attack/tar_priest/curse 
	replace_icon_state = "tar_shade_curse"


/obj/effect/timed_attack/tar_priest/curse/finish_attack()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		L.apply_status_effect(/datum/status_effect/tar_curse)	
	return ..()
/obj/effect/timed_attack/tar_priest/shroud
	replace_icon_state = "tar_shade_shroud"

/obj/effect/timed_attack/tar_priest/shroud/finish_attack()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		if(L.has_status_effect(/datum/status_effect/tar_curse))
			L.set_blindness(20)
			SEND_SIGNAL(L,COMSIG_JUNGLELAND_TAR_CURSE_PROC)	
		else 
			L.set_blurriness(20)
	return ..()
/obj/effect/timed_attack/tar_priest/tendril 
	replace_icon_state = "tar_shade_tendril"

/obj/effect/timed_attack/tar_priest/tendril/finish_attack()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		if(L.has_status_effect(/datum/status_effect/tar_curse))
			L.Stun(5 SECONDS)
			SEND_SIGNAL(L,COMSIG_JUNGLELAND_TAR_CURSE_PROC)	
		else 
			L.adjustStaminaLoss(60)
	return ..()

/obj/structure/fluff/tarstatue
	name = "Tar Statue"
	desc = "A lifelike recreation of some...one? It seems damaged from years of neglect."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damaged_tarstatue"
	deconstructible = FALSE


 