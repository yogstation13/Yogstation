GLOBAL_LIST_EMPTY(cargo_marks)

/obj/item/cargo_teleporter
	name = "cargo handheld teleporter"
	desc = "Specialised personal teleporter based on modern bluespace technology. This one issued to QM for moving crates, closets and none-living objects to previously marked locations."
	icon = 'modular_dripstation/icons/obj/cargo/cargo_teleporter.dmi'
	mob_overlay_icon = 'modular_dripstation/icons/mob/clothing/belt.dmi'
	lefthand_file = 'modular_dripstation/icons/mob/inhands/equipment/cargo_teleporter_lefthand.dmi'
	righthand_file = 'modular_dripstation/icons/mob/inhands/equipment/cargo_teleporter_righthand.dmi'
	icon_state = "cargo_tele"
	item_state = "cargo_tele"
	materials = list(MAT_METAL=10000)
	slot_flags = ITEM_SLOT_BELT
	cryo_preserve = TRUE
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/marker_children = list()		//the list of markers spawned by this item
	var/choice 								//storing marker of choice
	var/cooldown_in_seconds = 16 SECONDS	//cooldown, made for upgrades
	var/emagged = FALSE						//emagged?
	var/emped = FALSE						//emped?
	verb_say = "beeps"
	verb_exclaim = "blares"
	var/obj/item/stock_parts/manipulator/manipulator = null
	var/obj/item/stock_parts/cell/high/ctcell = null // Power cell (10000W)
	var/chargecost = 1000	// How much energy tele use
	var/static/list/high_risk_teleporting = typecacheof(list(
			/obj/item/disk/nuclear,
			/obj/item/gun/energy/laser/captain,
			/obj/item/hand_tele,
			/obj/item/clothing/accessory/medal/gold/captain,
			/obj/item/melee/sabre,
			/obj/item/clothing/gloves/krav_maga/sec,
			/obj/item/gun/energy/e_gun/hos,
			/obj/item/card/id/captains_spare,
			/obj/item/tank/jetpack/oxygen/captain,
			/obj/item/aicard,
			/obj/item/hypospray/deluxe/cmo,
			/obj/item/clothing/suit/armor/reactive/teleport,
			/obj/item/clothing/suit/armor/laserproof,
			/obj/item/blackbox,
			/obj/item/holotool,
			/obj/item/areaeditor/blueprints)
			)
	var/static/list/blacklisted_turfs = typecacheof(list(
			/turf/closed,
			/turf/open/chasm,
			/turf/open/lava))
	var/static/list/deathtrap_list = typecacheof(list(
			/obj/machinery/power/supermatter_crystal,
			/obj/machinery/conveyor,
			/obj/machinery/recycler))

	COOLDOWN_DECLARE(use_cooldown)

/obj/item/cargo_teleporter/get_cell()
	return ctcell

/obj/item/cargo_teleporter/Initialize()
	. = ..()
	manipulator = new /obj/item/stock_parts/manipulator(src)
	ctcell = new(src)

/obj/item/cargo_teleporter/emp_act(severity)
	if (. & EMP_PROTECT_SELF)
		return
	emped = TRUE
	SStgui.close_uis(src) //Close the UI control if it is open. I guess do not work, will work with ui refactor, if it will be made some day
	if(severity > EMP_LIGHT)
		ctcell.charge = 0
		if(emagged)
			emagged = FALSE
			if(prob(50))
				var/mob/living/carbon/human/user = src.loc
				say("E:FATAL:PWR_BUS_OVERLOAD")
				if(user.is_holding(src))
					if(user.dna && user.dna.species.id == "human")
						say("E:FATAL:STACK_EMPTY\nE:FATAL:READ_NULL_POINT")
						to_chat(user, span_danger("An electromagnetic pulse disrupts your hacked teleporter and violently turns you into abomination."))
						to_chat(user, span_userdanger("You SEE THE LIGHT."))
						user.set_species(/datum/species/moth)
	else
		ctcell.use(chargecost)
		if(emagged)
			emagged = FALSE

/obj/item/cargo_teleporter/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(emagged)
			. += "<span class='boldwarning'><b>Warning: Safety protocols disabled.</b></span>"
		if(!manipulator)
			. += "<span class='notice'>The manipulator is missing.<span>"
		else
			. += "<span class='notice'>A tier <b>[manipulator.rating]</b> manipulator is installed. It is <i>screwed</i> in place.<span>"
		. += "<span class='notice'>There are <b>[round(ctcell.charge/chargecost)]</b> charge\s left.</span>"
	. += span_notice("Attack itself to set down the markers!")
	. += span_notice("ALT-CLICK to change destination marker!")

