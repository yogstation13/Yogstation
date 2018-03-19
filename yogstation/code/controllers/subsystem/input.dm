SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	
	var/list/macro_sets
	
	var/list/default_arrowmovement_keys
	var/list/default_movement_keys

/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()
	setup_default_movement_keys()
	
	initialized = TRUE

	return ..()

/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	var/list/static/default_macro_sets

	if(default_macro_sets)
		macro_sets = default_macro_sets
		return
	
	default_macro_sets = list(
		"old_default" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_hotkeys map.focus=true input.background-color=[COLOR_INPUT_DISABLED]\\\"\"",
			"Ctrl+T" = "say",
			"Ctrl+O" = "ooc",
		),
		"old_hotkeys" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_default input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"O" = "ooc",
			"T" = "say",
			"M" = "me",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"", // This makes it so backspace can remove default inputs
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
		),
	)
	
	macro_sets = default_macro_sets

/datum/controller/subsystem/input/proc/setup_default_movement_keys()
	var/static/list/default_keys = list(
		"W" = NORTH, "A" = WEST, "S" = SOUTH, "D" = EAST,				// WASD
	)
	
	var/static/list/arrow_keys = list(
		"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST,	// WASD
	)

	default_arrowmovement_keys = arrow_keys.Copy()
	default_movement_keys = default_keys.Copy()

/datum/controller/subsystem/input/fire()
	var/list/clients = GLOB.clients // Let's sing the list cache song
	for(var/i in 1 to clients.len)
		var/client/C = clients[i]
		C.keyLoop()