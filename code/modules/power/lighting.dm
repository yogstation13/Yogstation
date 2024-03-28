// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)

#define LIGHT_EMERGENCY_POWER_USE 0.2 //How much power emergency lights will consume per tick
// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

#define BROKEN_SPARKS_MIN (3 MINUTES)
#define BROKEN_SPARKS_MAX (9 MINUTES)

#define LIGHT_ON_DELAY_UPPER 3 SECONDS
#define LIGHT_ON_DELAY_LOWER 1 SECONDS

/obj/item/wallframe/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	result_path = /obj/structure/light_construct
	inverse = TRUE

/obj/item/wallframe/light_fixture/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	result_path = /obj/structure/light_construct/small
	materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)

/obj/item/wallframe/light_fixture/try_build(turf/on_wall, user)
	if(!..())
		return
	var/area/local_area = get_area(user)
	if(!local_area.static_lighting)
		to_chat(user, span_warning("You cannot place [src] in this area!"))
		return
	return TRUE


/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 200
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)

	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null
	var/obj/item/stock_parts/cell/cell

	var/cell_connectors = TRUE

/obj/structure/light_construct/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)

/obj/structure/light_construct/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/structure/light_construct/get_cell()
	return cell

/obj/structure/light_construct/examine(mob/user)
	. = ..()
	switch(stage)
		if(1)
			. += "It's an empty frame."
		if(2)
			. += "It's wired."
		if(3)
			. += "The casing is closed."
	if(cell_connectors)
		if(cell)
			. += "You see [cell] inside the casing."
		else
			. += "The casing has no power cell for backup power."
	else
		. += span_danger("This casing doesn't support power cells for backup power.")

/obj/structure/light_construct/attack_hand(mob/user)
	if(cell)
		user.visible_message("[user] removes [cell] from [src]!",span_notice("You remove [cell]."))
		user.put_in_hands(cell)
		cell.update_appearance()
		cell = null
		add_fingerprint(user)

/obj/structure/light_construct/attack_tk(mob/user)
	if(cell)
		to_chat(user, span_notice("You telekinetically remove [cell]."))
		cell.forceMove(drop_location())
		cell.attack_tk(user)
		cell = null

/obj/structure/light_construct/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell_connectors)
			to_chat(user, span_warning("This [name] can't support a power cell!"))
			return
		if(HAS_TRAIT(W, TRAIT_NODROP))
			to_chat(user, span_warning("[W] is stuck to your hand!"))
			return
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
		else if(user.temporarilyRemoveItemFromInventory(W))
			user.visible_message(span_notice("[user] hooks up [W] to [src]."), \
			span_notice("You add [W] to [src]."))
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			W.forceMove(src)
			cell = W
			add_fingerprint(user)
		return
	else if (istype(W, /obj/item/light))
		to_chat(user, span_warning("This [name] isn't finished being setup!"))
		return

	switch(stage)
		if(1)
			if(W.tool_behaviour == TOOL_WRENCH)
				if(cell)
					to_chat(user, span_warning("You have to remove the cell first!"))
					return
				else
					to_chat(user, span_notice("You begin deconstructing [src]..."))
					if (W.use_tool(src, user, 30, volume=50))
						new /obj/item/stack/sheet/metal(drop_location(), sheets_refunded)
						user.visible_message("[user.name] deconstructs [src].", \
							span_notice("You deconstruct [src]."), span_italics("You hear a ratchet."))
						playsound(src, 'sound/items/deconstruct.ogg', 75, 1)
						qdel(src)
					return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.use(1))
					icon_state = "[fixture_type]-construct-stage2"
					stage = 2
					user.visible_message("[user.name] adds wires to [src].", \
						span_notice("You add wires to [src]."))
				else
					to_chat(user, span_warning("You need one length of cable to wire [src]!"))
				return
		if(2)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(usr, span_warning("You have to remove the wires first!"))
				return

			if(W.tool_behaviour == TOOL_WIRECUTTER)
				stage = 1
				icon_state = "[fixture_type]-construct-stage1"
				new /obj/item/stack/cable_coil(drop_location(), 1, "red")
				user.visible_message("[user.name] removes the wiring from [src].", \
					span_notice("You remove the wiring from [src]."), span_italics("You hear clicking."))
				W.play_tool_sound(src, 100)
				return

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] closes [src]'s casing.", \
					span_notice("You close [src]'s casing."), span_italics("You hear screwing."))
				W.play_tool_sound(src, 75)
				switch(fixture_type)
					if("tube")
						newlight = new /obj/machinery/light/built(loc)
					if("bulb")
						newlight = new /obj/machinery/light/small/built(loc)
					if("floor")
						newlight = new /obj/machinery/light/floor/built(loc)
				newlight.setDir(dir)
				transfer_fingerprints_to(newlight)
				if(cell)
					newlight.cell = cell
					cell.forceMove(newlight)
					cell = null
				qdel(src)
				return
	return ..()

