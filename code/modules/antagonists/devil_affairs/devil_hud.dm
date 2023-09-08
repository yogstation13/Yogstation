/atom/movable/screen/devil
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/devil/soul_counter
	icon = 'icons/mob/screen_gen.dmi'
	name = "souls owned"
	icon_state = "Devil-6"
	screen_loc = ui_devilsouldisplay

/atom/movable/screen/devil/soul_counter/proc/update_counter(souls)
	invisibility = 0
	maptext = ANTAG_MAPTEXT(souls, COLOR_RED)
	switch(souls)
		if(0)
			icon_state = "Devil-1"
		if(1, 2)
			icon_state = "Devil-2"
		if(3 to 5)
			icon_state = "Devil-3"
		if(6 to 7)
			icon_state = "Devil-4"
		if(8 to INFINITY)
			icon_state = "Devil-5"
		else
			icon_state = "Devil-6"

/atom/movable/screen/devil/soul_counter/proc/clear()
	invisibility = INVISIBILITY_ABSTRACT
