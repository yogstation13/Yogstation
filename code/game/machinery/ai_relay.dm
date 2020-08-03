GLOBAL_LIST_EMPTY(ai_relays)

#define AI_RELAY_HACK_TIME 600
#define FLIP_DELAY 150

/obj/machinery/ai_relay
	name = "processing relay"
	desc = "A mighty piece of hardware used to process massive amounts of data. It allows the AI to interface with various machines on the station."

	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"

	critical_machine = TRUE
	density = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 5000 //10x

	var/on = TRUE

	var/list/linked_ais = list()

	var/list/hacked_ais = list()

	var/module_door_open = FALSE
	var/obj/item/ai_relay_module/inserted_module

	var/last_flipped

	var/generates_heat = TRUE
	var/heat_output = 5000


	circuit = /obj/item/circuitboard/machine/ai_relay

/obj/machinery/ai_relay/Initialize()
	GLOB.ai_relays += src
	name = "[name] ([num2hex(rand(1,65535), -1)])"
	if(inserted_module)
		var/obj/item/ai_relay_module/board = new inserted_module(src)
		inserted_module = board
	. = ..()

/obj/machinery/ai_relay/Destroy()
	GLOB.ai_relays -= src
	reset_connected_ais()
	. = ..()

/obj/machinery/ai_relay/attack_hand(mob/user)
	. = ..()
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>Nothing happens...</span>")
		return

	if(panel_open)
		to_chat(user, "<span class='warning'>You need to close the maintenance hatch first!</span>")
		return

	if(module_door_open && inserted_module)
		inserted_module.forceMove(get_turf(src))
		user.visible_message("[user] removes [inserted_module].", "<span class='notice'>You remove [inserted_module].</span>")
		inserted_module = null
		return

	if(on)
		if(last_flipped > world.time)
			to_chat(user, "<span class='warning'>The breaker won't budge! The relay has locked it for [(last_flipped - world.time) / 10] seconds!</span>")
			return
		last_flipped = world.time + FLIP_DELAY
		to_chat(user, "<span class='notice'>You start flipping the breaker...</span>")
		if(!do_after(user, FLIP_DELAY, target = src))
			return
		on = FALSE
		user.visible_message("[user] switches [src] off.", "<span class='warning'>You flip the breaker to the OFF position.</span>")
		use_power = IDLE_POWER_USE
		message_ais("<span class='warning'>[src] has been turned off manually!</span>")
		update_icon()
	else
		if(last_flipped > world.time)
			to_chat(user, "<span class='warning'>The breaker won't budge! The relay has locked it for [(last_flipped - world.time) / 10] seconds!</span>")
			return
		last_flipped = world.time + FLIP_DELAY
		to_chat(user, "<span class='notice'>You start flipping the breaker...</span>")
		if(!do_after(user, FLIP_DELAY, target = src))
			return
		on = TRUE
		user.visible_message("[user] switches [src] on.", "<span class='warning'>You flip the breaker to the ON position.</span>")
		use_power = ACTIVE_POWER_USE
		message_ais("<span class='notice'>[src] has been turned on manually.</span>")
		update_icon()


/obj/machinery/ai_relay/process()
	if(stat & (NOPOWER|BROKEN))
		visible_message("[src] switches off.")
		update_icon()
		on = FALSE
		use_power = IDLE_POWER_USE
		return FALSE
	if(on && generates_heat)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env.heat_capacity())
			env.set_temperature(env.return_temperature() + heat_output / env.heat_capacity())
	return TRUE

/obj/machinery/ai_relay/attack_ai(mob/user)
	if(get_area(src) == get_area(user))
		to_chat(user, "<span class='warning'>If you wish to connect this relay, please use the Refresh Relays button.</span>")
		return

	var/mob/living/silicon/ai/hacker = user
	if(!istype(hacker))
		return
	if(hacker in linked_ais)
		to_chat(user, "<span class='warning'>We already have control of this relay!</span>")
		return
	if(hacker.relay_hack)
		return

	hacker.relay_hack = addtimer(CALLBACK(hacker, /mob/living/silicon/ai/.proc/relay_hacked, src), AI_RELAY_HACK_TIME, TIMER_STOPPABLE)
	var/obj/screen/alert/hackingapc/A
	A = hacker.throw_alert("hacking_relay", /obj/screen/alert/hackingapc)
	A.target = src

	for(var/M in linked_ais)
		var/mob/living/silicon/ai/AI = M
		if(!istype(AI))
			return
		to_chat(AI, "<span class='userdanger'>Hostile intrusion detected on [src]! Signal origin tracked to [get_area(hacker)]</span>")


/obj/machinery/ai_relay/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[icon_state]", "[icon_state]", O))
		return
	else if(O.tool_behaviour == TOOL_CROWBAR)
		if(module_door_open)
			module_door_open = FALSE
			user.visible_message("[user] has lifted the panel on [src] back in.", "<span class='notice'>You lift the panel back in.</span>")
		else
			module_door_open = TRUE
			user.visible_message("[user] has lifted the panel off of [src].", "<span class='notice'>You lift the panel off.</span>")
		O.play_tool_sound(src)
		update_icon()
	else if(istype(O, /obj/item/ai_relay_module))
		if(!module_door_open)
			to_chat(user, "<span class='caution'>The module hatch isn't open!</span>")
			return
		if(inserted_module)
			to_chat(user, "<span class='caution'>There's already a module inserted!</span>")
			return
		inserted_module = O
		O.forceMove(src)
	else if(istype(O, /obj/item/multitool))
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "<span class='caution'>The relay is offline!</span>")
			return
		reset_connected_ais()
	else
		return ..()

/obj/machinery/ai_relay/proc/return_module_type()
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(!inserted_module)
		return FALSE
	if(!on)
		return FALSE
	return inserted_module.enabling_tasks

/obj/machinery/ai_relay/proc/reset_connected_ais()
	for(var/A in linked_ais + hacked_ais)
		var/mob/living/silicon/ai/AI = A
		if(!istype(AI))
			continue
		AI.relays -= src
		to_chat(AI, "<span class='userdanger'>You have been disconnected from [src]!</span>")


/obj/machinery/ai_relay/proc/message_ais(msg, include_hacked = TRUE)
	var/list/ais = linked_ais
	if(include_hacked)
		ais += hacked_ais

	for(var/A in ais)
		var/mob/living/silicon/ai/AI = A
		if(!istype(AI))
			continue
		to_chat(AI, msg)

/obj/machinery/ai_relay/update_icon()
	. = ..()

/obj/machinery/ai_relay/allinone
	name = "suspcious processing relay"

	use_power = IDLE_POWER_USE
	idle_power_usage = 25
	active_power_usage = 250 //10x

	generates_heat = FALSE

	inserted_module = /obj/item/ai_relay_module/all_in_one

/obj/machinery/ai_relay/machines
	name = "processing relay - machine interaction"
	inserted_module = /obj/item/ai_relay_module/machine_interaction

/obj/machinery/ai_relay/telecomms
	name = "processing relay - telecommunications control"
	inserted_module = /obj/item/ai_relay_module/telecomms

/obj/machinery/ai_relay/doors
	name = "processing relay - door control"
	inserted_module = /obj/item/ai_relay_module/doors

/obj/machinery/ai_relay/environment
	name = "processing relay - enviromental control"
	inserted_module = /obj/item/ai_relay_module/enviromental

/obj/machinery/ai_relay/power
	name = "processing relay - power manipulation"
	inserted_module = /obj/item/ai_relay_module/power_manip
