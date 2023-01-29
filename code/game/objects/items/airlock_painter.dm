/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"
	
	w_class = WEIGHT_CLASS_SMALL

	materials = list(/datum/material/iron=50, /datum/material/glass=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray2.ogg'

	/// The ink cartridge to pull charges from.
	var/obj/item/toner/ink = null
	/// The type path to instantiate for the ink cartridge the device initially comes with, eg. /obj/item/toner
	var/initial_ink_type = /obj/item/toner
	var/painter_mode = 1
	/// Associate list of all paint jobs the airlock painter can apply. The key is the name of the airlock the user will see. The value is the type path of the airlock
	var/list/available_paint_jobs = list(
		"Public" = /obj/machinery/door/airlock/public,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Security" = /obj/machinery/door/airlock/security,
		"Command" = /obj/machinery/door/airlock/command,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Research" = /obj/machinery/door/airlock/research,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Science" = /obj/machinery/door/airlock/science,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Virology" = /obj/machinery/door/airlock/virology,
		"Standard" = /obj/machinery/door/airlock,
	    "Centcom"  = /obj/machinery/door/airlock/centcom
	)

/obj/item/airlock_painter/Initialize()
	. = ..()
	ink = new initial_ink_type(src)

/obj/item/airlock_painter/proc/get_mode()
	return painter_mode

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE)
		return TRUE
	else
		return FALSE

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		to_chat(user, span_warning("There is no toner cartridge installed in [src]!"))
		return FALSE
	else if(ink.charges < 1)
		to_chat(user, span_warning("[src] is out of ink!"))
		return FALSE
	else
		return TRUE

