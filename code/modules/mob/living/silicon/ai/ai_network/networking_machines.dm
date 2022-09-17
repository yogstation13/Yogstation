GLOBAL_LIST_EMPTY(ai_networking_machines)

/obj/machinery/ai/networking
	name = "networking machine"
	desc = "A high powered combined transmitter and receiver. Capable of connecting remote AI networks with near-zero delay."
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "sp_base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150
	integrity_failure = 0.33

	var/label
	//For mapping, will connect to machine with this label if found
	var/roundstart_connection

	var/mutable_appearance/panelstructure
	var/mutable_appearance/paneloverlay

	var/obj/machinery/ai/networking/partner
	var/rotation_to_partner
	var/locked = FALSE
	var/mob/remote_control


/obj/machinery/ai/networking/Initialize(mapload)
	. = ..()
	if(!label)
		label = num2hex(rand(1,65535), -1)
	GLOB.ai_networking_machines += src
	panelstructure = mutable_appearance(icon, "solar_panel", FLY_LAYER)
	paneloverlay = mutable_appearance(icon, "solar_panel-o", FLY_LAYER)
	paneloverlay.color = "#599ffa"
	update_icon(TRUE)

/obj/machinery/ai/networking/Destroy(mapload)
	GLOB.ai_networking_machines -= src
	disconnect()
	. = ..()
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


/obj/machinery/ai/networking/update_icon(forced = FALSE)
	..()
	if(!rotation_to_partner && !forced)
		return
	cut_overlays()
	var/matrix/turner = matrix()
	turner.Turn(rotation_to_partner)
	panelstructure.transform = turner
	paneloverlay.transform = turner
	add_overlay(list(paneloverlay, panelstructure))

/obj/machinery/ai/networking/proc/disconnect()
	if(partner)
		var/datum/ai_network/AN = partner.network
		partner.partner = null
		partner = null
		AN.rebuild_remote()
		network.rebuild_remote()
		

/obj/machinery/ai/networking/proc/connect_to_partner(obj/machinery/ai/networking/target)
	if(target.partner)
		return
	if(target == src)
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
	
/obj/machinery/ai/networking/disconnect_from_network()
	var/datum/ai_network/temp = network
	. = ..()
	if(partner)
		temp.rebuild_remote()
