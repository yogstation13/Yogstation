//update_state
#define UPSTATE_CELL_IN		(1<<0)
#define UPSTATE_OPENED1		(1<<1)
#define UPSTATE_OPENED2		(1<<2)
#define UPSTATE_MAINT		(1<<3)
#define UPSTATE_BROKE		(1<<4)
#define UPSTATE_BLUESCREEN	(1<<5)
#define UPSTATE_WIREEXP		(1<<6)
#define UPSTATE_ALLGOOD		(1<<7)

#define APC_RESET_EMP "emp"

//update_overlay
#define APC_UPOVERLAY_CHARGEING0	(1<<0)
#define APC_UPOVERLAY_CHARGEING1	(1<<1)
#define APC_UPOVERLAY_CHARGEING2	(1<<2)
#define APC_UPOVERLAY_EQUIPMENT0	(1<<3)
#define APC_UPOVERLAY_EQUIPMENT1	(1<<4)
#define APC_UPOVERLAY_EQUIPMENT2	(1<<5)
#define APC_UPOVERLAY_LIGHTING0		(1<<6)
#define APC_UPOVERLAY_LIGHTING1		(1<<7)
#define APC_UPOVERLAY_LIGHTING2		(1<<8)
#define APC_UPOVERLAY_ENVIRON0		(1<<9)
#define APC_UPOVERLAY_ENVIRON1		(1<<10)
#define APC_UPOVERLAY_ENVIRON2		(1<<11)
#define APC_UPOVERLAY_LOCKED		(1<<12)
#define APC_UPOVERLAY_OPERATING		(1<<13)

#define APC_ELECTRONICS_MISSING 0 // None
#define APC_ELECTRONICS_INSTALLED 1 // Installed but not secured
#define APC_ELECTRONICS_SECURED 2 // Installed and secured

#define APC_COVER_CLOSED 0
#define APC_COVER_OPENED 1
#define APC_COVER_REMOVED 2

#define APC_NOT_CHARGING 0
#define APC_CHARGING 1
#define APC_FULLY_CHARGED 2

//Ethereal stuff
#define APC_POWER_GAIN 250			///amount of power transferred to an APC by an overcharging Ethereal

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire connection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto

/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area's electrical systems."

	icon_state = "apc0"
	use_power = NO_POWER_USE
	req_access = list(ACCESS_ENGINE_EQUIP) // Yogs -- changed to allow for use of req_one_access
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	clicksound = 'sound/machines/terminal_select.ogg'
	works_with_rped_anyways = TRUE
	FASTDMM_PROP(\
		set_instance_vars(\
			pixel_x = dir == EAST ? 24 : (dir == WEST ? -25 : INSTANCE_VAR_DEFAULT),\
			pixel_y = dir == NORTH ? 23 : (dir == SOUTH ? -23 : INSTANCE_VAR_DEFAULT)\
		),\
		dir_amount = 4\
    )

	var/light_on_range = 1.5
	var/area/area
	var/areastring = null
	var/obj/item/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = /obj/item/stock_parts/cell/upgraded		//Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	var/opened = APC_COVER_CLOSED
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = TRUE
	var/charging = APC_NOT_CHARGING
	var/chargemode = 1
	var/chargecount = 0
	var/locked = TRUE
	var/coverlocked = TRUE
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/has_electronics = APC_ELECTRONICS_MISSING // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/transfer_in_progress = FALSE //Is there an AI being transferred out of us?
	var/obj/item/clockwork/integration_cog/integration_cog //Is there a cog siphoning power?
	var/longtermpower = 10
	var/auto_name = 0
	var/failure_timer = 0
	var/force_update = 0
	var/emergency_lights = FALSE
	var/nightshift_lights = FALSE
	var/last_light_switch = 0
	var/update_state = -1
	var/update_overlay = -1
	var/icon_update_needed = FALSE
	var/obj/machinery/computer/apc_control/remote_control = null

/obj/machinery/power/apc/unlocked
	locked = FALSE

/obj/machinery/power/apc/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/power/apc/away //general away mission access
	req_access = list(ACCESS_RUINS_GENERAL)

/obj/machinery/power/apc/highcap/five_k
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/machinery/power/apc/highcap/ten_k
	cell_type = /obj/item/stock_parts/cell/high

/obj/machinery/power/apc/highcap/fifteen_k
	cell_type = /obj/item/stock_parts/cell/high/plus

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

/obj/machinery/power/apc/auto_name/north //Pixel offsets get overwritten on New()
	dir = NORTH
	pixel_y = 23

/obj/machinery/power/apc/auto_name/south
	dir = SOUTH
	pixel_y = -23

