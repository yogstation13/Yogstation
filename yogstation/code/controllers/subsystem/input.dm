SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_sets

	var/list/movement_arrows

/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()
	setup_default_movement_keys()

	initialized = TRUE
	refresh_client_macro_sets()

	return ..()

/datum/controller/subsystem/input/proc/setup_default_macro_sets()
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

/datum/controller/subsystem/input/proc/setup_default_movement_keys()
	var/static/list/arrow_keys = list(
		"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST,	// Arrow keys & Numpad
	)

	movement_arrows = arrow_keys.Copy()

/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to clients.len)
		var/client/user = clients[i]
		user.set_macros()

/datum/controller/subsystem/input/fire()
	var/list/clients = GLOB.clients // Let's sing the list cache song
	for(var/i in 1 to clients.len)
		var/client/C = clients[i]
		C.keyLoop()