/obj/item/airlock_painter/suicide_act(mob/user)
	var/obj/item/organ/lungs/L = user.getorganslot(ORGAN_SLOT_LUNGS)

	if(can_use(user) && L)
		user.visible_message(span_suicide("[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		use(user)

		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// Find out if there is an open turf in front of us,
		// and if not, pick the turf we are standing on.
		var/turf/T = get_step(get_turf(src), user.dir)
		if(!isopenturf(T))
			T = get_turf(src)

		// they managed to lose their lungs between then and
		// now. Good job.
		if(!L)
			return OXYLOSS

		L.Remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent(/datum/reagent/colorful_reagent, 10)
		L.reagents.reaction(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message(span_suicide("[user] vomits out [user.p_their()] [L]!"))
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message(span_suicide("[user] is spraying toner on [user.p_them()]self from [src]! It looks like [user.p_theyre()] trying to commit suicide."))
		user.reagents.add_reagent(/datum/reagent/colorful_reagent, 1)
		user.reagents.reaction(user, TOUCH, 1)
		return TOXLOSS

	else
		user.visible_message(span_suicide("[user] is trying to inhale toner from [src]! It might be a suicide attempt if [src] had any toner."))
		return SHAME


/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += span_notice("It doesn't have a toner cartridge installed.")
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	. += span_notice("Its ink levels look [ink_level].")


/obj/item/airlock_painter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, span_warning("[src] already contains \a [ink]!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, span_notice("You install [W] into [src]."))
		ink = W
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	else
		return ..()

/obj/item/airlock_painter/AltClick(mob/user, obj/item/W)
	. = ..()
	if(ink)
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		ink.forceMove(user.drop_location())
		user.put_in_hands(ink)
		to_chat(user, span_notice("You remove [ink] from [src]."))
		ink = null

/obj/item/airlock_painter/decal
	name = "decal painter"
	desc = "An airlock painter, reprogrammed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed. Alt-Click to take out toner."
	icon = 'icons/obj/objects.dmi'
	icon_state = "decal_sprayer"
	item_state = "decal_sprayer"
	painter_mode = 2
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)
	initial_ink_type = /obj/item/toner/large
	/// The current direction of the decal being printed
	var/stored_dir = 2
	/// The current color of the decal being printed.
	var/stored_color = "yellow"
	/// The current base icon state of the decal being printed.
	var/stored_decal = "warningline"
	/// The full icon state of the decal being printed.
	var/stored_decal_total = "warningline"
	/// The type path of the spritesheet being used for the frontend.
	var/spritesheet_type = /datum/asset/spritesheet/decals // spritesheet containing previews
	/// Does this printer implementation support custom colors?
	var/supports_custom_color = FALSE
	/// Current custom color
	var/stored_custom_color
	/// List of color options as list(user-friendly label, color value to return)
	var/color_list = list(
		list("Yellow", "yellow"),
		list("Red", "red"),
		list("White", "white"),
	)
	/// List of direction options as list(user-friendly label, dir value to return)
	var/dir_list = list(
		list("North", NORTH),
		list("South", SOUTH),
		list("East", EAST),
		list("West", WEST),
	)
	/// List of decal options as list(user-friendly label, icon state base value to return)
	var/decal_list = list(list("Warning Line","warningline"),
			list("Warning Line Corner","warninglinecorner"),
			list("Warning Line U Corner","warn_end"),
			list("Warning Line Box","warn_box"),
			list("Caution Label","caution"),
			list("Directional Arrows","arrows"),
			list("Stand Clear Label","stand_clear"),
			list("Box","box"),
			list("Box Corner","box_corners"),
			list("Delivery Marker","delivery"),
			list("Warning Box","warn_full"),
			list("Loading Arrow","loadingarea"),
			list("Bot","bot"),
			list("Bot Right","bot_right"),
			list("Bot Left","bot_left"),

	)
	// These decals only have a south sprite.
	var/nondirectional_decals = list(
		"bot",
		"box",
		"delivery",
		"warn_full",
		"bot_right",
		"bot_left",
	)

/obj/item/airlock_painter/decal/Initialize(mapload)
	. = ..()
	stored_custom_color = stored_color

/obj/item/airlock_painter/decal/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		to_chat(user, span_notice("You need to get closer!"))
		return

	if(isfloorturf(target) && use_paint(user))
		paint_floor(target)

/**
 * Actually add current decal to the floor.
 *
 * Responsible for actually adding the element to the turf for maximum flexibility.area
 * Can be overriden for different decal behaviors.
 * Arguments:
 * * target - The turf being painted to
*/
/obj/item/airlock_painter/decal/proc/paint_floor(turf/open/floor/target)
	target.AddComponent(/datum/component/decal, 'icons/turf/decals.dmi', stored_decal_total, stored_dir, FALSE, color, null, null, 255)

/**
 * Return the final icon_state for the given decal options
 *
 * Arguments:
 * * decal - the selected decal base icon state
 * * color - the selected color
 * * dir - the selected dir
 */
/obj/item/airlock_painter/decal/proc/get_decal_path(decal, color, dir)
	// Special case due to icon_state names
	if(color == "yellow")
		color = ""

	return "[decal][color ? "_" : ""][color]"

/obj/item/airlock_painter/decal/proc/update_decal_path()
	stored_decal_total = get_decal_path(stored_decal, stored_color, stored_dir)

/obj/item/airlock_painter/decal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DecalPainter", name)
		ui.open()

/obj/item/airlock_painter/decal/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(spritesheet_type)

/obj/item/airlock_painter/decal/ui_static_data(mob/user)
	. = ..()
	var/datum/asset/spritesheet/icon_assets = get_asset_datum(spritesheet_type)

	.["icon_prefix"] = "[icon_assets.name]32x32"
	.["supports_custom_color"] = supports_custom_color
	.["decal_list"] = list()
	.["color_list"] = list()
	.["dir_list"] = list()
	.["nondirectional_decals"] = nondirectional_decals

	for(var/decal in decal_list)
		.["decal_list"] += list(list(
			"name" = decal[1],
			"decal" = decal[2],
		))
	for(var/color in color_list)
		.["color_list"] += list(list(
			"name" = color[1],
			"color" = color[2],
		))
	for(var/dir in dir_list)
		.["dir_list"] += list(list(
			"name" = dir[1],
			"dir" = dir[2],
		))

/obj/item/airlock_painter/decal/ui_data(mob/user)
	. = ..()
	.["current_decal"] = stored_decal
	.["current_color"] = stored_color
	.["current_dir"] = stored_dir
	.["current_custom_color"] = stored_custom_color

/obj/item/airlock_painter/decal/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		//Lists of decals and designs
		if("select decal")
			var/selected_decal = params["decal"]
			var/selected_dir = text2num(params["dir"])
			stored_decal = selected_decal
			stored_dir = selected_dir
		if("select color")
			var/selected_color = params["color"]
			stored_color = selected_color
		if("pick custom color")
			if(supports_custom_color)
				pick_painting_tool_color(usr, stored_custom_color)
	update_decal_path()
	. = TRUE