/obj/machinery/power/apc/auto_name/east
	dir = EAST
	pixel_x = 24

/obj/machinery/power/apc/auto_name/west
	dir = WEST
	pixel_x = -25

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, ndir, building=0, mob/user)
	//if (!req_access)
		//req_access = list(ACCESS_ENGINE_EQUIP) // Yogs -- Commented out to allow for use of req_one_access. Also this is just generally bad and the guy who wrote this doesn't get OOP
	if (!armor)
		armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 10, BOMB = 30, BIO = 100, RAD = 100, FIRE = 90, ACID = 50, ELECTRIC = 100)
	..()
	GLOB.apcs_list += src

	wires = new /datum/wires/apc(src)
	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		setDir(ndir)
	src.tdir = dir		// to fix Vars bug
	setDir(SOUTH)

	if(auto_name)
		name = "\improper [get_area(src)] APC"

	switch(tdir)
		if(NORTH)
			if((pixel_y != initial(pixel_y)) && (pixel_y != 23))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_y value ([pixel_y] - should be 23.)")
			pixel_y = 23
		if(SOUTH)
			if((pixel_y != initial(pixel_y)) && (pixel_y != -23))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_y value ([pixel_y] - should be -23.)")
			pixel_y = -23
		if(EAST)
			if((pixel_y != initial(pixel_x)) && (pixel_x != 24))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_x value ([pixel_x] - should be 24.)")
			pixel_x = 24
		if(WEST)
			if((pixel_y != initial(pixel_x)) && (pixel_x != -25))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_x value ([pixel_x] - should be -25.)")
			pixel_x = -25
	if (building)
		if(user)
			area = get_area(user)
		else
			area = get_area(src)
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "[area.name] APC"
		stat |= MAINT
		addtimer(CALLBACK(src, PROC_REF(update)), 5)
	update_appearance(UPDATE_ICON)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	area.power_light = FALSE
	area.power_equip = FALSE
	area.power_environ = FALSE
	area.poweralert(1, src)
	area.power_change()
	if(occupier)
		malfvacate(1)
	QDEL_NULL(wires)
	if(cell)
		qdel(cell)
	if(terminal)
		disconnect_terminal()
	. = ..()