/obj/item/cargo_teleporter/Destroy()
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			destroy_children.parent_item = null
			qdel(destroy_children)
	QDEL_NULL(manipulator)
	QDEL_NULL(ctcell)
	return ..()

/obj/item/cargo_teleporter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/manipulator))
		if(!manipulator)
			if(!user.transferItemToLoc(W, src))
				return
			manipulator = W
			playsound(src, 'sound/machines/click.ogg', 25)
			to_chat(user, span_notice("You install a [manipulator.name] in [src]."))
		else
			to_chat(user, span_notice("[src] already has a manipulator installed."))

/obj/item/cargo_teleporter/screwdriver_act(mob/living/user, obj/item/I)
	if(manipulator)
		I.play_tool_sound(src)
		to_chat(user, span_notice("You remove the [manipulator.name] from \the [src]."))
		manipulator.forceMove(drop_location())
		manipulator = null

/obj/item/cargo_teleporter/emag_act(user)
	if(!emagged)
		emagged = TRUE
		do_sparks(3, TRUE, src)
		say("SAFETY PROTOCOLS OVERRIDE DETECTED!")
		return

/obj/item/cargo_teleporter/attack_self(mob/user, modifiers)
	if(isnull(manipulator))
		say("\The [src] is missing it's manipulator, and cannot function.")
		return
	var/turf/current_location = get_turf(user)//What turf is the user on?
	var/area/current_area = current_location.loc
	if(!current_location || current_area.noteleport || is_away_level(current_location.z) || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
		say("\The [src] is malfunctioning.")
		return
	if(!is_station_level(current_location.z))
		var/lava_emag
		if(emagged & is_mining_level(current_location.z))
			lava_emag = TRUE
		if(!lava_emag)
			say("Error 503. Marker location undefined. Bluespace signal is not tracing. Try again onboard.")
			return
	if(isspaceturf(current_location))
		say("You cannot place markers in space.")
		return
	if(is_type_in_typecache(current_location, blacklisted_turfs))
		say("You cannot place markers here.")
		return
	if(length(marker_children) >= manipulator.rating)
		say("You may only have [manipulator.rating] spawned markers from [src].")
		return
	if(locate(/obj/effect/decal/cleanable/cargo_mark) in current_location)
		say("There is already a marker here.")
		return
	var/obj/effect/decal/cleanable/cargo_mark/spawned_marker = new /obj/effect/decal/cleanable/cargo_mark(get_turf(src))
	to_chat(user, span_notice("You place a cargo marker below your feet."))
	playsound(src, 'sound/machines/click.ogg', 50)
	spawned_marker.parent_item = src
	marker_children += spawned_marker

/obj/item/cargo_teleporter/AltClick(mob/user)
	if(!user.is_holding(src))
		to_chat(user, span_notice("You should be able to press the change destination button to to interact with interface."))
		return
	if(emped)
		to_chat(user, "Teleporter restarts by itself!")
		playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, 3)
		emped = FALSE
		choice = null
		return
	makingchoice(user)

/obj/item/cargo_teleporter/proc/makingchoice(mob/user)
	choice = tgui_input_list(user, "Select which cargo mark to teleport the items to?", "Cargo Mark Selection", GLOB.cargo_marks)
	if(!choice)
		return


/obj/item/cargo_teleporter/verb/remove_all_markers()
	set name = "Cargo Tele: Remove All Markers"
	set category = "Object"

	if(!usr.is_holding(src))
		return
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			qdel(destroy_children)
		marker_children = list()
		choice = null
		playsound(src, 'sound/machines/click.ogg', 50)
		to_chat(usr, span_notice("You destroyed all markers."))

