#define UI_DEVIL_SOUL_DISPLAY "WEST:6,CENTER-1:15"

/atom/movable/screen/devil_soul_counter
	icon = 'icons/mob/screen_gen.dmi'
	name = "souls owned"
	icon_state = "devil-6"
	screen_loc = UI_DEVIL_SOUL_DISPLAY

/atom/movable/screen/devil_soul_counter/proc/update_counter(souls)
	maptext = ANTAG_MAPTEXT(souls, COLOR_RED)
	switch(souls)
		if(0)
			icon_state = "devil-1"
		if(1, 2)
			icon_state = "devil-2"
		if(3 to 5)
			icon_state = "devil-3"
		if(6, 7)
			icon_state = "devil-4"
		if(8 to 10)
			icon_state = "devil-5"
		else
			icon_state = "devil-6"

/atom/movable/screen/devil_soul_counter/Click()
	var/datum/antagonist/devil/devil_antag = hud.mymob.mind.has_antag_datum(/datum/antagonist/devil)
	if(!devil_antag)
		return
	hud.mymob.balloon_alert(usr, "souls owned: [devil_antag.souls]")
	

#undef UI_DEVIL_SOUL_DISPLAY
