/turf/open/floor/light
	name = "light floor"
	desc = "A wired glass tile embedded into the floor. Modify the color with a Screwdriver."
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	var/on = TRUE
	var/state = 0//0 = fine, 1 = flickering, 2 = breaking, 3 = broken
	var/list/coloredlights = list("r", "o", "y", "g", "b", "i", "v", "w", "s", "z")
	var/currentcolor = "b"
	var/can_modify_colour = TRUE
	tiled_dirt = FALSE
	var/static/list/lighttile_designs

/turf/open/floor/light/broken_states()
	return list("light_broken")

/turf/open/floor/light/examine(mob/user)
	. = ..()
	. += span_notice("There's a <b>small crack</b> on the edge of it.")

/turf/open/floor/light/proc/populate_lighttile_designs()
	lighttile_designs = list(
		"r" = image(icon = src.icon, icon_state = "light_on-r"),
		"o" = image(icon = src.icon, icon_state = "light_on-o"),
		"y" = image(icon = src.icon, icon_state = "light_on-y"),
		"g" = image(icon = src.icon, icon_state = "light_on-g"),
		"b" = image(icon = src.icon, icon_state = "light_on-b"),
		"i" = image(icon = src.icon, icon_state = "light_on-i"),
		"v" = image(icon = src.icon, icon_state = "light_on-v"),
		"w" = image(icon = src.icon, icon_state = "light_on-w"),
		"blk" = image(icon = src.icon, icon_state = "light_on-blk"),
		"s" = image(icon = src.icon, icon_state = "light_on-s"),
		"z" = image(icon = src.icon, icon_state = "light_on-z")
		)

/turf/open/floor/light/Initialize(mapload)
	. = ..()
	update_appearance()
	if(!length(lighttile_designs))
		populate_lighttile_designs()

/turf/open/floor/light/break_tile()
	..()
	light_range = 0
	update_light()

/turf/open/floor/light/update_icon(updates=ALL)
	. = ..()
	if(on)
		switch(state)
			if(0)
				icon_state = "light_on-[currentcolor]"
				set_light(1)
			if(1)
				var/num = pick("1","2","3","4")
				icon_state = "light_on_flicker[num]"
				set_light(1)
			if(2)
				icon_state = "light_on_broken"
				set_light(1)
			if(3)
				icon_state = "light_off"
				set_light(0)
	else
		set_light(0)
		icon_state = "light_off"


/turf/open/floor/light/ChangeTurf(path, new_baseturf, flags)
	set_light(0)
	return ..()

/turf/open/floor/light/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!can_modify_colour)
		return
	var/choice = show_radial_menu(user,src, lighttile_designs, custom_check = CALLBACK(src, PROC_REF(check_menu), user, I), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	currentcolor = choice
	update_appearance(UPDATE_ICON)

/turf/open/floor/light/attack_ai(mob/user)
	if(!can_modify_colour)
		return
	var/choice = show_radial_menu(user,src, lighttile_designs, custom_check = FALSE, radius = 36, require_near = FALSE)
	if(!choice)
		return FALSE
	currentcolor = choice
	update_appearance(UPDATE_ICON)
	return attack_hand(user)

/turf/open/floor/light/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/light/bulb)) //only for light tiles
		if(state && user.temporarilyRemoveItemFromInventory(C))
			qdel(C)
			state = 0 //fixing it by bashing it with a light bulb, fun eh?
			update_appearance(UPDATE_ICON)
			to_chat(user, span_notice("You replace the light bulb."))
		else
			to_chat(user, span_notice("The light bulb seems fine, no need to replace it."))


//Cycles through all of the colours
/turf/open/floor/light/colour_cycle
	currentcolor = "cycle_all"
	can_modify_colour = FALSE



//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/open/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	currentcolor = "dancefloor_A"

/turf/open/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	currentcolor = "dancefloor_A"


///check_menu: Checks if we are allowed to interact with a radial menu

///Arguments:
///user The mob interacting with a menu
///screwdriver The screwdriver used to interact with a menu

/turf/open/floor/light/proc/check_menu(mob/living/user, obj/item/screwdriver)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!screwdriver || !user.is_holding(screwdriver))
		return FALSE
	return TRUE
