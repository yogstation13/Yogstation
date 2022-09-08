// This is the base type that does all the hardware stuff.
// Other types expand it - tablets use a direct subtypes, and
// consoles and laptops use "procssor" item that is held inside machinery piece
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."
	
	flags_1 = RAD_PROTECT_CONTENTS_1

	var/enabled = FALSE										// Whether the computer is turned on.
	var/screen_on = TRUE									// Whether the computer is active/opened/it's screen is on.
	var/device_theme = "ntos"								// Sets the theme for the main menu, hardware config, and file browser apps. Overridden by certain non-NT devices.
	var/datum/computer_file/program/active_program = null	// A currently active program running on the computer.
	var/hardware_flag = 0									// A flag that describes this device type
	var/last_power_usage = 0
	var/last_battery_percent = 0							// Used for deciding if battery percentage has chandged
	var/last_world_time = "00:00"
	var/list/last_header_icons

	var/base_active_power_usage = 50						// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 5							// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop-open"
	var/icon_state_unpowered = null							// Icon state when the computer is turned off.
	var/icon_state_powered = null							// Icon state when the computer is turned on.
	var/icon_state_menu = "menu"							// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/id_rename = FALSE										// If we should update the name of the computer with the name and job of the stored ID.
	var/icon_state_screensaver = "standby"					// Icon state overlay when the computer is turned off, but not out of power.
	var/max_hardware_size = 0								// Maximal hardware w_class. Tablets/PDAs have 1, laptops 2, consoles 4.
	var/steel_sheet_cost = 5								// Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/overlay_skin = null									// What set of icons should be used for program overlays.

	integrity_failure = 50
	max_integrity = 100
	armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 0, ACID = 0)

	/// List of "connection ports" in this computer and the components with which they are plugged
	var/list/all_components = list()
	/// Lazy List of extra hardware slots that can be used modularly.
	var/list/expansion_bays
	/// Number of total expansion bays this computer has available.
	var/max_bays = 0

	var/list/idle_threads							// Idle programs on background. They still receive process calls but can't be interacted with.
	var/obj/physical = null									// Object that represents our computer. It's used for Adjacent() and UI visibility checks.
	var/has_light = FALSE						//If the computer has a flashlight/LED light/what-have-you installed
	var/light_on = FALSE						//If that light is enabled
	var/comp_light_luminosity = 3				//The brightness of that light
	var/comp_light_color			//The color of that light

	// Preset Stuff
	var/list/starting_components = list()
	var/list/starting_files = list()
	var/datum/computer_file/program/initial_program
	var/sound/startup_sound = 'sound/machines/computers/computer_start.ogg'
	var/sound/shutdown_sound = 'sound/machines/computers/computer_end.ogg'
	var/list/interact_sounds = list('sound/machines/computers/keypress1.ogg', 'sound/machines/computers/keypress2.ogg', 'sound/machines/computers/keypress3.ogg', 'sound/machines/computers/keypress4.ogg', 'sound/machines/computers/keystroke1.ogg', 'sound/machines/computers/keystroke2.ogg', 'sound/machines/computers/keystroke3.ogg', 'sound/machines/computers/keystroke4.ogg')


/obj/item/modular_computer/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	if(!physical)
		physical = src
	comp_light_color = "#FFFFFF"
	idle_threads = list()
	install_starting_components()
	install_starting_files()
	update_icon()

/obj/item/modular_computer/Destroy()
	kill_program(forced = TRUE)
	STOP_PROCESSING(SSobj, src)
	for(var/H in all_components)
		var/obj/item/computer_hardware/CH = all_components[H]
		if(CH.holder == src)
			CH.on_remove(src)
			CH.holder = null
			all_components.Remove(CH.device_type)
			qdel(CH)
	physical = null
	return ..()

/obj/item/modular_computer/attack(atom/A, mob/living/user, params)
	if(active_program?.tap(A, user, params))
		user.do_attack_animation(A) //Emulate this animation since we kill the attack in three lines
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1) //Likewise for the tap sound
		addtimer(CALLBACK(src, .proc/play_ping), 0.5 SECONDS, TIMER_UNIQUE) //Slightly delayed ping to indicate success
		return 
	return ..()

/**
 * Plays a sound through the computer's speakers.
 */
/obj/item/modular_computer/proc/play_computer_sound(soundin, vol, vary)
	if(isobserver(usr))
		return
	playsound(loc, soundin, vol, vary, -1)

