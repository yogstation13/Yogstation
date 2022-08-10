GLOBAL_LIST_EMPTY(ai_networking_machines)

/obj/machinery/ai/networking
	name = "networking machine"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
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
			connect_to_partner(N, TRUE)
			break
		if(!roundstart_connection)
			connect_to_partner(N, TRUE)
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
		network.resources.split_resources(partner.network)
		partner.partner = null
		partner = null
		

/obj/machinery/ai/networking/proc/connect_to_partner(obj/machinery/ai/networking/target, roundstart = FALSE)
	if(target.partner)
		return
	if(target == src)
		return
	

	partner = target
	rotation_to_partner = Get_Angle(src, partner)
	target.partner = src
	target.rotation_to_partner = Get_Angle(target, src)
	target.update_icon()

	if(roundstart) //Resources aren't initialized yet, they'll automatically rebuild the remotes when they are
		network.resources.add_resource(partner.network.resources)

	update_icon()
	

/obj/machinery/ai/networking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiNetworking", name)
		ui.open()

/obj/machinery/ai/networking/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["is_connected"] = partner ? TRUE : FALSE
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
			var/new_label = stripped_input(usr, "Enter new label", "Set label", max_length = 16)
			if(new_label)
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
					if(partner)
						disconnect()
					connect_to_partner(N)
					return
			. = TRUE
		if("disconnect")
			disconnect()
			. = TRUE
		if("toggle_lock")
			locked = !locked
			. = TRUE

