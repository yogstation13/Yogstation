/*
	The equivalent of the server, for PDA and request console messages.
	Without it, PDA and request console messages cannot be transmitted.
	PDAs require the rest of the telecomms setup, but request consoles only
	require the message server.
*/

// A decorational representation of SSblackbox, usually placed alongside the message server. Contains the Blackbox item for traitor theft objectives.
/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 70)
	var/obj/item/stored

/obj/machinery/blackbox_recorder/Initialize(mapload)
	. = ..()
	stored = new /obj/item/blackbox(src)

/obj/machinery/blackbox_recorder/attack_hand(mob/living/user)
	. = ..()
	if(stored)
		user.put_in_hands(stored)
		stored = null
		to_chat(user, span_notice("You remove the blackbox from [src]. The tapes stop spinning."))
		update_appearance(UPDATE_ICON)
		return
	else
		to_chat(user, span_warning("It seems that the blackbox is missing..."))
		return

/obj/machinery/blackbox_recorder/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/blackbox))
		if(HAS_TRAIT(I, TRAIT_NODROP) || !user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] clicks [I] into [src]!"), \
		span_notice("You press the device into [src], and it clicks into place. The tapes begin spinning again."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		stored = I
		update_appearance(UPDATE_ICON)
		return ..()
	return ..()

/obj/machinery/blackbox_recorder/Destroy()
	if(stored)
		stored.forceMove(loc)
		new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/obj/machinery/blackbox_recorder/update_icon_state()
	. = ..()
	if(!stored)
		icon_state = "blackbox_b"
	else
		icon_state = "blackbox"

/obj/item/blackbox
	name = "the blackbox"
	desc = "A strange relic, capable of recording data on extradimensional vertices. It lives inside the blackbox recorder for safe keeping."
	icon = 'icons/obj/device.dmi'
	icon_state = "blackcube"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

#define MESSAGE_SERVER_FUNCTIONING_MESSAGE "This is an automated message. The messaging system is functioning correctly."

// The message server itself.
/obj/machinery/telecomms/message_server
	icon_state = "message_server"
	name = "Messaging Server"
	desc = "A machine that processes and routes PDA and request console messages."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/telecomms/message_server

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/decryptkey = "password"
	var/calibrating = 15 MINUTES //Init reads this and adds world.time, then becomes 0 when that time has passed and the machine works

/obj/machinery/telecomms/message_server/Initialize(mapload)
	. = ..()
	if (!decryptkey)
		decryptkey = GenerateKey()

	if (calibrating)
		calibrating += world.time
		say("Calibrating... Estimated wait time: [rand(3, 9)] minutes.")
		pda_msgs += new /datum/data_pda_msg("System Administrator", "system", "This is an automated message. System calibration started at [station_time_timestamp()]")
	else
		pda_msgs += new /datum/data_pda_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

/obj/machinery/telecomms/message_server/Destroy()
	for(var/obj/machinery/computer/message_monitor/monitor in GLOB.telecomms_list)
		if(monitor.linkedServer && monitor.linkedServer == src)
			monitor.linkedServer = null
	. = ..()

/obj/machinery/telecomms/message_server/examine(mob/user)
	. = ..()
	if(calibrating)
		. += span_warning("It's still calibrating.")

/obj/machinery/telecomms/message_server/proc/GenerateKey()
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

/obj/machinery/telecomms/message_server/process()
	. = ..()
	if(calibrating && calibrating <= world.time)
		calibrating = 0
		pda_msgs += new /datum/data_pda_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

/obj/machinery/telecomms/message_server/receive_information(datum/signal/subspace/messaging/signal, obj/machinery/telecomms/machine_from)
	// can't log non-message signals
	if(!istype(signal) || !signal.data["message"] || !on || calibrating)
		return

	if(istype(signal, /datum/signal/subspace/messaging/ntospda))
		var/datum/computer_file/program/pdamessager/recipient = signal.data["targets"][1]
		var/datum/computer_file/program/pdamessager/sender = signal.data["program"]
		GLOB.NTPDAMessages += list(list(sender.username, recipient.username, signal.data["message"]))
		var/datum/data_pda_msg/M = new(recipient.username, sender.username, signal.data["message"])
		pda_msgs += M
		signal.logged = TRUE
		var/datum/signal/subspace/current = signal
		while (current) // Recursively mark logged so we know in the caller_but_not_a_byond_built_in_proc proc that it is logged and sent proper
			current.data["logged"] = TRUE
			current = current.original
	else if(istype(signal, /datum/signal/subspace/messaging/rc))
		var/datum/data_rc_msg/M = new(signal.data["rec_dpt"], signal.data["send_dpt"], signal.data["message"], signal.data["stamped"], signal.data["verified"], signal.data["priority"])
		signal.logged = M
		if(signal.data["send_dpt"]) // don't log messages not from a department but allow them to work
			rc_msgs += M
	signal.data["reject"] = FALSE

	// pass it along to either the hub or the broadcaster
	if(!relay_information(signal, /obj/machinery/telecomms/hub))
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