/**
 * Plays a ping sound.
 *
 * Timers runtime if you try to make them call playsound. Yep.
 */
/obj/item/modular_computer/proc/play_ping()
	play_computer_sound('sound/machines/ping.ogg', get_clamped_volume(), FALSE)

// Plays a random interaction sound, which is by default a bunch of keboard clacking
/obj/item/modular_computer/proc/play_interact_sound()
	if(isobserver(usr))
		return
	play_computer_sound(pick(interact_sounds), get_clamped_volume(), FALSE, -1)


/obj/item/modular_computer/AltClick(mob/user)
	..()
	if(issilicon(user))
		return

	if(user.canUseTopic(src, BE_CLOSE))
		var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
		var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
		return (card_slot2?.try_eject(user) || card_slot?.try_eject(user)) //Try the secondary one first.


// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs.
/obj/item/modular_computer/GetAccess()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetAccess()
	return ..()

/obj/item/modular_computer/RemoveID()
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	return (card_slot2?.try_eject() || card_slot?.try_eject()) //Try the secondary one first.

/obj/item/modular_computer/InsertID(obj/item/inserting_item)
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	if(!(card_slot || card_slot2))
		//to_chat(user, "<span class='warning'>There isn't anywhere you can fit a card into on this computer.</span>")
		return FALSE

	var/obj/item/card/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return FALSE

	if((card_slot?.try_insert(inserting_id)) || (card_slot2?.try_insert(inserting_id)))
		return TRUE
	//to_chat(user, "<span class='warning'>This computer doesn't have an open card slot.</span>")
	return FALSE

/obj/item/modular_computer/GetID()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetID()
	return ..()

/obj/item/modular_computer/RemoveID()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(!card_slot)
		return
	return card_slot.RemoveID()

/obj/item/modular_computer/InsertID(obj/item/inserting_item)
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(!card_slot)
		return FALSE
	var/obj/item/card/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return FALSE
	return card_slot.try_insert(inserting_id)

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && usr.canUseTopic(src, BE_CLOSE))
		return attack_self(M)
	return ..()

/obj/item/modular_computer/CtrlClick()
	var/mob/M = usr
	if(ishuman(usr) && usr.CanReach(src) && usr.canUseTopic(src))
		return attack_self(M)
	else
		..()