/obj/structure/light_construct/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)


/obj/structure/light_construct/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)
	qdel(src)

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1

/obj/structure/light_construct/floor
	name = "floor light fixture frame"
	icon_state = "floor-construct-stage1"
	fixture_type = "floor"
	sheets_refunded = 1
	layer = LOW_OBJ_LAYER

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	///Lights are calc'd via area so they dont need to be in the machine list
	power_channel = AREA_USAGE_LIGHT
	///What overlay the light should use
	var/overlay_icon = 'icons/obj/lighting_overlay.dmi'
	///base description and icon_state
	var/base_state = "tube"
	///Is the light on?
	var/on = FALSE
	var/on_gs = FALSE
	var/forced_off = FALSE
	var/static_power_used = 0
	///Luminosity when on, also used in power calculation
	var/brightness = 8
	///Basically the alpha of the emitted light source
	var/bulb_power = 1
	///Default colour of the light.
	var/bulb_colour = LIGHT_COLOR_DEFAULT
	///LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/status = LIGHT_OK
	///Should we flicker?
	var/flickering = FALSE
	///The type of light item
	var/light_type = /obj/item/light/tube
	///String of the light type, used in descriptions and in examine
	var/fitting = "tube"
	///Count of number of times switched on/off, this is used to calculate the probability the light burns out
	var/switchcount = 0
	///true if rigged to explode
	var/rigged = FALSE

	///Cell reference
	var/obj/item/stock_parts/cell/cell
	///If true, this fixture generates a very weak cell at roundstart
	var/start_with_cell = TRUE

	///Currently in night shift mode?
	var/nightshift_enabled = FALSE
	///Set to FALSE to never let this light get switched to night mode.
	var/nightshift_allowed = TRUE
	///Brightness of the nightshift light
	var/nightshift_brightness = 8
	///Alpha of the nightshift light
	var/nightshift_light_power = 0.45
	///Basecolor of the nightshift light
	var/nightshift_light_color = "#FFDDCC"

	var/nightshift_powercheck = FALSE

	///if true, the light is in emergency mode
	var/emergency_mode = FALSE	
	///if true, this light cannot ever have an emergency mode
	var/no_emergency = FALSE	
	///Multiplier for this light's base brightness during a cascade
	var/bulb_emergency_brightness_mul = 0.25
	///Colour of the light when major emergency mode is on
	var/bulb_emergency_colour = "#ff4e4e"
	///the multiplier for determining the light's power in emergency mode
	var/bulb_emergency_pow_mul = 0.75
	///the minimum value for the light's power in emergency mode
	var/bulb_emergency_pow_min = 0.5

	///colour of the light when air alarm is set to severe
	var/bulb_vacuum_colour = "#4F82FF"	
	var/bulb_vacuum_brightness = 8

	///More stress stuff.
	var/turning_on = FALSE

	///Flicker cooldown
	COOLDOWN_DECLARE(flicker_cooldown)

