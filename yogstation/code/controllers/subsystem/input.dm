VERB_MANAGER_SUBSYSTEM_DEF(input)
	name = "Input"
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	use_default_stats = FALSE

	var/list/macro_sets

	var/list/movement_arrows

	///running average of how many clicks inputted by a player the server processes every second. used for the subsystem stat entry
	var/clicks_per_second = 0
	///count of how many clicks onto atoms have elapsed before being cleared by fire(). used to average with clicks_per_second.
	var/current_clicks = 0
	///acts like clicks_per_second but only counts the clicks actually processed by SSinput itself while clicks_per_second counts all clicks
	var/delayed_clicks_per_second = 0
	///running average of how many movement iterations from player input the server processes every second. used for the subsystem stat entry
	var/movements_per_second = 0
	///running average of the amount of real time clicks take to truly execute after the command is originally sent to the server.
	///if a click isnt delayed at all then it counts as 0 deciseconds.
	var/average_click_delay = 0

/datum/controller/subsystem/verb_manager/input/Initialize()
	setup_default_macro_sets()
	setup_default_movement_keys()

	initialized = TRUE
	refresh_client_macro_sets()

	return ..()

/datum/controller/subsystem/verb_manager/input/proc/setup_default_macro_sets()
	var/list/static/default_macro_sets

	if(default_macro_sets)
		macro_sets = default_macro_sets
		return

	default_macro_sets = list(
		"default" = list(
			"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"", // This makes it so backspace can remove default inputs
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
			),
		"old_default" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_hotkeys map.focus=true input.background-color=[COLOR_INPUT_DISABLED]\\\"\"",
			"Ctrl+T" = "say",
			"Ctrl+O" = "ooc",
			"CTRL+L" = "looc",
			),
		"old_hotkeys" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_default input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"", // This makes it so backspace can remove default inputs
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
			),
		)

	// Because i'm lazy and don't want to type all these out twice
	var/list/old_default = default_macro_sets["old_default"]
	var/list/old_hotkeys = default_macro_sets["old_hotkeys"]
	var/list/default = default_macro_sets["default"]

	var/list/static/oldmode_keys = list(
		"North", "East", "South", "West",
		"Northeast", "Southeast", "Northwest", "Southwest",
		"Insert", "Delete", "Ctrl", "Alt",
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		)

	for(var/i in 1 to oldmode_keys.len)
		var/key = oldmode_keys[i]
		old_default[key] = "\"KeyDown [key]\""
		old_default["[key]+UP"] = "\"KeyUp [key]\""

	var/list/static/oldmode_ctrl_override_keys = list(
		"W" = "W", "A" = "A", "S" = "S", "D" = "D", // movement
		"1" = "1", "2" = "2", "3" = "3", "4" = "4", // intent
		"B" = "B", // resist
		"E" = "E", // quick equip
		"F" = "F", // intent left
		"G" = "G", // intent right
		"H" = "H", // stop pulling
		"Q" = "Q", // drop
		"R" = "R", // throw
		"X" = "X", // switch hands
		"Y" = "Y", // activate item
		"Z" = "Z", // activate item
		)

	for(var/i in 1 to oldmode_ctrl_override_keys.len)
		var/key = oldmode_ctrl_override_keys[i]
		var/override = oldmode_ctrl_override_keys[key]
		old_default["Ctrl+[key]"] = "\"KeyDown [override]\""
		old_default["Ctrl+[key]+UP"] = "\"KeyUp [override]\""

	// basically when these keys are pressed, we want to make sure to clear/set ctrl's state if we need to.
	var/list/static/ctrl_sensitive_keys = list(
		"North", "East", "South", "West",
		"W", "A", "S", "D"
		)
	for(var/i in 1 to ctrl_sensitive_keys.len)
		var/key = ctrl_sensitive_keys[i]
		old_hotkeys["Ctrl+[key]"] = "\"KeyDown Ctrl\""
		old_hotkeys["[key]"] = "\"KeyUp Ctrl\""
		default["Ctrl+[key]"] = "\"KeyDown Ctrl\""
		default["[key]"] = "\"KeyUp Ctrl\""

	macro_sets = default_macro_sets

/datum/controller/subsystem/verb_manager/input/proc/setup_default_movement_keys()
	var/static/list/arrow_keys = list(
		"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST,	// Arrow keys & Numpad
	)

	movement_arrows = arrow_keys.Copy()

/datum/controller/subsystem/verb_manager/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to clients.len)
		var/client/user = clients[i]
		user.set_macros()

/datum/controller/subsystem/verb_manager/input/can_queue_verb(datum/callback/verb_callback/incoming_callback, control)
	//make sure the incoming verb is actually something we specifically want to handle
	if(control != "mapwindow.map")
		return FALSE

	if(average_click_delay >= MAXIMUM_CLICK_LATENCY || !..())
		current_clicks++
		average_click_delay = MC_AVG_FAST_UP_SLOW_DOWN(average_click_delay, 0)
		return FALSE

	return TRUE

///stupid workaround for byond not recognizing the /atom/Click typepath for the queued click callbacks
/atom/proc/_Click(location, control, params)
	if(usr)
		Click(location, control, params)


/datum/controller/subsystem/verb_manager/input/fire()
	var/moves_this_run = 0
	var/deferred_clicks_this_run = 0 //acts like current_clicks but doesnt count clicks that dont get processed by SSinput

	for(var/datum/callback/verb_callback/queued_click as anything in verb_queue)
		if(!istype(queued_click))
			stack_trace("non /datum/callback/verb_callback instance inside SSinput's verb_queue!")
			continue

		average_click_delay = MC_AVG_FAST_UP_SLOW_DOWN(average_click_delay, (REALTIMEOFDAY - queued_click.creation_time) SECONDS)
		queued_click.InvokeAsync()

		current_clicks++
		deferred_clicks_this_run++

	verb_queue.Cut() //is ran all the way through every run, no exceptions

	for(var/mob/user in GLOB.player_list)
		moves_this_run += user.focus?.keyLoop(user.client)//only increments if a player changes their movement input from the last tick

	clicks_per_second = MC_AVG_SECONDS(clicks_per_second, current_clicks, wait TICKS)
	delayed_clicks_per_second = MC_AVG_SECONDS(delayed_clicks_per_second, deferred_clicks_this_run, wait TICKS)
	movements_per_second = MC_AVG_SECONDS(movements_per_second, moves_this_run, wait TICKS)

	current_clicks = 0

/datum/controller/subsystem/verb_manager/input/stat_entry(msg)
	. = ..()
	. += "M/S:[round(movements_per_second,0.01)] | C/S:[round(clicks_per_second,0.01)]([round(delayed_clicks_per_second,0.01)] | CD: [round(average_click_delay,0.01)])"

