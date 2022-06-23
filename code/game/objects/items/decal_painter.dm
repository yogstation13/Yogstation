/obj/item/airlock_painter/decal/proc/toggle_mode(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	var/obj/item/airlock_painter/floor_painter/fp = new /obj/item/airlock_painter/floor_painter(drop_location())
	fp.ink = src.ink
	to_chat(user, "<span class='notice'>You switch the [src]'s mode.</span>")
	qdel(src)
	user.put_in_active_hand(fp)

/obj/item/airlock_painter/decal
	name = "decal painter"
	desc = "An airlock painter, reprogramed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed. Alt-Click to change design."
	icon = 'icons/obj/objects.dmi'
	icon_state = "decal_sprayer"
	item_state = "decalsprayer"
	custom_materials = list(/datum/material/iron=2000, /datum/material/glass=500)

	item_state = "electronic"
	var/charge_per_use = 0.1

	var/decal_icon
	var/decal_state = "warnline"
	var/decal_color = "#ffffff"
	var/decal_dir = SOUTH

	var/static/list/star_directions = list("north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest")
	var/static/list/cardinal_directions = list("north", "east", "south", "west")
	var/list/allowed_directions = list("south")

	var/static/list/allowed_states = list(
		"warnline", "warncorner", "warnu", "warno", "warnfull",
		"warnline_white", "warncorner_white", "warnu_white", "warno_white", "warnfull_white",
		"tile_corner", "tile_side", "tile_cross", "tile_full",
		"bolt_corner", "bolt_side", "bolt_cross", "bolt_full",
		"trim", "trimcorner", "trimu", "trimo",
		"trom", "tromcorner", "tromu", "tromo",
		"splin", "splincorner", "splinu", "splino",
		"splon", "sploncorner", "splonu", "splono",
		"bord", "bordcorner", "bordercolor", "bordercolorcorner", "edge",
		"delivery", "bot", "loading", "caution", "standclear", "arrows",
		"box", "boxcorner", "botright", "botleft", "checker"
		)

/obj/item/airlock_painter/decal/Initialize()
	..()
	ink = new /obj/item/toner(src)

/obj/item/airlock_painter/decal/CtrlClick(mob/user)
	. = ..()
	toggle_mode(user)

/obj/item/airlock_painter/decal/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, "<span class='notice'>[src] already contains \a [ink].</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, "<span class='notice'>You install [W] into [src].</span>")
		ink = W
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	else
		return ..()

/obj/item/airlock_painter/decal/examine(mob/user)
	..()
	if(!ink)
		to_chat(user, "<span class='notice'>It doesn't have a toner cartridge installed.</span>")
		return
	var/ink_level = "high"
	if(ink.charges <= charge_per_use)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	to_chat(user, "<span class='notice'>Its ink levels look [ink_level].</span>")

/obj/item/airlock_painter/decal/afterattack(var/atom/A, var/mob/user, proximity, params)
	if(!proximity)
		return

	if(!ink)
		to_chat(user, "<span class='notice'>There is no toner cartridge installed in [src]!</span>")
		return FALSE
	else if(ink.charges <= charge_per_use)
		to_chat(user, "<span class='notice'>[src] is out of ink!</span>")
		return FALSE

	var/turf/open/floor/F = A
	if(!istype(F))
		to_chat(user, "<span class='warning'>\The [src] can only be used on station flooring.</span>")
		return

	F.AddElement(/datum/element/decal, 'modular_lumos/icons/turf/decals.dmi', decal_state, turn(decal_dir, -dir2angle(F.dir)), CLEAN_STRONG, decal_color, null, null, alpha)

	if(ink.charges > charge_per_use)
		playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	else
		playsound(src, 'sound/effects/spray3.ogg', 50, 1)
		ink.name = "empty " + ink.name

	ink.charges -= charge_per_use

/obj/item/airlock_painter/decal/attack_self(var/mob/user)
	if(!user)
		return FALSE
	user.set_machine(src)
	interact(user)
	return TRUE

/obj/item/airlock_painter/decal/interact(mob/user as mob) //TODO: Make TGUI for this because ouch
	if(!decal_icon)
		decal_icon = icon('modular_lumos/icons/turf/decals.dmi', decal_state, decal_dir)
	user << browse_rsc(decal_icon, "floor.png")
	var/dat = {"
		<center>
			<img style="-ms-interpolation-mode: nearest-neighbor;" src="floor.png" width=128 height=128 border=4>
		</center>
		<center>
			<a href="?src=[UID()];cycleleft=1">&lt;-</a>
			<a href="?src=[UID()];choose_state=1">Choose Style</a>
			<a href="?src=[UID()];cycleright=1">-&gt;</a>
		</center>
		<div class='statusDisplay'>Style: [decal_state]</div>
		<center>
			<a href="?src=[UID()];cycledirleft=1">&lt;-</a>
			<a href="?src=[UID()];choose_dir=1">Choose Direction</a>
			<a href="?src=[UID()];cycledirright=1">-&gt;</a>
		</center>
		<div class='statusDisplay'>Direction: [dir2text(decal_dir)]</div>
		<center>
			<a href="?src=[UID()];choose_color=1">Choose Color</a>
			<span style='border: 1px solid #161616; background-color: [decal_color];'>&nbsp;&nbsp;&nbsp;</span>
		</center>
	"}

	var/datum/browser/popup = new(user, "decal_painter", name, 225, 300)
	popup.set_content(dat)
	popup.open()

/obj/item/airlock_painter/decal/Topic(href, href_list)
	if(..())
		return

	if(href_list["choose_state"])
		var/state = input("Please select a style", "[src]") as null|anything in allowed_states
		if(state)
			decal_state = state
			check_directional_tile()
	if(href_list["choose_dir"])
		var/seldir = input("Please select a direction", "[src]") as null|anything in allowed_directions
		if(seldir)
			decal_dir = text2dir(seldir)
	if(href_list["cycledirleft"])
		var/index = allowed_directions.Find(dir2text(decal_dir))
		index--
		if(index < 1)
			index = allowed_directions.len
		decal_dir = text2dir(allowed_directions[index])
	if(href_list["cycledirright"])
		var/index = allowed_directions.Find(dir2text(decal_dir))
		index++
		if(index > allowed_directions.len)
			index = 1
		decal_dir = text2dir(allowed_directions[index])
	if(href_list["cycleleft"])
		var/index = allowed_states.Find(decal_state)
		index--
		if(index < 1)
			index = allowed_states.len
		decal_state = allowed_states[index]
		check_directional_tile()
	if(href_list["cycleright"])
		var/index = allowed_states.Find(decal_state)
		index++
		if(index > allowed_states.len)
			index = 1
		decal_state = allowed_states[index]
		check_directional_tile()
	if(href_list["choose_color"])
		var/chosen_color = input(usr, "", "Choose Color", decal_color) as color|null
		if(!chosen_color)
			decal_color = "#ffffff"
		else
			decal_color = chosen_color

	decal_icon = icon('modular_lumos/icons/turf/decals.dmi', decal_state, decal_dir)
	if(usr)
		attack_self(usr)

/obj/item/airlock_painter/decal/proc/check_directional_tile()
	var/icon/current = icon('modular_lumos/icons/turf/decals.dmi', decal_state, NORTHWEST)
	if(current.GetPixel(1,1) != null)
		allowed_directions = star_directions
	else
		current = icon('modular_lumos/icons/turf/decals.dmi', decal_state, WEST)
		if(current.GetPixel(1,1) != null)
			allowed_directions = cardinal_directions
		else
			allowed_directions = list("south")

	if(!(dir2text(decal_dir) in allowed_directions))
		decal_dir = SOUTH

// Floor painter

/obj/item/airlock_painter/floor_painter
	name = "floor painter"
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_painter"
	desc = "An airlock painter, reprogramed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed. Use it inhand to change the design, and Ctrl-Click to switch to decal-painting mode."

	var/floor_icon
	var/floor_state = "floor"
	var/floor_dir = SOUTH

	item_state = "electronic"
	var/charge_per_use = 0.1

	var/static/list/star_directions = list("north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest")
	var/static/list/cardinal_directions = list("north", "east", "south", "west")
	var/list/allowed_directions = list("south")

	var/static/list/allowed_states = list(
		"floor", "white", "cafeteria", "whitehall", "whitecorner", "stairs-old",
		"stairs", "stairs-l", "stairs-m", "stairs-r", "grimy", "yellowsiding",
		"yellowcornersiding", "chapel", "pinkblack", "darkfull", "checker",
		"dark", "darkcorner", "solarpanel", "freezerfloor", "showroomfloor","elevatorshaft",
		"recharge_floor", "sepia", "bcircuit", "rcircuit", "gcircuit",
		"rockvault", "sandstonevault", "alienvault", "podfloor", "podfloor_dark", "podfloor_light"
		)

/obj/item/airlock_painter/floor_painter/Initialize()
	..()
	ink = new /obj/item/toner(src)

/obj/item/airlock_painter/floor_painter/CtrlClick(mob/user)
	. = ..()
	toggle_mode(user)

/obj/item/airlock_painter/floor_painter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, "<span class='notice'>[src] already contains \a [ink].</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, "<span class='notice'>You install [W] into [src].</span>")
		ink = W
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	else
		return ..()

/obj/item/airlock_painter/floor_painter/examine(mob/user)
	..()
	if(!ink)
		to_chat(user, "<span class='notice'>It doesn't have a toner cartridge installed.</span>")
		return
	var/ink_level = "high"
	if(ink.charges <= charge_per_use)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	to_chat(user, "<span class='notice'>Its ink levels look [ink_level].</span>")

/obj/item/airlock_painter/floor_painter/afterattack(var/atom/A, var/mob/user, proximity, params)
	if(!proximity)
		return

	if(!ink)
		to_chat(user, "<span class='notice'>There is no toner cartridge installed in [src]!</span>")
		return FALSE
	else if(ink.charges <= charge_per_use)
		to_chat(user, "<span class='notice'>[src] is out of ink!</span>")
		return FALSE

	var/turf/open/floor/plasteel/F = A
	if(!istype(F))
		to_chat(user, "<span class='warning'>\The [src] can only be used on station flooring.</span>")
		return

	if(F.dir == floor_dir && F.icon_state == floor_state && F.icon_regular_floor == floor_state)
		return //No point wasting ink

	F.icon_state = floor_state
	F.icon_regular_floor = floor_state
	F.dir = floor_dir

	if(ink.charges > charge_per_use)
		playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	else
		playsound(src, 'sound/effects/spray3.ogg', 50, 1)
		ink.name = "empty " + ink.name

	ink.charges -= charge_per_use

/obj/item/airlock_painter/floor_painter/attack_self(var/mob/user)
	if(!user)
		return FALSE
	user.set_machine(src)
	interact(user)
	return TRUE

/obj/item/airlock_painter/floor_painter/interact(mob/user as mob) //TODO: Make TGUI for this because ouch
	if(!floor_icon)
		floor_icon = icon('modular_lumos/icons/turf/floors.dmi', floor_state, floor_dir)
	user << browse_rsc(floor_icon, "floor.png")
	var/dat = {"
		<center>
			<img style="-ms-interpolation-mode: nearest-neighbor;" src="floor.png" width=128 height=128 border=4>
		</center>
		<center>
			<a href="?src=[UID()];cycleleft=1">&lt;-</a>
			<a href="?src=[UID()];choose_state=1">Choose Style</a>
			<a href="?src=[UID()];cycleright=1">-&gt;</a>
		</center>
		<div class='statusDisplay'>Style: [floor_state]</div>
		<center>
			<a href="?src=[UID()];cycledirleft=1">&lt;-</a>
			<a href="?src=[UID()];choose_dir=1">Choose Direction</a>
			<a href="?src=[UID()];cycledirright=1">-&gt;</a>
		</center>
		<div class='statusDisplay'>Direction: [dir2text(floor_dir)]</div>
	"}

	var/datum/browser/popup = new(user, "floor_painter", name, 225, 300)
	popup.set_content(dat)
	popup.open()

/obj/item/airlock_painter/floor_painter/Topic(href, href_list)
	if(..())
		return

	if(href_list["choose_state"])
		var/state = input("Please select a style", "[src]") as null|anything in allowed_states
		if(state)
			floor_state = state
			check_directional_tile()
	if(href_list["choose_dir"])
		var/seldir = input("Please select a direction", "[src]") as null|anything in allowed_directions
		if(seldir)
			floor_dir = text2dir(seldir)
	if(href_list["cycledirleft"])
		var/index = allowed_directions.Find(dir2text(floor_dir))
		index--
		if(index < 1)
			index = allowed_directions.len
		floor_dir = text2dir(allowed_directions[index])
	if(href_list["cycledirright"])
		var/index = allowed_directions.Find(dir2text(floor_dir))
		index++
		if(index > allowed_directions.len)
			index = 1
		floor_dir = text2dir(allowed_directions[index])
	if(href_list["cycleleft"])
		var/index = allowed_states.Find(floor_state)
		index--
		if(index < 1)
			index = allowed_states.len
		floor_state = allowed_states[index]
		check_directional_tile()
	if(href_list["cycleright"])
		var/index = allowed_states.Find(floor_state)
		index++
		if(index > allowed_states.len)
			index = 1
		floor_state = allowed_states[index]
		check_directional_tile()

	floor_icon = icon('modular_lumos/icons/turf/floors.dmi', floor_state, floor_dir)
	if(usr)
		attack_self(usr)

/obj/item/airlock_painter/floor_painter/proc/check_directional_tile()
	var/icon/current = icon('modular_lumos/icons/turf/floors.dmi', floor_state, NORTHWEST)
	if(current.GetPixel(1,1) != null)
		allowed_directions = star_directions
	else
		current = icon('modular_lumos/icons/turf/floors.dmi', floor_state, WEST)
		if(current.GetPixel(1,1) != null)
			allowed_directions = cardinal_directions
		else
			allowed_directions = list("south")

	if(!(dir2text(floor_dir) in allowed_directions))
		floor_dir = SOUTH

/obj/item/airlock_painter/floor_painter/proc/toggle_mode(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	var/obj/item/airlock_painter/decal/dp = new /obj/item/airlock_painter/decal(drop_location())
	dp.ink = src.ink
	to_chat(user, "<span class='notice'>You switch the [src]'s mode.</span>")
	qdel(src)
	user.put_in_active_hand(dp)