/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/small/broken
	status = LIGHT_BROKEN
	icon_state = "bulb-broken"

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		break_light_tube(TRUE)
	return ..()

/obj/machinery/light/built
	status = LIGHT_EMPTY
	icon_state = "tube-empty"
	start_with_cell = FALSE

/obj/machinery/light/floor/built
	status = LIGHT_EMPTY
	icon_state = "floor-empty"
	start_with_cell = FALSE

/obj/machinery/light/small/built
	status = LIGHT_EMPTY
	icon_state = "bulb-empty"
	start_with_cell = FALSE

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()
	GLOB.lights += src

	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_light))

	//Setup area colours -pb
	var/area/our_area = get_room_area()
	if(bulb_colour == initial(bulb_colour))
		if(istype(src, /obj/machinery/light/small))
			bulb_colour = our_area.lighting_colour_bulb
		else
			bulb_colour = our_area.lighting_colour_tube

	if(nightshift_light_color == initial(nightshift_light_color))
		nightshift_light_color = our_area.lighting_colour_night

	if(!mapload) //sync up nightshift lighting for player made lights
		var/obj/machinery/power/apc/temp_apc = our_area.get_apc()
		nightshift_enabled = temp_apc?.nightshift_lights

	if(start_with_cell && !no_emergency)
		cell = new/obj/item/stock_parts/cell/emergency_light(src)

	// Light projects out backwards from the dir of the light
	set_light(l_dir = REVERSE_DIR(dir))

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/LateInitialize()
	. = ..()
	switch(fitting)
		if("tube")
			if(prob(2))
				break_light_tube(TRUE)
		if("bulb")
			if(prob(5))
				break_light_tube(TRUE)
	update(trigger = FALSE)

	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))

/obj/machinery/light/Destroy()
	GLOB.lights.Remove(src)
	var/area/A = get_area(src)
	if(A)
		on = FALSE && !forced_off
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/setDir(newdir)
	. = ..()
	set_light(l_dir = REVERSE_DIR(dir))

/obj/machinery/light/update_icon_state(updates=ALL)
	switch(status)		// set icon_states
		if(LIGHT_OK)
			if(forced_off)
				icon_state = "[base_state]"
				return
			var/area/A = get_area(src)
			if(emergency_mode || (A && (A.fire || A.delta_light)))
				icon_state = "[base_state]_emergency"
			else if (A && A.vacuum)
				icon_state = "[base_state]_vacuum"
			else
				icon_state = "[base_state]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	return ..()

/obj/machinery/light/update_overlays()
	. = ..()
	if(!on || status != LIGHT_OK)
		return

	. += emissive_appearance(overlay_icon, "[base_state]", src, alpha = src.alpha)

	var/area/local_area = get_room_area()

	if(emergency_mode || (local_area?.fire))
		. += mutable_appearance(overlay_icon, "[base_state]_emergency")
		return
	if(nightshift_enabled)
		. += mutable_appearance(overlay_icon, "[base_state]_nightshift")
		return
	. += mutable_appearance(overlay_icon, base_state)

