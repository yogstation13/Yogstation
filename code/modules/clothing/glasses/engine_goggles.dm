//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"
#define MODE_SHUTTLE "shuttle"
#define MODE_ATMOS_THERMAL "atmospheric-thermal"
#define TEMP_SHADE_CYAN 273.15
#define TEMP_SHADE_GREEN 283.15
#define TEMP_SHADE_YELLOW 300
#define TEMP_SHADE_RED 500

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, the T-ray Scanner mode lets you see underfloor objects such as cables and pipes, and the Radiation Scanner mode let's you see objects contaminated by radiation."
	icon_state = "trayson-meson"
	item_state = "trayson-meson"
	actions_types = list(/datum/action/item_action/toggle_mode)

	vision_flags = NONE
	invis_view = SEE_INVISIBLE_LIVING
	color_cutoffs = null

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1

/obj/item/clothing/glasses/meson/engine/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_appearance(UPDATE_ICON)

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "You turn the goggles":"The goggles turn"] [mode ? "to [mode] mode":"off"][voluntary ? ".":"!"]</span>")

	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			color_cutoffs = list(15, 12, 0)

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			color_cutoffs = list()
			
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_appearance(UPDATE_ICON)
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/meson/engine/process()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	switch(mode)
		if(MODE_TRAY)
			t_ray_scan(user, 8, range)
		if(MODE_RAD)
			show_rads()
		if(MODE_SHUTTLE)
			show_shuttle()
		if(MODE_ATMOS_THERMAL)
			atmos_thermal(user)

/obj/item/clothing/glasses/meson/engine/proc/show_rads()
	var/mob/living/carbon/human/user = loc
	var/list/rad_places = list()
	for(var/datum/component/radioactive/thing in SSradiation.processing)
		var/atom/owner = thing.parent
		var/turf/place = get_turf(owner)
		if(rad_places[place])
			rad_places[place] += thing.strength
		else
			rad_places[place] = thing.strength

	for(var/i in rad_places)
		var/turf/place = i
		if(get_dist(user, place) >= range*5)	//Rads are easier to see than wires under the floor
			continue
		var/strength = round(rad_places[i] / 1000, 0.1)
		var/image/pic = image(loc = place)
		var/mutable_appearance/MA = new()
		MA.maptext = span_maptext("[strength]k")
		MA.color = "#04e604"
		MA.plane = GAME_PLANE
		pic.appearance = MA
		flick_overlay_global(pic, list(user.client), 10)

/obj/item/clothing/glasses/meson/engine/proc/show_shuttle()
	var/mob/living/carbon/human/user = loc
	var/obj/docking_port/mobile/port = SSshuttle.get_containing_shuttle(user)
	if(!port)
		return
	var/list/shuttle_areas = port.shuttle_areas
	for(var/area/region as anything in shuttle_areas)
		for(var/turf/place as anything in region.get_contained_turfs())
			if(get_dist(user, place) > 7)
				continue
			var/image/pic
			if(isshuttleturf(place))
				pic = new('icons/turf/overlays.dmi', place, "greenOverlay", AREA_LAYER)
			else
				pic = new('icons/turf/overlays.dmi', place, "redOverlay", AREA_LAYER)
			flick_overlay_global(pic, list(user.client), 8)

/obj/item/clothing/glasses/meson/engine/update_icon_state()
	. = ..()
	icon_state = "trayson-[mode]"
	update_mob()

/obj/item/clothing/glasses/meson/engine/proc/update_mob()
	item_state = icon_state
	if(isliving(loc))
		var/mob/living/user = loc
		if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
			user.update_inv_glasses()
		else
			user.update_inv_hands()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optical t-ray scanner"
	icon_state = "trayson-t-ray"
	item_state = "trayson-t-ray"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	range = 2

	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_ATMOS_THERMAL, MODE_ATMOS_THERMAL = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/shuttle
	name = "shuttle region scanner"
	icon_state = "trayson-shuttle"
	item_state = "trayson-shuttle"
	desc = "Used to see the boundaries of shuttle regions."

	modes = list(MODE_NONE = MODE_SHUTTLE, MODE_SHUTTLE = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/atmos_imaging
	name = "atmospheric thermal imaging goggles"
	desc = "Goggles used by Atmospheric Technicians to see the thermal energy of gasses in open areas."
	icon_state = "trayson-atmospheric-thermal"
	glass_colour_type = /datum/client_colour/glass_colour/gray

	modes = list(MODE_NONE = MODE_ATMOS_THERMAL, MODE_ATMOS_THERMAL = MODE_NONE)

/proc/atmos_thermal(mob/viewer, range = 5, duration = 10)
	if(!ismob(viewer) || !viewer.client)
		return
	for(var/turf/open in view(range, viewer))
		if(open.blocks_air)
			continue
		var/datum/gas_mixture/environment = open.return_air()
		var/temp = round(environment.return_temperature()) 
		var/image/pic = image('icons/turf/overlays.dmi', open, "greyOverlay", ABOVE_ALL_MOB_LAYER)
		// Lower than TEMP_SHADE_CYAN should be deep blue
		switch(temp)
			if(-INFINITY to TEMP_SHADE_CYAN)
				pic.color = COLOR_STRONG_BLUE
			// Between TEMP_SHADE_CYAN and TEMP_SHADE_GREEN
			if(TEMP_SHADE_CYAN to TEMP_SHADE_GREEN)
				pic.color = BlendRGB(COLOR_DARK_CYAN, COLOR_LIME, max(round((temp - TEMP_SHADE_CYAN)/(TEMP_SHADE_GREEN - TEMP_SHADE_CYAN), 0.01), 0))
			// Between TEMP_SHADE_GREEN and TEMP_SHADE_YELLOW
			if(TEMP_SHADE_GREEN to TEMP_SHADE_YELLOW)
				pic.color = BlendRGB(COLOR_LIME, COLOR_YELLOW, clamp(round((temp-TEMP_SHADE_GREEN)/(TEMP_SHADE_YELLOW - TEMP_SHADE_GREEN), 0.01), 0, 1))
			// Between TEMP_SHADE_YELLOW and TEMP_SHADE_RED
			if(TEMP_SHADE_YELLOW to TEMP_SHADE_RED)
				pic.color = BlendRGB(COLOR_YELLOW, COLOR_RED, clamp(round((temp-TEMP_SHADE_YELLOW)/(TEMP_SHADE_RED - TEMP_SHADE_YELLOW), 0.01), 0, 1))
			// Over TEMP_SHADE_RED should be red
			if(TEMP_SHADE_RED to INFINITY)
				pic.color = COLOR_RED
		pic.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		pic.alpha = 200
		flick_overlay_global(pic, list(viewer.client), duration)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
#undef MODE_SHUTTLE
#undef MODE_ATMOS_THERMAL
#undef TEMP_SHADE_CYAN
#undef TEMP_SHADE_GREEN
#undef TEMP_SHADE_YELLOW
#undef TEMP_SHADE_RED
