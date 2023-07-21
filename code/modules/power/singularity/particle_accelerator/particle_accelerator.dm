/*Composed of 7 parts :

 3 Particle Emitters
 1 Power Box
 1 Fuel Chamber
 1 End Cap
 1 Control computer

 Setup map

   |EC|
 CC|FC|
   |PB|
 PE|PE|PE

*/
#define PA_CONSTRUCTION_UNSECURED  0
#define PA_CONSTRUCTION_UNWIRED    1
#define PA_CONSTRUCTION_PANEL_OPEN 2
#define PA_CONSTRUCTION_COMPLETE   3

/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'yogstation/icons/obj/machines/particle_accelerator.dmi'//Yogs PA Sprites
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 80)

	var/obj/machinery/particle_accelerator/control_box/master = null
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/reference = null
	var/powered = 0
	var/strength = null

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += "Looks like it's not attached to the flooring."
		if(PA_CONSTRUCTION_UNWIRED)
			. += "It is missing some cables."
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += "The panel is open."

/obj/structure/particle_accelerator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/structure/particle_accelerator/Destroy()
	construction_state = PA_CONSTRUCTION_UNSECURED
	if(master)
		master.connected_parts -= src
		master.assembled = 0
		master = null
	return ..()

/obj/structure/particle_accelerator/attackby(obj/item/W, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(W.tool_behaviour == TOOL_WRENCH && !isinspace())
				if(W.use_tool(src, user, 0.8 SECONDS, volume = 75))
					anchored = TRUE
					user.visible_message("[user.name] secures the [name] to the floor.", \
						"You secure the external bolts.")
					construction_state = PA_CONSTRUCTION_UNWIRED

		if(PA_CONSTRUCTION_UNWIRED)
			if(W.tool_behaviour == TOOL_WRENCH)
				if(W.use_tool(src, user, 0.8 SECONDS, volume = 75))
					anchored = FALSE
					user.visible_message("[user.name] detaches the [name] from the floor.", \
						"You remove the external bolts.")
					construction_state = PA_CONSTRUCTION_UNSECURED

			else if(istype(W, /obj/item/stack/cable_coil))
				if(!W.tool_start_check(user, amount = 1))
					return
				to_chat(user, span_notice("You start to add cables to the frame..."))
				if(W.use_tool(src, user, 0.8 SECONDS, volume = 50, amount = 1))
					user.visible_message("[user.name] adds wires to the [name].", \
						"You add some wires.")
					construction_state = PA_CONSTRUCTION_PANEL_OPEN

		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				if(W.use_tool(src, user, 0.4 SECONDS, volume = 75))
					user.visible_message("[user.name] removes some wires from the [name].", \
						"You remove some wires.")
					construction_state = PA_CONSTRUCTION_UNWIRED

			else if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] closes the [name]'s access panel.", \
					"You close the access panel.")
				construction_state = PA_CONSTRUCTION_COMPLETE

		if(PA_CONSTRUCTION_COMPLETE)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] opens the [name]'s access panel.", \
					"You open the access panel.")
				construction_state = PA_CONSTRUCTION_PANEL_OPEN

	update_state()
	update_appearance(UPDATE_ICON)


/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/structure/particle_accelerator/Move()
	. = ..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.", INVESTIGATE_SINGULO)


/obj/structure/particle_accelerator/update_icon_state()
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED,PA_CONSTRUCTION_UNWIRED)
			icon_state="[reference]"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			icon_state="[reference]w"
		if(PA_CONSTRUCTION_COMPLETE)
			if(powered)
				icon_state="[reference]p[strength]"
			else
				icon_state="[reference]c"

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()

/obj/structure/particle_accelerator/proc/connect_master(obj/O)
	if(O.dir == dir)
		master = O
		return 1
	return 0

///////////
// PARTS //
///////////


/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc = "This is where Alpha particles are generated from \[REDACTED\]."
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc = "This uses electromagnetic waves to focus the Alpha particles."
	icon = 'yogstation/icons/obj/machines/particle_accelerator.dmi'//Yogs PA Sprites
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc = "This is where the Alpha particles are accelerated to <b><i>radical speeds</i></b>."
	icon = 'yogstation/icons/obj/machines/particle_accelerator.dmi'//Yogs PA Sprites
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"
