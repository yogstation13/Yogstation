/obj/item/ai_relay_module
	name = "\improper AI Relay Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "A module that enable AI relays to perform specific tasks."
	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_GOLD = 250)

	var/enabling_tasks


/obj/item/ai_relay_module/power_manip
	name = "\improper AI Relay Module (Power Manipulation)"
	desc = "A module that enable AI relays to manipulate APCs and SMES units."
	enabling_tasks = POWER_MANIPULATION

/obj/item/ai_relay_module/enviromental
	name = "\improper AI Relay Module (Enviromental Control)"
	desc = "A module that enable AI relays to interface with air alarms and firealarms."
	enabling_tasks = ENVIROMENTAL_CONTROL

/obj/item/ai_relay_module/doors
	name = "\improper AI Relay Module (Door Control)"
	desc = "A module that enable AI relays to open and close doors."
	enabling_tasks = DOOR_CONTROL

/obj/item/ai_relay_module/telecomms
	name = "\improper AI Relay Module (Telecommunications Control)"
	desc = "A module that enable AI relays to manipulate telecommunications machinery and give the AI radio access."
	enabling_tasks = TELECOMMS_CONTROL

/obj/item/ai_relay_module/machine_interaction
	name = "\improper AI Relay Module (Machine Interaction)"
	desc = "A module that enable AI relays to interact with consoles and regular machinery."
	enabling_tasks = MACHINE_INTERACTION

/obj/item/ai_relay_module/all_in_one
	name = "\improper AI Relay Module (Unknown)"
	desc = "A modified module that gives the AI unknown capabilities to control various objects."
	enabling_tasks = MACHINE_INTERACTION | TELECOMMS_CONTROL | DOOR_CONTROL | ENVIROMENTAL_CONTROL | POWER_MANIPULATION
