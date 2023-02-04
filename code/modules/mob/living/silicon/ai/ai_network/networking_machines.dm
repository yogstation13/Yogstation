GLOBAL_LIST_EMPTY(ai_networking_machines)

/obj/machinery/ai/networking
	name = "networking machine"
	desc = "A high powered combined transmitter and receiver. Capable of connecting remote AI networks with near-zero delay. It is possible to manually connect other machines using a multitool."
	icon = 'icons/obj/networking_machine.dmi'
	icon_state = "base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150

	circuit = /obj/item/circuitboard/machine/networking_machine

	var/label
	//For mapping, will connect to machine with this label if found
	var/roundstart_connection

	var/mutable_appearance/dish_overlay

	var/obj/machinery/ai/networking/partner
	var/rotation_to_partner = 0
	var/locked = FALSE
	var/obj/machinery/ai/networking/remote_connection_attempt
	var/mob/remote_control

	var/datum/ai_network/cached_old_network




/obj/machinery/ai/networking/Initialize(mapload)
	. = ..()
	if(!label)
		label = num2hex(rand(1,65535), -1)
	GLOB.ai_networking_machines += src
	dish_overlay = mutable_appearance(icon, "top", FLY_LAYER)
	update_icon()

/obj/machinery/ai/networking/Destroy(mapload)
	GLOB.ai_networking_machines -= src
	disconnect()
	. = ..()

/obj/machinery/ai/networking/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(partner)
			to_chat(user, span_warning("This machine is already connected to a different machine! Disconnect it using the controls or a wirecutter first!"))
			return TRUE
		remote_connection_attempt = null
		var/targets = list()
		for(var/obj/machinery/ai/networking/N in GLOB.ai_networking_machines)
			if(N == src)
				continue
			if(N.z != src.z)
				continue
			if(N.partner)
				continue
			targets[N.label] = N
		var/attempt_connect = input(user, "Select the machine you wish to attempt connecting to.") as null|anything in targets
		if(!attempt_connect)
			return TRUE
		var/obj/machinery/ai/networking/remote_target = locate(targets[attempt_connect]) in GLOB.ai_networking_machines
		if(!remote_target)
			return TRUE
		remote_connection_attempt = remote_target
		to_chat(user, span_notice("The machine is ready to establish connection. You must now rotate it so it faces the other machine! Rotation is done using a wrench, and the connection can then be finalized with a screwdriver when aligned."))
		return TRUE
	
	if(W.tool_behaviour == TOOL_WRENCH)
		if(partner)
			to_chat(user, span_warning("This machine is already connected to a different machine!"))
			return TRUE
		var/new_rotation = input(user, "Set rotation (0-360): ") as null|num
		if(isnull(new_rotation))
			rotation_to_partner = 0
		else
			new_rotation = clamp(new_rotation, 0, 360)
			rotation_to_partner = new_rotation
		
		update_icon()
		return TRUE

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(partner)
			to_chat(user, span_warning("This machine is already connected to a different machine!"))
			return TRUE
		if(!remote_connection_attempt)
			to_chat(user, span_warning("You need to initialize a manual override using a wrench to connect to something!"))
			return TRUE
		var/actual_angle = Get_Angle(src, remote_connection_attempt)
		if(rotation_to_partner < actual_angle + 20 && rotation_to_partner > actual_angle - 20)
			connect_to_partner(remote_connection_attempt)
			to_chat(user, span_notice("You successfully connect to [remote_connection_attempt.label]!"))
			return TRUE
		to_chat(user, span_warning("Unable to establish connection!"))
		return TRUE


	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(partner)
			to_chat(user, span_notice("You disconnect the remote connection."))
			disconnect()
			return TRUE
		to_chat(user, span_warning("The machine isn't connected!"))
		return TRUE

	if(W.tool_behaviour == TOOL_CROWBAR)
		if(default_deconstruction_crowbar(W, TRUE))
			return TRUE

	if(default_deconstruction_screwdriver(user, "expansion_bus_o", "expansion_bus", W))
		return TRUE

	return ..()