/obj/item/modular_computer/attack_ai(mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(enabled)
		ui_interact(user)
	else if(IsAdminGhost(user))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/emag_act(mob/user)
	if(!enabled)
		to_chat(user, "<span class='warning'>You'd need to turn the [src] on first.</span>")
		return FALSE
	obj_flags |= EMAGGED //Mostly for consistancy purposes; the programs will do their own emag handling
	var/newemag = FALSE
	var/obj/item/computer_hardware/hard_drive/drive = all_components[MC_HDD]
	for(var/datum/computer_file/program/app in drive.stored_files)
		if(!istype(app))
			continue
		if(app.run_emag())
			newemag = TRUE
	if(newemag)
		to_chat(user, "<span class='notice'>You swipe \the [src]. A console window momentarily fills the screen, with white text rapidly scrolling past.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>You swipe \the [src]. A console window fills the screen, but it quickly closes itself after only a few lines are written to it.</span>")
	return FALSE

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	if(obj_integrity <= integrity_failure)
		. += span_danger("It is heavily damaged!")
	else if(obj_integrity < max_integrity)
		. += span_warning("It is damaged.")

	. += get_modular_computer_parts_examine(user)

/obj/item/modular_computer/update_icon()
	if(!physical)
		return

	SSvis_overlays.remove_vis_overlay(physical, physical.managed_vis_overlays)
	var/program_overlay = ""
	var/is_broken = obj_integrity <= integrity_failure
	if(overlay_skin)
		program_overlay = "[overlay_skin]-"
	if(!enabled)
		if(use_power() && !isnull(icon_state_screensaver))
			program_overlay += icon_state_screensaver
		else
			icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered
		if(is_broken)
			program_overlay += "bsod"
		else
			if(active_program)
				program_overlay += active_program.program_icon_state ? "[active_program.program_icon_state]" : "[icon_state_menu]"
			else
				program_overlay += icon_state_menu

	SSvis_overlays.add_vis_overlay(physical, physical.icon, program_overlay, physical.layer, physical.plane, physical.dir)
	SSvis_overlays.add_vis_overlay(physical, physical.icon, program_overlay, physical.layer, EMISSIVE_PLANE, physical.dir)
	if(is_broken)
		SSvis_overlays.add_vis_overlay(physical, physical.icon, "broken", physical.layer, physical.plane, physical.dir)

/obj/item/modular_computer/equipped()
	. = ..()
	update_icon()

/obj/item/modular_computer/dropped()
	. = ..()
	update_icon()


/obj/item/modular_computer/proc/update_label()
	var/obj/item/card/id/stored_id = GetID()
	if(id_rename && stored_id)
		name = "[stored_id.registered_name]'s [initial(name)] ([stored_id.assignment])"
	else
		name = initial(name)

// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/modular_computer/interact(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

/obj/item/modular_computer/proc/turn_on(mob/user)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(obj_integrity <= integrity_failure)
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src], but it responds with an error code. It must be damaged."))
		else
			to_chat(user, span_warning("You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again."))
		return

	// If we have a recharger, enable it automatically. Lets computer without a battery work.
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGE]
	if(recharger)
		recharger.enabled = TRUE

	if(all_components[MC_CPU] && use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, span_notice("You send an activation signal to \the [src], turning it on."))
		else
			to_chat(user, span_notice("You press the power button and start up \the [src]."))
		enabled = TRUE
		update_icon()
		play_computer_sound(startup_sound, get_clamped_volume(), FALSE)
		ui_interact(user)
	else // Unpowered
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src] but it does not respond."))
		else
			to_chat(user, span_warning("You press the power button but \the [src] does not respond."))

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/modular_computer/process()
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return FALSE

	if(obj_integrity <= integrity_failure)
		shutdown_computer()
		return FALSE

	if(active_program && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature))
		active_program.event_networkfailure(0) // Active program requires NTNet to run but we've just lost connection. Crash.

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
			P.event_networkfailure(1)

	if(active_program)
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.process_tick()
			active_program.ntnet_status = get_ntnet_status()
		else
			active_program = null

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.program_state != PROGRAM_STATE_KILLED)
			P.process_tick()
			P.ntnet_status = get_ntnet_status()
		else
			idle_threads.Remove(P)

	handle_power() // Handles all computer power interaction
	//check_update_ui_need()

/**
  * Displays notification text alongside a soundbeep when requested to by a program.
  *
  * After checking tha the requesting program is allowed to send an alert, creates
  * a visible message of the requested text alongside a soundbeep. This proc adds
  * text to indicate that the message is coming from this device and the program
  * on it, so the supplied text should be the exact message and ending punctuation.
  *
  * Arguments:
  * The program calling this proc.
  * The message that the program wishes to display.
 */