/obj/machinery/telecomms/message_server/update_overlays()
	. = ..()
	if(calibrating && on)
		var/mutable_appearance/calibrate = mutable_appearance(icon, "message_server_disabled")
		. += calibrate


// Root messaging signal datum
/datum/signal/subspace/messaging
	frequency = FREQ_COMMON
	server_type = /obj/machinery/telecomms/message_server
	var/logged = FALSE

/datum/signal/subspace/messaging/New(init_source, init_data)
	source = init_source
	data = init_data
	var/turf/T
	if(istype(source, /datum/computer_file/program)) //programs don't actually have locations
		var/datum/computer_file/program/P = source
		T = get_turf_global(P.computer)
	else
		T = get_turf_global(source)

	if(T)
		levels = SSmapping.get_connected_levels(T)
	else
		levels = SSmapping.levels_by_trait(ZTRAIT_STATION) //just assume we're on station..
	if(!("reject" in data))
		data["reject"] = TRUE

/datum/signal/subspace/messaging/copy()
	var/datum/signal/subspace/messaging/copy = new type(source, data.Copy())
	copy.original = src
	copy.levels = levels
	return copy

// NTOS PDA signal datum
/datum/signal/subspace/messaging/ntospda
	var/datum/language/lang // Stores what language the message was written in.
	var/datum/computer_file/program/pdamessager/program

/datum/signal/subspace/messaging/ntospda/New(init_source,init_data)
	..()
	lang = data["language"] || /datum/language/common

/datum/signal/subspace/messaging/ntospda/proc/format_message(mob/living/listener)
	var/msg = data["message"]
	if(istype(listener) && !listener.has_language(lang))
		var/datum/language/langue = GLOB.language_datum_instances[lang]
		msg = langue.scramble(msg)
	return msg

/datum/signal/subspace/messaging/ntospda/broadcast()
	if (!logged)  // Can only go through if a message server logs it
		return
	for(var/datum/computer_file/program/pdamessager/P in data["targets"])
		P.receive_message(src)

// Request Console signal datum
/datum/signal/subspace/messaging/rc/broadcast()
	if (!logged)  // Like /pda, only if logged
		return
	var/rec_dpt = ckey(data["rec_dpt"])
	for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
		if(ckey(Console.department) == rec_dpt || (data["ore_update"] && Console.receive_ore_updates))
			Console.createmessage(data["sender"], data["send_dpt"], data["message"], data["verified"], data["stamped"], data["priority"], data["notify_freq"])

// Log datums stored by the message server.
/datum/data_pda_msg
	var/sender = "Unspecified"
	var/recipient = "Unspecified"
	var/message = "Blank"  // transferred message
	var/datum/picture/picture  // attached photo
	var/automated = 0 //automated message

/datum/data_pda_msg/New(param_rec, param_sender, param_message, param_photo)
	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message
	if(param_photo)
		picture = param_photo

/datum/data_pda_msg/Topic(href,href_list)
	..()
	if(href_list["photo"])
		var/mob/M = usr
		M << browse_rsc(picture.picture_image, "pda_photo.png")
		M << browse("<html><head><meta charset='UTF-8'><title>PDA Photo</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='pda_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "</body></html>", "window=pdaphoto;size=[picture.psize_x]x[picture.psize_y];can-close=true")
		onclose(M, "pdaphoto")

/datum/data_rc_msg
	var/rec_dpt = "Unspecified"  // receiving department
	var/send_dpt = "Unspecified"  // sending department
	var/message = "Blank"
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(param_rec, param_sender, param_message, param_stamp, param_id_auth, param_priority)
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(REQ_NORMAL_MESSAGE_PRIORITY)
				priority = "Normal"
			if(REQ_HIGH_MESSAGE_PRIORITY)
				priority = "High"
			if(REQ_EXTREME_MESSAGE_PRIORITY)
				priority = "Extreme"
			else
				priority = "Undetermined"

#undef MESSAGE_SERVER_FUNCTIONING_MESSAGE

/obj/machinery/telecomms/message_server/preset
	id = "Messaging Server"
	network = "tcommsat"
	autolinkers = list("messaging")
	decryptkey = null //random
	calibrating = 0