/obj/item/cargo_teleporter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user.is_holding(src))
		to_chat(user, span_notice("You should be able to press the teleportation button to be able teleport something."))
		return ..()
	if(isnull(manipulator))
		say("\The [src] is missing it's manipulator, and cannot function.")
		return ..()
	if(ctcell.charge < chargecost)
		say("Unable to teleport, insufficient charge.")
		return ..()
	if(!emagged && !proximity_flag)
		return ..()
	if(emagged && (get_dist(user, target) > manipulator.rating))
		return ..()
	if(target == src)
		return ..()
	if(emped)
		say("\The [src] malfunctioning and needs to be restarted.")
		to_chat(user, span_notice("AltClick on device to restart it."))
		return ..()
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		say("\The [src] is still on cooldown.")
		return
	if(!choice)
		return makingchoice(user)
	var/turf/moving_turf = get_turf(choice)
	var/turf/target_turf = get_turf(target)
	var/area/current_area = target_turf.loc
	if(current_area.noteleport)//If z level disables teleportation
		say("\The [src] is malfunctioning.")
		return
	var/destination_incorrect = FALSE //prevent spamming on one turf and primitive deathraps
	for(var/deathtrap_check in moving_turf.contents) //deathrap checking
		if(emagged & is_type_in_typecache(deathtrap_check, deathtrap_list)) //preventing oneclick deathraps, say no to oneturf recycler bins
			destination_incorrect = TRUE
			continue
		if(moving_turf == target_turf)	//die spamm
			destination_incorrect = TRUE
			continue
	if(destination_incorrect)						//prevent oneturf sound spamming and primitive deathraps
		say("Teleportation error detected. Destination incorrect.")
		playsound(src, 'sound/machines/terminal_alert.ogg', 50)
		return ..()
	var/dust = FALSE
	for(var/check_content in target_turf.contents)
		if(isobserver(check_content))
			continue
		if(!ismovable(check_content))
			continue
		if(is_type_in_typecache(check_content, high_risk_teleporting))
			playsound(src, 'sound/machines/terminal_alert.ogg', 50)
			continue
		var/atom/movable/movable_content = check_content
		if(isliving(movable_content) && !emagged)
			playsound(src, 'sound/machines/terminal_alert.ogg', 50)
			continue
		if(HAS_TRAIT(movable_content, TRAIT_NO_TELEPORT))
			playsound(src, 'sound/machines/terminal_alert.ogg', 50)
			continue
		if(length(movable_content.get_all_contents_type(/mob/living)) && !emagged)
			playsound(src, 'sound/machines/terminal_alert.ogg', 50)
			continue
		if(length(typecache_filter_list(movable_content.get_all_contents_type(/obj/item), high_risk_teleporting)))
			playsound(src, 'sound/machines/terminal_alert.ogg', 50)
			continue
		if(movable_content.anchored)
			continue
		if(length(movable_content.get_all_contents_type(/obj/item/cargo_teleporter)))
			playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, 1)
			say("Teleportation error detected. Do not try teleport teleporter.")
			continue
		dust = TRUE
		do_teleport(movable_content, moving_turf, asoundout = 'sound/magic/Disable_Tech.ogg')
	if(dust)
		new /obj/effect/decal/cleanable/ash(target_turf)
		ctcell.use(chargecost)
		say("Teleportation successful. [round(ctcell.charge/chargecost)] charge\s left.")
		cooldown_in_seconds -= (manipulator.rating * 2)
		COOLDOWN_START(src, use_cooldown, cooldown_in_seconds)

/obj/effect/decal/cleanable/cargo_mark
	name = "cargo mark"
	desc = "A mark left behind by a cargo teleporter, which allows targeted teleportation. Can be removed by the cargo teleporter."
	icon = 'modular_dripstation/icons/obj/cargo/cargo_teleporter.dmi'
	icon_state = "marker"
	///the reference to the item that spawned the cargo mark
	var/obj/item/cargo_teleporter/parent_item

	light_range = 3
	light_color = COLOR_VIVID_YELLOW

/obj/effect/decal/cleanable/cargo_mark/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/cargo_teleporter))
		to_chat(user, span_notice("You remove [src] using [W]."))
		playsound(src, 'sound/machines/click.ogg', 50)
		if(parent_item.choice)
			if(get_turf(parent_item.choice) == get_turf(src))
				parent_item.choice = null
		qdel(src)
		return
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Destroy()
	if(parent_item)
		parent_item.marker_children -= src
		if(parent_item.choice)
			if(get_turf(parent_item.choice) == get_turf(src))
				parent_item.choice = null
	GLOB.cargo_marks -= src
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	var/area/src_area = get_area(src)
	name = "[src_area.name] ([rand(100000,999999)])"
	GLOB.cargo_marks += src