/obj/machinery/power/apc/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_appearance()
		updateUsrDialog()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.setDir(tdir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	has_electronics = APC_ELECTRONICS_SECURED
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new cell_type
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	var/area/A = get_area(loc)

	//if area isn't specified use current
	if(areastring)
		src.area = get_area_instance_from_text(areastring)
		if(!src.area)
			src.area = A
			stack_trace("Bad areastring path for [src], [src.areastring]")
	else if(isarea(A) && src.areastring == null)
		src.area = A

	if(prob(10))
		locked = FALSE

	make_terminal()

	addtimer(CALLBACK(src, PROC_REF(update)), 5)
	update_appearance()

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		return
	if(opened)
		if(has_electronics && terminal)
			. += "The cover is [opened==APC_COVER_REMOVED?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"]."
		else
			. += {"It's [ !terminal ? "not" : "" ] wired up.\n
			The electronics are[!has_electronics?"n't":""] installed."}
		if(user.Adjacent(src) && integration_cog)
			. += span_warning("[src]'s innards have been replaced by strange brass machinery!")

	else
		if (stat & MAINT)
			. += "The cover is closed. Something is wrong with it. It doesn't work."
		else if (malfhack)
			. += "The cover is broken. It may be hard to force it open."
		else
			. += "The cover is closed."

	if(integration_cog && is_servant_of_ratvar(user))
		. += span_brass("There is an integration cog installed!")

	. += span_notice("Right-Click the APC to [ locked ? "unlock" : "lock"] the interface.")

	if(issilicon(user))
		. += span_notice("Ctrl-Click the APC to switch the breaker [ operating ? "off" : "on"].")

/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if(!opened && !W.works_from_distance)
		return FALSE
	var/current_cell_rating = cell ? cell.get_part_rating() : -1
	var/best_cell_rating = current_cell_rating
	var/obj/item/stock_parts/cell/best_cell
	for(var/C in W.contents)
		var/obj/item/stock_parts/cell/cell = C
		if (!cell || !istype(cell))
			continue
		var/cell_rating = cell.get_part_rating()
		if (cell_rating > best_cell_rating || (cell_rating == best_cell_rating && cell.charge > best_cell.charge))
			best_cell_rating = cell_rating
			best_cell = cell
	if (best_cell)
		if (cell)
			SEND_SIGNAL(W, COMSIG_TRY_STORAGE_INSERT, cell, null, null, TRUE)
			to_chat(user, span_notice("[capitalize(cell.name)] replaced with [best_cell.name]."))
		best_cell.forceMove(src)
		var/amount_to_charge = min(best_cell.maxcharge - best_cell.charge, cell.charge)
		if (cell.use(amount_to_charge))
			best_cell.give(amount_to_charge)
		cell = best_cell
		W.play_rped_sound()

/obj/machinery/power/apc/update_appearance(updates = check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return

	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(update_state & UPSTATE_ALLGOOD)
		switch(charging)
			if(APC_NOT_CHARGING)
				light_color = LIGHT_COLOR_RED
			if(APC_CHARGING)
				light_color = LIGHT_COLOR_BLUE
			if(APC_FULLY_CHARGED)
				light_color = LIGHT_COLOR_GREEN
		set_light(light_on_range)
	else if(update_state & UPSTATE_BLUESCREEN)
		light_color = LIGHT_COLOR_BLUE
		set_light(light_on_range)
	else
		set_light(0)

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon_state()
	. = ..()
	if(update_state & UPSTATE_ALLGOOD)
		icon_state = "apc0"
	else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
		var/basestate = "apc[ cell ? "2" : "1" ]"
		if(update_state & UPSTATE_OPENED1)
			if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
				icon_state = "apcmaint" //disabled APC cannot hold cell
			else
				icon_state = basestate
		else if(update_state & UPSTATE_OPENED2)
			if (update_state & UPSTATE_BROKE || malfhack)
				icon_state = "[basestate]-b-nocover"
			else
				icon_state = "[basestate]-nocover"
	else if(update_state & UPSTATE_BROKE)
		icon_state = "apc-b"
	else if(update_state & UPSTATE_BLUESCREEN)
		icon_state = "apcemag"
	else if(update_state & UPSTATE_WIREEXP)
		icon_state = "apcewires"
	else if(update_state & UPSTATE_MAINT)
		icon_state = "apc0"

/obj/machinery/power/apc/update_overlays()
	. = ..()
	if(!(update_state & UPSTATE_ALLGOOD))
		return

	if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
		. += mutable_appearance(icon, "apcox-[locked]")
		. += emissive_appearance(icon, "apcox-[locked]", src)
		. += mutable_appearance(icon, "apco3-[charging]")
		. += emissive_appearance(icon, "apco3-[charging]", src)
		if(operating)
			. += mutable_appearance(icon, "apco0-[equipment]")
			. += emissive_appearance(icon, "apco0-[equipment]", src)
			. += mutable_appearance(icon, "apco1-[lighting]")
			. += emissive_appearance(icon, "apco1-[lighting]", src)
			. += mutable_appearance(icon, "apco2-[environ]")
			. += emissive_appearance(icon, "apco2-[environ]", src)

/obj/machinery/power/apc/proc/check_updates()
	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened==APC_COVER_OPENED)
			update_state |= UPSTATE_OPENED1
		if(opened==APC_COVER_REMOVED)
			update_state |= UPSTATE_OPENED2
	else if(obj_flags & EMAGGED)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2


	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return
	var/results = NONE
	if(last_update_state != update_state)
		results ^= UPDATE_ICON_STATE
	if(last_update_overlay != update_overlay)
		results ^= UPDATE_OVERLAYS
	return results

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/W)
	. = TRUE
	if (opened)
		if (has_electronics == APC_ELECTRONICS_INSTALLED)
			if (terminal)
				to_chat(user, span_warning("Disconnect the wires first!"))
				return
			W.play_tool_sound(src)
			to_chat(user, span_notice("You attempt to remove the power control board...") )
			if(W.use_tool(src, user, 50))
				if (has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if (stat & BROKEN)
						user.visible_message(\
							"[user.name] has broken the charred power control board inside [src.name]!", //Yogs -- Makes this message a bit more clear
							span_notice("You break the charred power control board and remove the remains."),
							span_italics("You hear a crack."))
						return
					else if (obj_flags & EMAGGED)
						obj_flags &= ~EMAGGED
						user.visible_message(\
							"[user.name] has discarded a sparking power control board from [src.name]!", // Yogs -- Makes this message make more sense.
							span_notice("You discard the emagged power control board."))
						return
					else if (malfhack)
						user.visible_message(\
							"[user.name] has discarded a strange-looking power control board from [src.name]!", //Yogs -- Makes this message make more sense.
							span_notice("You discard the strangely programmed board."))
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(\
							"[user.name] has removed the power control board from [src.name]!",\
							span_notice("You remove the power control board."))
						new /obj/item/electronics/apc(loc)
						return
		else if(integration_cog)
			user.visible_message(span_notice("[user] starts prying [integration_cog] from [src]..."), \
			span_notice("You painstakingly start tearing [integration_cog] out of [src]'s guts..."))
			W.play_tool_sound(src)
			if(W.use_tool(src, user, 100))
				user.visible_message(span_notice("[user] destroys [integration_cog] in [src]!"), \
				span_notice("[integration_cog] comes free with a clank and snaps in two as the machinery returns to normal!"))
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				QDEL_NULL(integration_cog)
			return
		else if (opened!=APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_appearance()
			return
	else if (!(stat & BROKEN))
		if(coverlocked && !(stat & MAINT)) // locked...
			to_chat(user, span_warning("The cover is locked and cannot be opened!"))
			return
		else if (panel_open)
			to_chat(user, span_warning("Exposed wires prevents you from opening it!"))
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return
	else
		W.play_tool_sound(src)
		to_chat(user, span_notice("You attempt to pry off the broken cover..."))
		if(W.use_tool(src, user, 3 SECONDS))
			W.play_tool_sound(src)
			to_chat(user, span_notice("You pry the broken cover off of [src]."))
			opened = APC_COVER_REMOVED
			update_appearance()
			return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!",span_notice("You remove \the [cell]."))
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_appearance()
			cell = null
			charging = APC_NOT_CHARGING
			update_appearance()
			return
		else
			switch (has_electronics)
				if (APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					stat &= ~MAINT
					W.play_tool_sound(src)
					to_chat(user, span_notice("You screw the circuit electronics into place."))
				if (APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					stat |= MAINT
					W.play_tool_sound(src)
					to_chat(user, span_notice("You unfasten the electronics."))
				else
					to_chat(user, span_warning("There is nothing to secure!"))
					return
			update_appearance()
	else if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
		return
	else
		panel_open = !panel_open
		to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
		update_appearance()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/W)
	if (terminal && opened)
		terminal.dismantle(user, W)
		return TRUE


/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/W)
	if (opened && !has_electronics && !terminal)
		if(!W.tool_start_check(user, amount=3))
			return
		user.visible_message("[user.name] welds [src].", \
							span_notice("You start welding the APC frame..."), \
							span_italics("You hear welding."))
		if(W.use_tool(src, user, 50, volume=50, amount=3))
			if ((stat & BROKEN) || opened==APC_COVER_REMOVED)
				new /obj/item/stack/sheet/metal(loc)
				user.visible_message(\
					"[user.name] has cut [src] apart with [W].",\
					span_notice("You disassembled the broken APC frame."))
			else
				new /obj/item/wallframe/apc(loc)
				user.visible_message(\
					"[user.name] has cut [src] from the wall with [W].",\
					span_notice("You cut the APC frame from the wall."))
			qdel(src)
			return TRUE

/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src,user)>1)
		return attack_hand(user)

	if	(istype(W, /obj/item/stock_parts/cell) && opened)
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
			return
		else
			if (stat & MAINT)
				to_chat(user, span_warning("There is no connector for your power cell!"))
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			user.visible_message(\
				"[user.name] has inserted the power cell to [src.name]!",\
				span_notice("You insert the power cell."))
			chargecount = 0
			update_appearance()
	else if (W.GetID())
		togglelock(user)
	else if (istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			CRASH("attackby on APC when it's not on a turf")
		if(host_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			to_chat(user, span_warning("You must remove the floor plating in front of the APC first!"))
			return
		else if (terminal)
			to_chat(user, span_warning("This APC is already wired!"))
			return
		else if (!has_electronics)
			to_chat(user, span_warning("There is nothing to wire!"))
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, span_warning("You need ten lengths of cable for APC!"))
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							span_notice("You start adding cables to the APC frame..."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 2 SECONDS, src))
			if (C.get_amount() < 10 || !C)
				return
			if (C.get_amount() >= 10 && !terminal && opened && has_electronics)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE))
					do_sparks(5, TRUE, src)
					return
				C.use(10)
				to_chat(user, span_notice("You add cables to the APC frame."))
				make_terminal()
				terminal.connect_to_network()
	else if (istype(W, /obj/item/electronics/apc) && opened)
		if (has_electronics)
			to_chat(user, span_warning("There is already a board inside the [src]!"))
			return
		else if (stat & BROKEN)
			to_chat(user, span_warning("You cannot put the board inside, the frame is damaged!"))
			return

		user.visible_message("[user.name] inserts the power control board into [src].", \
							span_notice("You start to insert the power control board into the frame..."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 1 SECONDS, src))
			if(!has_electronics)
				has_electronics = APC_ELECTRONICS_INSTALLED
				locked = FALSE
				to_chat(user, span_notice("You place the power control board inside the frame."))
				qdel(W)
	else if(istype(W, /obj/item/electroadaptive_pseudocircuit) && opened)
		var/obj/item/electroadaptive_pseudocircuit/P = W
		if(!has_electronics)
			if(stat & BROKEN)
				to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
				return
			if(!P.adapt_circuit(user, 50))
				return
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a power control board and click it into place in [src]'s guts."))
			has_electronics = APC_ELECTRONICS_INSTALLED
			locked = FALSE
		else if(!cell)
			if(stat & MAINT)
				to_chat(user, span_warning("There's no connector for a power cell."))
				return
			if(!P.adapt_circuit(user, 500))
				return
			var/obj/item/stock_parts/cell/crap/empty/C = new(src)
			C.forceMove(src)
			cell = C
			chargecount = 0
			user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
			span_warning("Your [P.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
			update_appearance()
		else
			to_chat(user, span_warning("[src] has both electronics and a cell."))
			return
	else if (istype(W, /obj/item/wallframe/apc) && opened)
		if (!(stat & BROKEN || opened==APC_COVER_REMOVED || atom_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, span_warning("You found no reason for repairing this APC"))
			return
		if (!(stat & BROKEN) && opened==APC_COVER_REMOVED) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] replaces missing APC's cover.",\
							span_notice("You begin to replace APC's cover..."))
			if(do_after(user, 2 SECONDS, src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, span_notice("You replace missing APC's cover."))
				qdel(W)
				opened = APC_COVER_OPENED
				update_appearance()
			return
		if (has_electronics)
			to_chat(user, span_warning("You cannot repair this APC until you remove the electronics still inside!"))
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							span_notice("You begin to replace the damaged APC frame..."))
		if(do_after(user, 5 SECONDS, src))
			to_chat(user, span_notice("You replace the damaged APC frame with a new one."))
			qdel(W)
			stat &= ~BROKEN
			update_integrity(max_integrity)
			if (opened==APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_appearance()
	else if(istype(W, /obj/item/clockwork/integration_cog) && is_servant_of_ratvar(user))
		if(integration_cog)
			to_chat(user, span_warning("This APC already has a cog."))
			return
		if(!opened)
			user.visible_message(span_warning("[user] slices [src]'s cover lock, and it swings wide open!"), \
			span_alloy("You slice [src]'s cover lock apart with [W], and the cover swings open."))
			opened = APC_COVER_OPENED
			update_appearance()
		else
			user.visible_message(span_warning("[user] presses [W] into [src]!"), \
			span_alloy("You hold [W] in place within [src], and it slowly begins to warm up..."))
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			if(!do_after(user, 7 SECONDS, src))
				return
			user.visible_message(span_warning("[user] installs [W] in [src]!"), \
			"[span_alloy("Replicant alloy rapidly covers the APC's innards, replacing the machinery.")]<br>\
			[span_brass("This APC will now passively provide power for the cult!")]")
			playsound(user, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)
			user.transferItemToLoc(W, src)
			integration_cog = W
			START_PROCESSING(SSfastprocess, W)
			playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 50, FALSE)
			opened = APC_COVER_CLOSED
			locked = FALSE
			update_appearance()
		return
	else if(istype(W, /obj/item/apc_powercord))
		return //because we put our fancy code in the right places, and this is all in the powercord's afterattack()
	else if(panel_open && !opened && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/power/apc/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	if(ethereal_act(user))
		return
	togglelock(user)

/obj/machinery/power/apc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS)
		if(!has_electronics)
			if(stat & BROKEN)
				to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
		else if(!cell)
			if(stat & MAINT)
				to_chat(user, span_warning("There's no connector for a power cell."))
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 50, "cost" = 10) //16 for a wall
		else
			to_chat(user, span_warning("[src] has both electronics and a cell."))
			return FALSE
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			if(!has_electronics)
				if(stat & BROKEN)
					to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt a power control board and click it into place in [src]'s guts."))
				has_electronics = TRUE
				locked = TRUE
				return TRUE
			else if(!cell)
				if(stat & MAINT)
					to_chat(user, span_warning("There's no connector for a power cell."))
					return FALSE
				var/obj/item/stock_parts/cell/crap/empty/C = new(src)
				C.forceMove(src)
				cell = C
				chargecount = 0
				user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
				span_warning("Your [the_rcd.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
				update_appearance()
				return TRUE
			else
				to_chat(user, span_warning("[src] has both electronics and a cell."))
				return FALSE
	return FALSE

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
	else if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
	else if(panel_open)
		to_chat(user, span_warning("You must close the panel!"))
	else if(stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
	else
		if((allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack) || integration_cog)
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the APC interface."))
			update_appearance()
			updateUsrDialog()
		else
			to_chat(user, span_warning("Access denied."))

/obj/machinery/power/apc/proc/toggle_lights(mob/living/user)
	if(last_light_switch > world.time - 10 SECONDS) //~10 seconds between each toggle to prevent spamming
		to_chat(usr, span_warning("[src]'s lighting circuit breaker is still cycling!"))
		return
	last_light_switch = world.time
	area.lightswitch = !area.lightswitch
	area.update_appearance()

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance()

	area.power_change()

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_light_switch > world.time - 10 SECONDS) //~10 seconds between each toggle to prevent spamming
		to_chat(usr, span_warning("[src]'s lighting circuit breaker is still cycling!"))
		return
	last_light_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE && damage_amount < 10 && (!(stat & BROKEN) || malfai))
		return 0
	. = ..()


/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_REMOVED
			coverlocked = FALSE
			visible_message(span_warning("The APC cover is knocked down!"))
			update_appearance()

/obj/machinery/power/apc/emag_act(mob/user, obj/item/card/emag/emag_card)
	if((obj_flags & EMAGGED) || malfhack)
		return FALSE
	if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
		return FALSE
	if(panel_open)
		to_chat(user, span_warning("You must close the panel first!"))
		return FALSE
	if(stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
		return FALSE
	flick("apc-spark", src)
	playsound(src, "sparks", 75, 1)
	obj_flags |= EMAGGED
	locked = FALSE
	to_chat(user, span_notice("You emag the APC interface."))
	update_appearance()
	return TRUE

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/living/user, modifiers)
	. = ..()
	if(.)
		return
	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!",span_notice("You remove \the [cell]."))
			user.put_in_hands(cell)
			cell.update_appearance()
			src.cell = null
			charging = APC_NOT_CHARGING
			src.update_appearance()
		return
	if((stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/attack_hand_secondary(mob/living/user, modifiers)
	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Apc", name)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked && !(integration_cog && is_servant_of_ratvar(user)),
		"failTime" = failure_timer,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = DisplayPower(lastused_total),
		"coverLocked" = coverlocked,
		"siliconUser" = user.has_unlimited_silicon_privilege || user.using_power_flow_console(),
		"malfStatus" = get_malf_status(user),
		"lights" = area.lightswitch,
		"emergencyLights" = !emergency_lights,
		"nightshiftLights" = nightshift_lights,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = DisplayPower(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = DisplayPower(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = DisplayPower(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)
	return data


/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(istype(malf) && malf.malf_picker)
		if(malfai == (malf.parent || malf))
			if(occupier == malf)
				return 3 // 3 = User is shunted in this APC
			else if(istype(malf.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(user.has_unlimited_silicon_privilege)
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if (                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
				to_chat(user, span_danger("\The [src] has eee disabled!"))
			return FALSE
	if(iseminence(user))
		if(!integration_cog || !aidisabled)
			return FALSE
	return TRUE

/obj/machinery/power/apc/can_interact(mob/user)
	. = ..()
	if (!. && !QDELETED(remote_control))
		. = remote_control.can_interact(user)
	if(!(stat & (NOPOWER|BROKEN)) || (interaction_flags_machine & (INTERACT_MACHINE_OFFLINE)))
		if(iseminence(user) && integration_cog)
			. = TRUE

/obj/machinery/power/apc/ui_status(mob/user)
	. = ..()
	if (!QDELETED(remote_control) && user == remote_control.operator)
		. = UI_INTERACTIVE
	if(!QDELETED(src) && iseminence(user) && integration_cog)
		. = UI_INTERACTIVE

/obj/machinery/power/apc/ui_act(action, params)
	if(..())
		return
	// For things that require no access
	switch(action)
		if("toggle_lights")
			toggle_lights(usr)
			. = TRUE
		if("toggle_nightshift")
			toggle_nightshift_lights()
			. = TRUE
	if(!can_use(usr, TRUE) || (locked && !usr.has_unlimited_silicon_privilege && !failure_timer && !(integration_cog && (is_servant_of_ratvar(usr)))))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if((obj_flags & EMAGGED) || (stat & (BROKEN|MAINT)))
					to_chat(usr, "The APC does not respond to the command.")
				else
					locked = !locked
					update_appearance()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_appearance()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_appearance()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_appearance()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_appearance()
				update()
			. = TRUE
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				overload_lighting()
				. = TRUE
		if("hack")
			if(get_malf_status(usr))
				malfhack(usr)
		if("occupy")
			if(get_malf_status(usr))
				malfoccupy(usr)
		if("deoccupy")
			if(get_malf_status(usr))
				malfvacate()
		if("reboot")
			failure_timer = 0
			update_appearance()
			update()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/L in area)
				if(!initial(L.no_emergency)) //If there was an override set on creation, keep that override
					L.no_emergency = emergency_lights
					INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)
				CHECK_TICK
	return 1

/obj/machinery/power/apc/attack_eminence(mob/camera/eminence/user, params)
	if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON) && !IsAdminGhost(user))  ///Cutting AI wire should prevent from eminence interactions
		return FALSE
	if(!integration_cog)
		return FALSE
	_try_interact(user)

/obj/machinery/power/apc/attack_ai(mob/user)
	if(!isAI(user))
		return ..()
	
	var/mob/living/silicon/ai/AI = user
	if(AI.has_subcontroller_connection(get_area(src)))
		return ..()

	to_chat(AI, span_warning("No connection to subcontroller detected. Polling APC..."))
	if(do_after(AI, 1 SECONDS, src, IGNORE_USER_LOC_CHANGE))
		return ..()

/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(!is_operational() || failure_timer)
		return
	operating = !operating
	add_hiddenprint(user)
	log_combat(user, src, "turned [operating ? "on" : "off"]")
	update()
	update_appearance()

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != 1)
		return
	if(malf.malfhacking)
		to_chat(malf, "You are already hacking an APC.")
		return
	to_chat(malf, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, TYPE_PROC_REF(/mob/living/silicon/ai, malfhacked), src), 300, TIMER_STOPPABLE)

	var/atom/movable/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /atom/movable/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, span_warning("You must evacuate your current APC first!"))
		return
	if(!malf.can_shunt)
		to_chat(malf, span_warning("You cannot shunt!"))
		return
	if(!is_station_level(z))
		return
	if(alert("Are you sure you want to shunt into this APC?", "Confirm Shunt", "Yes", "No") != "Yes")
		return

	occupier = new /mob/living/silicon/ai(src, malf.laws, malf , TRUE) //DEAR GOD WHY?	//IKR????
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = TRUE
	QDEL_NULL(occupier.builtInCamera)
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	add_verb(occupier, /mob/living/silicon/ai/proc/corereturn)
	occupier.cancel_camera()


/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = 0
		occupier.parent.setOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		remove_verb(occupier.parent, /mob/living/silicon/ai/proc/corereturn)
		qdel(occupier)
	else
		to_chat(occupier, span_danger("Primary core damaged, unable to return core processes."))
		if(forced)
			occupier.forceMove(drop_location())
			occupier.death()
			occupier.gib()
			for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
				P.switch_mode_to(TRACK_NUKE_DISK) //Pinpointers go back to tracking the nuke disk
				P.alert = FALSE

/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(card.AI)
		to_chat(user, span_warning("[card] is already occupied!"))
		return
	if(!occupier)
		to_chat(user, span_warning("There's nothing in [src] to transfer!"))
		return
	if(!occupier.mind || !occupier.client)
		to_chat(user, span_warning("[occupier] is either inactive or destroyed!"))
		return
	if(!occupier.parent.stat)
		to_chat(user, span_warning("[occupier] is refusing all attempts at transfer!") )
		return
	if(transfer_in_progress)
		to_chat(user, span_warning("There's already a transfer in progress!"))
		return
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return
	var/turf/T = get_turf(user)
	if(!T)
		return
	transfer_in_progress = TRUE
	user.visible_message(span_notice("[user] slots [card] into [src]..."), span_notice("Transfer process initiated. Sending request for AI approval..."))
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	SEND_SOUND(occupier, sound('sound/misc/notice2.ogg')) //To alert the AI that someone's trying to card them if they're tabbed out
	if(tgui_alert(occupier, "[user] is attempting to transfer you to \a [card.name]. Do you consent to this?", "APC Transfer", list("Yes - Transfer Me", "No - Keep Me Here")) == "No - Keep Me Here")
		to_chat(user, "<span class='danger'>AI denied transfer request. Process terminated.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		transfer_in_progress = FALSE
		return
	if(user.loc != T)
		to_chat(user, span_danger("Location changed. Process terminated."))
		to_chat(occupier, span_warning("[user] moved away! Transfer canceled."))
		transfer_in_progress = FALSE
		return
	to_chat(user, span_notice("AI accepted request. Transferring stored intelligence to [card]..."))
	to_chat(occupier, span_notice("Transfer starting. You will be moved to [card] shortly."))
	if(!do_after(user, 5 SECONDS, src))
		to_chat(occupier, span_warning("[user] was interrupted! Transfer canceled."))
		transfer_in_progress = FALSE
		return
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return
	user.visible_message(span_notice("[user] transfers [occupier] to [card]!"), span_notice("Transfer complete! [occupier] is now stored in [card]."))
	to_chat(occupier, span_notice("Transfer complete! You've been stored in [user]'s [card.name]."))
	occupier.forceMove(card)
	card.AI = occupier
	occupier.parent.shunted = FALSE
	occupier.cancel_camera()
	occupier = null
	transfer_in_progress = FALSE
	return

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(icon_update_needed)
		update_appearance()
	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return
	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = 1
		return

	lastused_light = area.usage(AREA_USAGE_STATIC_LIGHT)
	lastused_light += area.usage(AREA_USAGE_LIGHT)
	lastused_equip = area.usage(AREA_USAGE_EQUIP)
	lastused_equip += area.usage(AREA_USAGE_STATIC_EQUIP)
	lastused_environ = area.usage(AREA_USAGE_ENVIRON)
	lastused_environ += area.usage(AREA_USAGE_STATIC_ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge/GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 40 && longtermpower < 0)			// <40%, turn off Lighting
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		// now trickle-charge the cell
		if(chargemode && charging == APC_CHARGING && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_CHARGING

		else // chargemode off
			charging = 0
			chargecount = 0

	else // no cell, switch everything off

		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/obj/machinery/power/apc/proc/autoset(val, on)
	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1
	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3
	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1
	return val

/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = 3
			environ = 3
			update_appearance()
			update()

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_CONTENTS))
		if(cell)
			cell.emp_act(severity)
		if(occupier)
			occupier.emp_act(severity)
	if(. & EMP_PROTECT_SELF)
		return
	lighting = 0
	equipment = 0
	environ = 0
	update_appearance()
	update()
	addtimer(CALLBACK(src, PROC_REF(reset), APC_RESET_EMP), (6 * severity) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	operating = FALSE
	atom_break()
	if(occupier)
		malfvacate(1)
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		INVOKE_ASYNC(src, PROC_REF(break_lights))

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/breaked_light in area)
		breaked_light.on = TRUE
		breaked_light.break_light_tube()
		stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	do_sparks(5, TRUE, src)
	if(isalien(user))
		return 0
	if(electrocute_mob(user, src, src, 1, TRUE))
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0


/obj/machinery/power/apc/proc/energy_fail(duration)
	for(var/obj/machinery/M in area.contents)
		if(M.critical_machine)
			return
	for(var/A in GLOB.ai_list)
		var/mob/living/silicon/ai/I = A
		if(get_area(I) == area)
			return

	failure_timer = max(failure_timer, round(duration))

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/L in area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE)
		CHECK_TICK