/obj/machinery/ai/networking/proc/roundstart_connect(mapload)
	for(var/obj/machinery/ai/networking/N in GLOB.ai_networking_machines)
		if(partner)
			break
		if(N == src)
			continue
		if(N.partner)
			continue
		if(roundstart_connection && N.label == roundstart_connection)
			connect_to_partner(N)
			break
		if(!roundstart_connection)
			connect_to_partner(N)
			break


/obj/machinery/ai/networking/update_icon()
	..()
	cut_overlays()
	var/matrix/turner = matrix()
	turner.Turn(rotation_to_partner - 180)
	dish_overlay.transform = turner
	add_overlay(dish_overlay)

/obj/machinery/ai/networking/proc/disconnect()
	if(partner)
		var/datum/ai_network/AN = partner.network
		partner.rotation_to_partner = 0
		partner.update_icon()
		partner.partner = null
		partner = null
		AN.rebuild_remote()
		network.rebuild_remote()
		AN.network_machine_disconnected(network)
		network.network_machine_disconnected(AN)
		rotation_to_partner = 0
		update_icon()

		

/obj/machinery/ai/networking/proc/connect_to_partner(obj/machinery/ai/networking/target, forced = FALSE)
	remote_connection_attempt = null
	if(target.partner)
		return
	if(target == src)
		return
	if(target.locked && !forced)
		return

	partner = target
	rotation_to_partner = Get_Angle(src, partner)
	target.partner = src
	target.rotation_to_partner = Get_Angle(target, src)
	target.update_icon()

	
	network.rebuild_remote()

	update_icon()
	

/obj/machinery/ai/networking/ui_status(mob/user)
	. = ..()
	if (!QDELETED(remote_control) && user == remote_control)
		. = UI_INTERACTIVE

/obj/machinery/ai/networking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiNetworking", name)
		ui.open()

/obj/machinery/ai/networking/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["is_connected"] = partner ? partner.label : FALSE
	data["label"] = label

	data["locked"] = locked

	data["possible_targets"] = list()
	for(var/obj/machinery/ai/networking/N in GLOB.ai_networking_machines)
		if(N == src)
			continue
		if(N.z != src.z)
			continue
		if(N.locked)
			continue
		data["possible_targets"] += N.label

	return data

/obj/machinery/ai/networking/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("switch_label")
			if(locked)
				return
			var/new_label = stripped_input(usr, "Enter new label", "Set label", max_length = 16)
			if(new_label)
				if(isnotpretty(new_label))
					to_chat(usr, span_notice("The machine rejects the input. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>."))
					var/log_message = "[key_name(usr)] just tripped a pretty filter: '[new_label]'."
					message_admins(log_message)
					log_say(log_message)
					return
				for(var/obj/machinery/ai/networking/N in GLOB.ai_networking_machines)
					if(N.label == new_label)
						to_chat(usr, span_warning("A machine with this label already exists!"))
						return
				label = new_label
			. = TRUE
		if("connect")
			if(locked)
				return
			var/target_label = params["target_label"]
			if(target_label == label)
				return
			for(var/obj/machinery/ai/networking/N in GLOB.ai_networking_machines)
				if(N.z != src.z)
					return
				if(N.label == target_label)
					if(N.locked)
						to_chat(usr, span_warning("Unable to connect to '[target_label]'! It seems to be locked."))
						return
					if(N.partner)
						to_chat(usr, span_warning("Unable to connect to '[target_label]'! It seems to already have a connection established."))
						return
					connect_to_partner(N)
					to_chat(usr, span_notice("Connection established to '[target_label]'."))
					return
			. = TRUE
		if("disconnect")
			if(locked)
				return
			disconnect()
			. = TRUE
		if("toggle_lock")
			locked = !locked
			. = TRUE

/obj/machinery/ai/networking/connect_to_network()
	. = ..()
	if(partner)
		network.rebuild_remote()
		if(cached_old_network)
			cached_old_network.network_machine_disconnected(network)
			cached_old_network = null
	
/obj/machinery/ai/networking/disconnect_from_network()
	var/datum/ai_network/temp = network
	cached_old_network = temp
	. = ..()
	if(partner)
		temp.rebuild_remote()