/obj/machinery/light/proc/clean_light(O,strength)
	if(strength < CLEAN_TYPE_BLOOD)
		return
	var/area/A = get_area(src)
	if(istype(src, /obj/machinery/light/small))
		bulb_colour = A.lighting_colour_bulb
	else
		bulb_colour = A.lighting_colour_tube
	update()

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE, quiet = FALSE, instant = FALSE)
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	emergency_mode = FALSE
	if(on)
		if(instant)
			turn_on(trigger, quiet)
		else if(!turning_on)
			turning_on = TRUE
			addtimer(CALLBACK(src, PROC_REF(turn_on), trigger, quiet), rand(LIGHT_ON_DELAY_LOWER, LIGHT_ON_DELAY_UPPER))
	else if(has_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		emergency_mode = TRUE
		START_PROCESSING(SSmachines, src)
	else
		set_light(l_range = 0)

	active_power_usage = (brightness * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = brightness * 20 //20W per unit luminosity
			addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
			nightshift_powercheck = FALSE

	if(on)
		if(nightshift_enabled != nightshift_powercheck)
			nightshift_powercheck = nightshift_enabled
			if(nightshift_enabled)
				removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
				static_power_used =	brightness * 8 //8W per unit luminosity
				addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
			else
				removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
				static_power_used = brightness * 20 //20W per unit luminosity
				addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
	update_appearance()
	broken_sparks(start_only=TRUE)

/obj/machinery/light/proc/turn_on(trigger, quiet = FALSE)
	if(QDELETED(src))
		return FALSE
	turning_on = FALSE
	if(!on)
		return FALSE

	var/brightness_set = brightness
	var/power_set = bulb_power
	var/color_set = bulb_colour
	if(color)
		color_set = color
	var/area/A = get_area(src)
	if (A && (A.fire || A.delta_light))
		color_set = bulb_emergency_colour
	else if (A && A.vacuum)
		color_set = bulb_vacuum_colour
		brightness_set = bulb_vacuum_brightness
	else if (nightshift_enabled)
		brightness_set = nightshift_brightness
		power_set = nightshift_light_power
		if(!color)
			color_set = nightshift_light_color
	var/matching = light && brightness_set == light.light_range && power_set == light.light_power && color_set == light.light_color
	if(!matching)
		switchcount++
		if(rigged)
			if(status == LIGHT_OK && trigger)
				explode()
		else if( prob( min(60, (switchcount^2)*0.01) ) )
			if(trigger)
				burn_out()
		else
			set_light(
				l_range = brightness_set,
				l_power = power_set,
				l_color = color_set
				)
			if(!quiet)
				playsound(src.loc, 'sound/effects/light_on.ogg', 50)
	update_appearance()
	broken_sparks(start_only=TRUE)

/obj/machinery/light/update_atom_colour()
	..()
	update()

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	if(!QDELETED(src) && status == LIGHT_BROKEN && has_power() && MC_RUNNING())
		if(!start_only)
			do_sparks(3, TRUE, src)
		var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
		addtimer(CALLBACK(src, PROC_REF(broken_sparks)), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/process()
	if (!cell)
		return PROCESS_KILL
	if(has_power())
		if (cell.charge == cell.maxcharge)
			return PROCESS_KILL
		cell.charge = min(cell.maxcharge, cell.charge + LIGHT_EMERGENCY_POWER_USE) //Recharge emergency power automatically while not using it
	if(emergency_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE))
		update(FALSE) //Disables emergency mode and sets the color to normal

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(l_range = 0)
		playsound(src.loc, 'sound/effects/burnout.ogg', 65)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/set_on(turn_on)
	on = (turn_on && status == LIGHT_OK)
	update()

/obj/machinery/light/get_cell()
	return cell

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			. += "It is turned [on? "on" : "off"]."
		if(LIGHT_EMPTY)
			. += "The [fitting] has been removed."
		if(LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "The [fitting] has been smashed."
	if(cell)
		. += "Its backup power charge meter reads [round((cell.charge / cell.maxcharge) * 100, 0.1)]%."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/tool, mob/living/user, params)

	//Light replacer code
	if(istype(tool, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/LR = tool
		LR.ReplaceLight(src, user)
		return

	// attempt to insert light
	if(istype(tool, /obj/item/light))
		if(status == LIGHT_OK)
			to_chat(user, span_warning("There is a [fitting] already inserted!"))
			return
		add_fingerprint(user)
		var/obj/item/light/light_object = tool
		if(!istype(light_object, light_type))
			to_chat(user, span_warning("This type of light requires a [fitting]!"))
			return

		if(!user.temporarilyRemoveItemFromInventory(light_object))
			return

		add_fingerprint(user)
		if(status != LIGHT_EMPTY)
			drop_light_tube(user)
			to_chat(user, span_notice("You replace [light_object]."))
		else
			to_chat(user, span_notice("You insert [light_object]."))
		status = light_object.status
		switchcount = light_object.switchcount
		rigged = light_object.rigged
		brightness = light_object.brightness
		on = has_power() && !forced_off
		update()

		qdel(light_object)

		return

	// hit the light socket with umbral tendrils, instantly breaking the light as opposed to RNG //yogs
	if(istype(tool, /obj/item/umbral_tendrils))
		break_light_tube()
		return ..() //yogs end

	// attempt to stick weapon into light socket
	if(status != LIGHT_EMPTY)
		return ..()
	if(tool.tool_behaviour == TOOL_SCREWDRIVER) //If it's a screwdriver open it.
		tool.play_tool_sound(src, 75)
		user.visible_message("[user.name] opens [src]'s casing.", \
			span_notice("You open [src]'s casing."), span_italics("You hear a noise."))
		deconstruct()
		return
	
	to_chat(user, span_userdanger("You stick \the [tool] into the light socket!"))
	if(has_power() && (tool.flags_1 & CONDUCT_1))
		do_sparks(3, TRUE, src)
		if (prob(75))
			electrocute_mob(user, get_area(src), src, (rand(7,10) * 0.1), TRUE)

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		qdel(src)
		return
	var/obj/structure/light_construct/newlight = null
	var/current_stage = 2
	if(!disassembled)
		current_stage = 1
	switch(fitting)
		if("tube")
			newlight = new /obj/structure/light_construct(loc)
			newlight.icon_state = "tube-construct-stage[current_stage]"

		if("bulb")
			newlight = new /obj/structure/light_construct/small(loc)
			newlight.icon_state = "bulb-construct-stage[current_stage]"

		if("floor bulb")
			newlight = new /obj/structure/light_construct/floor(loc)
			newlight.icon_state = "floor-construct-stage[current_stage]"
	newlight.setDir(dir)
	newlight.stage = current_stage
	if(!disassembled)
		newlight.update_integrity(newlight.max_integrity * 0.5)
		if(status != LIGHT_BROKEN)
			break_light_tube()
		if(status != LIGHT_EMPTY)
			drop_light_tube()
		new /obj/item/stack/cable_coil(loc, 1, "red")
	transfer_fingerprints_to(newlight)
	
	if(cell)
		newlight.cell = cell
		cell.forceMove(newlight)
		cell = null
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user)
	..()
	if(status == LIGHT_BROKEN || status == LIGHT_EMPTY)
		if(on && (I.flags_1 & CONDUCT_1) && !forced_off)
			if(prob(12))
				electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/light/proc/on_light_eater(obj/machinery/light/source, datum/light_eater)
	SIGNAL_HANDLER
	if(status != LIGHT_EMPTY)
		var/obj/item/light/tube = drop_light_tube()
		tube?.burn()
	return COMPONENT_BLOCK_LIGHT_EATER
// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/A = get_area(src)
	return !A.lightswitch && A.power_light || flickering

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

// returns whether this light has emergency power
// can also return if it has access to a certain amount of that power
/obj/machinery/light/proc/has_emergency_power(pwr)
	if(no_emergency || !cell)
		return FALSE
	if(pwr ? cell.charge >= pwr : cell.charge)
		return status == LIGHT_OK

// attempts to use power from the installed emergency cell, returns true if it does and false if it doesn't
/obj/machinery/light/proc/use_emergency_power(pwr = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(pwr))
		return FALSE
	if(cell.charge > 300) //it's meant to handle 120 W, ya doofus
		visible_message(span_warning("[src] short-circuits from too powerful of a power cell!"))
		burn_out()
		return FALSE
	cell.use(pwr)
	set_light(brightness * bulb_emergency_brightness_mul, max(bulb_emergency_pow_min, bulb_emergency_pow_mul * (cell.charge / cell.maxcharge)), bulb_emergency_colour)
	return TRUE


/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	set waitfor = 0
	if(flickering || !COOLDOWN_FINISHED(src, flicker_cooldown))
		return
	COOLDOWN_START(src, flicker_cooldown, 10 SECONDS)
	flickering = 1
	if(on && status == LIGHT_OK)
		for(var/i = 0; i < amount; i++)
			if(status != LIGHT_OK)
				break
			on = !on
			update(FALSE)
			sleep(rand(0.5, 1.5) SECONDS)
		on = (status == LIGHT_OK) && !forced_off
		update(FALSE)
	flickering = 0

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	no_emergency = !no_emergency
	to_chat(user, span_notice("Emergency lights for this fixture have been [no_emergency ? "disabled" : "enabled"]."))
	update(FALSE)
	return

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits
	if(!on)
		to_chat(user, span_notice("You remove the light [fitting]."))
		// create a light tube/bulb item and put it in the user's hand
		drop_light_tube(user)
		return
		
	var/protected = FALSE
	var/mob/living/carbon/human/H = user

	if(istype(H))
		if(isethereal(H))
			to_chat(H, span_notice("You start channeling some power through the [fitting] into your body."))
			if(do_after(user, 1 SECONDS, src))
				if(istype(H.getorganslot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/cell))
					to_chat(H, span_notice("You receive some charge from the [fitting]."))
					H.adjust_nutrition(100)
				else
					to_chat(H, span_notice("You can't receive charge from the [fitting]."))
			return

		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.max_heat_protection_temperature)
				protected = (G.max_heat_protection_temperature > 360)
	else
		protected = TRUE

	if(protected > FALSE || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		to_chat(user, span_notice("You remove the light [fitting]."))
	else if(istype(user) && user.dna.check_mutation(TK))
		to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	else
		var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
		if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
			H.update_damage_overlays()
		to_chat(user, span_warning("You try to remove the light [fitting], but you burn your hand on it!"))
		return				// if burned, don't remove the light
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/light_object = new light_type()
	
	light_object.status = status
	light_object.rigged = rigged
	light_object.brightness = brightness

	// light item inherits the switchcount, then zero it
	light_object.switchcount = switchcount
	switchcount = 0

	light_object.update_appearance()
	light_object.forceMove(loc)

	if(user) //puts it in our active hand
		light_object.add_fingerprint(user)
		user.put_in_active_hand(light_object)

	status = LIGHT_EMPTY
	update()
	return light_object

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/L = drop_light_tube()
	L.attack_tk(user)

/obj/machinery/light/attack_eminence(mob/camera/eminence/user, params)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return
		
	to_chat(user, span_brass("You concentrate your power, trying to break [src]..."))
	if(!do_after(user, 2 SECONDS, src))
		return
	to_chat(user, span_brass("You sucessfully break [src]!"))
	break_light_tube(FALSE)

// break the light and make sparks if was on

/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = FALSE)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(on)
			do_sparks(3, TRUE, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	brightness = initial(brightness)
	on = TRUE && !forced_off
	update()

/obj/machinery/light/tesla_act(power, tesla_flags, shocked_targets, zap_gib = FALSE)
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		explosion(src,0,0,0,flame_range = 5, adminlog = 0)
		qdel(src)
	else
		return ..()

// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	set_on(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

// explode the light

/obj/machinery/light/proc/explode()
	set waitfor = 0
	var/turf/T = get_turf(src.loc)
	break_light_tube()	// break it first to give a warning
	sleep(0.2 SECONDS)
	explosion(T, 0, 1, 2, 4)
	sleep(0.1 SECONDS)
	qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/glass=100)
	grind_results = list(/datum/reagent/silicon = 5, /datum/reagent/nitrogen = 10) //Nitrogen is used as a cheaper alternative to argon in incandescent lighbulbs
	///How much light it gives off
	var/brightness = 2
	///LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/status = LIGHT_OK
	///Base icon state for each bulb types
	var/base_state
	///Number of times switched on and off
	var/switchcount = 0
	///True if rigged to explode
	var/rigged = FALSE		

/obj/item/light/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = force)
	update_icon_state()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/light/suicide_act(mob/living/carbon/user)
	if (status == LIGHT_BROKEN)
		user.visible_message(span_suicide("[user] begins to stab [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS
	else
		user.visible_message(span_suicide("[user] begins to eat \the [src]! It looks like [user.p_theyre()] not very bright!"))
		shatter()
		return BRUTELOSS

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	brightness = 8

/obj/item/light/tube/broken
	status = LIGHT_BROKEN
	sharpness = SHARP_POINTY

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	brightness = 4

/obj/item/light/bulb/broken
	status = LIGHT_BROKEN
	sharpness = SHARP_POINTY

/obj/item/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //not caught by a mob
		shatter()

// update the icon state and description of the light

/obj/item/light/update_icon_state()
	. = ..()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"

/obj/item/light/update_desc()
	. = ..()
	switch(status)
		if(LIGHT_OK)
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			desc = "A broken [name]."


/obj/item/light/proc/on_entered(datum/source, atom/movable/moving_atom)
	SIGNAL_HANDLER
	if(!isliving(moving_atom))
		return
	var/mob/living/moving_mob = moving_atom
	if(!(moving_mob.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || moving_mob.buckled)
		playsound(src, 'sound/effects/glass_step.ogg', HAS_TRAIT(moving_mob, TRAIT_LIGHT_STEP) ? 30 : 50, TRUE)
		if(status == LIGHT_BURNED || status == LIGHT_OK)
			shatter(moving_mob)

// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
/obj/item/light/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I

		to_chat(user, span_notice("You inject the solution into \the [src]."))

		if(S.reagents.has_reagent(/datum/reagent/toxin/plasma, 5))

			rigged = TRUE

		S.reagents.clear_reagents()
	else
		..()
	return

/obj/item/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter()

/obj/item/light/attack_atom(obj/O, mob/living/user)
	..()
	shatter()

/obj/item/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message(span_danger("[src] shatters."),span_italics("You hear a small glass object shatter."))
		status = LIGHT_BROKEN
		force = 5
		sharpness = SHARP_POINTY
		playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(rigged)
			atmos_spawn_air("plasma=5") //5u of plasma are required to rig a light bulb/tube
		update_appearance(UPDATE_DESC | UPDATE_ICON)


/obj/machinery/light/floor
	name = "floor light"
	icon = 'icons/obj/lighting.dmi'
	base_state = "floor"		// base description and icon_state
	icon_state = "floor"
	brightness = 4
	light_angle = 360
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	light_type = /obj/item/light/bulb
	fitting = "floor bulb"

/obj/item/floor_light
	name = "floor light frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floor-construct-stage1"

/obj/item/floor_light/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use in-hand to place a [src].\n"

/obj/item/floor_light/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need more space to place a [src] here."))
		return
	if((locate(/obj/machinery/light/floor) in user.loc) || (locate(/obj/structure/light_construct/floor) in user.loc))
		to_chat(user, span_warning("There is already a [src] here."))
		return
	to_chat(user, span_notice("You anchor the [src] in place."))
	playsound(user, 'sound/machines/click.ogg', 50, 1)
	var/obj/structure/light_construct/floor/M = new(user.loc)
	transfer_fingerprints_to(M)
	qdel(src)

/proc/flicker_all_lights() //not QUITE all lights, but it reduces lag
	for(var/obj/machinery/light/L in GLOB.machines)
		if(is_station_level(L.z) && prob(50))
			addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(3, 6)), rand(0, 15))

#undef LIGHT_ON_DELAY_UPPER
#undef LIGHT_ON_DELAY_LOWER
