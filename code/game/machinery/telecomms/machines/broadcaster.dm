/*
	The broadcaster sends processed messages to all radio devices in the game. They
	do not have to be headsets; intercoms and station-bounced radios suffice.

	They receive their message from a server after the message has been logged.
*/

GLOBAL_LIST_EMPTY(recentmessages) // global list of recent messages broadcasted : used to circumvent massive radio spam
GLOBAL_VAR_INIT(message_delay, 0) // To make sure restarting the recentmessages list is kept in sync

/obj/machinery/telecomms/broadcaster
	name = "subspace broadcaster"
	icon_state = "caster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 25
	circuit = /obj/item/circuitboard/machine/telecomms/broadcaster
	on_icon = "broadcaster_on"

/obj/machinery/telecomms/broadcaster/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	// Don't broadcast rejected signals
	if(!istype(signal))
		return
	if(signal.data["reject"])
		return
	if(!signal.data["message"])
		return

	// Prevents massive radio spam
	signal.mark_done()
	var/datum/signal/subspace/original = signal.original
	if(original && ("compression" in signal.data))
		original.data["compression"] = signal.data["compression"]

	var/turf/T = get_turf(src)
	if (T)
		signal.levels |= SSmapping.get_connected_levels(T)

	var/signal_message = "[signal.frequency]:[signal.data["message"]]:[signal.data["name"]]"
	if(signal_message in GLOB.recentmessages)
		return
	GLOB.recentmessages.Add(signal_message)

	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary

	signal.broadcast()

	if(!GLOB.message_delay)
		GLOB.message_delay = 1
		spawn(10)
			GLOB.message_delay = 0
			GLOB.recentmessages = list()

	/* --- Do a snazzy animation! --- */
	var/mutable_appearance/sending = mutable_appearance(icon, "broadcaster_send", 1)
	flick(sending, src)

/obj/machinery/telecomms/broadcaster/update_overlays()
	. = ..()
	if(on)
		var/mutable_appearance/on_overlay = mutable_appearance(icon, on_icon, 0)
		. += on_overlay
	var/mutable_appearance/base_overlay
	if(panel_open)
		base_overlay = mutable_appearance(icon, "[initial(icon_state)]_o")
	else
		base_overlay = mutable_appearance(icon, initial(icon_state))
	. += base_overlay

/obj/machinery/telecomms/broadcaster/Destroy()
	// In case message_delay is left on 1, otherwise it won't reset the list and people can't say the same thing twice anymore.
	if(GLOB.message_delay)
		GLOB.message_delay = 0
	return ..()



//Preset Broadcasters

//--PRESET LEFT--//

/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

//--PRESET RIGHT--//

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_left/birdstation
	name = "Broadcaster"