/obj/item/modular_computer/proc/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	play_computer_sound(sound, 50, TRUE)
	var/mob/living/holder = loc
	if(istype(holder))
		to_chat(holder, span_notice("\The [src] displays a [caller.filedesc] notification: [alerttext]"))
	else
		visible_message(span_notice("\The [src] displays a [caller.filedesc] notification: [alerttext]"))

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	data["PC_device_theme"] = device_theme

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGE]

	if(battery_module && battery_module.battery)
		switch(battery_module.battery.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(battery_module.battery.percent())] %"
		data["PC_showbatteryicon"] = 1
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"
		data["PC_showbatteryicon"] = battery_module ? 1 : 0

	if(recharger && recharger.enabled && recharger.check_functionality() && recharger.use_power(0))
		data["PC_apclinkicon"] = "charging.gif"

	switch(get_ntnet_status())
		if(0)
			data["PC_ntneticon"] = "sig_none.gif"
		if(1)
			data["PC_ntneticon"] = "sig_low.gif"
		if(2)
			data["PC_ntneticon"] = "sig_high.gif"
		if(3)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(idle_threads.len)
		var/list/program_headers = list()
		for(var/I in idle_threads)
			var/datum/computer_file/program/P = I
			if(!P.ui_header)
				continue
			program_headers.Add(list(list(
				"icon" = P.ui_header
			)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = station_time_timestamp()
	data["PC_hasheader"] = 1
	data["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen
	return data

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/modular_computer/proc/kill_program(forced = FALSE)
	if(active_program)
		active_program.kill_program(forced)
		active_program = null
	var/mob/user = usr
	if(user && istype(user))
		ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
	update_icon()

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status(specific_action = 0)
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	if(network_card)
		return network_card.get_signal(specific_action)
	else
		return 0

/obj/item/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return FALSE
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	return SSnetworks.station_network.add_log(text, network_card)

/obj/item/modular_computer/proc/shutdown_computer(loud = 1)
	kill_program(forced = TRUE)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(forced = TRUE)
		idle_threads.Remove(P)
	if(loud)
		physical.visible_message(span_notice("\The [src] shuts down."))
	enabled = FALSE
	update_icon()
	play_computer_sound(shutdown_sound, get_clamped_volume(), FALSE)

/obj/item/modular_computer/screwdriver_act(mob/user, obj/item/tool)
	if(!all_components.len)
		to_chat(user, "<span class='warning'>This device doesn't have any components installed.</span>")
		return
	var/list/component_names = list()
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		component_names.Add(H.name)

	var/choice = input(user, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in sortList(component_names)

	if(!choice)
		return

	if(!Adjacent(user))
		return

	var/obj/item/computer_hardware/H = find_hardware_by_name(choice)

	if(!H)
		return

	uninstall_component(H, user)
	return


/obj/item/modular_computer/attackby(obj/item/W as obj, mob/user as mob)
	// Insert items into the components
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		if(H.try_insert(W, user))
			return

	// Insert new hardware
	if(istype(W, /obj/item/computer_hardware))
		if(install_component(W, user))
			return

	if(W.tool_behaviour == TOOL_WRENCH)
		if(all_components.len)
			to_chat(user, span_warning("Remove all components from \the [src] before disassembling it."))
			return
		new /obj/item/stack/sheet/metal( get_turf(src.loc), steel_sheet_cost )
		physical.visible_message("\The [src] has been disassembled by [user].")
		relay_qdel()
		qdel(src)
		return

	if(W.tool_behaviour == TOOL_WELDER)
		if(obj_integrity == max_integrity)
			to_chat(user, span_warning("\The [src] does not require repairs."))
			return

		if(!W.tool_start_check(user, amount=1))
			return

		to_chat(user, span_notice("You begin repairing damage to \the [src]..."))
		if(W.use_tool(src, user, 20, volume=50, amount=1))
			obj_integrity = max_integrity
			to_chat(user, span_notice("You repair \the [src]."))
		return

	..()

// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

// Perform adjacency checks on our physical counterpart, if any.
/obj/item/modular_computer/Adjacent(atom/neighbor)
	if(physical && physical != src)
		return physical.Adjacent(neighbor)
	return ..()

// Starting Comps/Programs, mainly used for presets. Edit starting_components, starting_files, and initial_program.
/obj/item/modular_computer/proc/install_starting_components()
	if(starting_components.len < 1)
		return
	for(var/part in starting_components)
		var/new_part = new part
		if(istype(new_part, /obj/item/computer_hardware))
			var/result = install_component(new_part)
			if(result == FALSE)
				CRASH("[src] failed to install starting component for an unknown reason")
		else if(istype(new_part, /obj/item/stock_parts/cell/computer))
			var/new_cell = new /obj/item/computer_hardware/battery(src, part)
			qdel(new_part)
			var/result = install_component(new_cell)
			if(result == FALSE)
				CRASH("[src] failed to install starting cell for an unknown reason")

/obj/item/modular_computer/proc/install_starting_files()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!istype(hard_drive) || starting_files.len < 1)
		if(!starting_files.len < 1)
			CRASH("[src] failed to install files due to not having a hard drive even though it has starting files")
		return
	for(var/datum/computer_file/file in starting_files)
		var/result = hard_drive.store_file(file)
		if(result == FALSE)
			CRASH("[src] failed to install starting files for an unknown reason")
		if(istype(result, initial_program) && istype(result, /datum/computer_file/program))
			var/datum/computer_file/program/program = result
			if(program.requires_ntnet && program.network_destination)
				program.generate_network_log("Connection opened to [program.network_destination].")
			program.program_state = PROGRAM_STATE_ACTIVE
			active_program = program
			program.alert_pending = FALSE
			enabled = TRUE

/// Sets visible messages to also send to holder because coders didn't know it didn't do this
/obj/item/modular_computer/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags)
	. = ..()
	if(ismob(loc))
		to_chat(loc, message)

/obj/item/modular_computer/proc/uplink_check(mob/living/M, code)
	return SEND_SIGNAL(src, COMSIG_NTOS_CHANGE_RINGTONE, M, code) & COMPONENT_STOP_RINGTONE_CHANGE