/obj/machinery/power/apc/proc/ethereal_act(mob/living/user)
	if(!ishuman(user))
		to_chat(user, span_warning("You can't comprehend how this thing works!"))	//this shouldn't ever trigger
		return FALSE
	var/mob/living/carbon/human/ethereal = user
	var/obj/item/organ/stomach/maybe_stomach = ethereal.getorganslot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_stomach, /obj/item/organ/stomach/cell/ethereal))
		to_chat(ethereal, span_warning("You don't have the correct stomach for this!"))
		return FALSE
	if(ethereal.nutrition < NUTRITION_LEVEL_MOSTLY_FULL)
		to_chat(ethereal, span_warning("You don't have any excess power to channel into the APC!"))
		return TRUE
	to_chat(ethereal, span_notice("You start channeling power through your body into the APC."))
	if(!do_after(user, 1 SECONDS, target = src))
		return FALSE
	if(ethereal.nutrition < NUTRITION_LEVEL_MOSTLY_FULL)
		to_chat(ethereal, span_warning("You don't have any excess power to transfer to the APC!"))
		return FALSE
	if(istype(maybe_stomach))
		to_chat(ethereal, span_notice("You transfer some power to the APC."))
		ethereal.adjust_nutrition(APC_POWER_GAIN / -2.5) // nutrition and cell charges use different scales
		var/cellamount = clamp(cell.maxcharge - cell.charge, 0, APC_POWER_GAIN)
		cell.give(cellamount)
		add_avail(APC_POWER_GAIN - cellamount)
	else
		to_chat(ethereal, span_warning("You can't transfer power to the APC!"))
	
	return TRUE

#undef UPSTATE_CELL_IN
#undef UPSTATE_OPENED1
#undef UPSTATE_OPENED2
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD

#undef APC_RESET_EMP

#undef APC_ELECTRONICS_MISSING
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED

//update_overlay
#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED
#undef APC_UPOVERLAY_OPERATING
#undef APC_POWER_GAIN

/*Power module, used for APC construction*/
/obj/item/electronics/apc
	name = "APC module"
	icon_state = "power_mod"
	custom_price = 5
	desc = "Heavy-duty switching circuits for power control."
