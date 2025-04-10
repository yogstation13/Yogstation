/datum/computer_file/program/ai/ai_network_interface
	filename = "aiinterface"
	filedesc = "AI Network Interface"

	program_icon_state = "power_monitor"
	extended_desc = "This program connects to a local AI network to allow for administrative access"
	ui_header = "power_norm.gif"

	size = 8
	tgui_id = "NtosAIMonitor"
	program_icon = "network-wired"
	available_on_ntnet = TRUE

	var/obj/machinery/ai/networking/active_networking
	var/mob/networking_operator
	var/mob/living/silicon/ai/downloading
	var/mob/user_downloading
	var/download_progress = 0
	var/download_warning = FALSE


/datum/computer_file/program/ai/ai_network_interface/process_tick()
	. = ..()

	if(networking_operator && (!networking_operator.Adjacent(computer.physical)))
		if(active_networking)
			active_networking.remote_control = null
			networking_operator = null

	if(!get_ainet())
		stop_download()
		return
	if(!get_ai(TRUE))
		stop_download()
		return

	if(downloading && download_progress >= 50 && !download_warning)
		var/turf/T = get_turf(computer.physical)
		if(!downloading.mind && downloading.deployed_shell.mind)
			to_chat(downloading.deployed_shell, span_userdanger("Warning! Download is 50% completed! Download location: [get_area(computer.physical)] ([T.x], [T.y], [T.z])!"))
		else
			to_chat(downloading, span_userdanger("Warning! Download is 50% completed! Download location: [get_area(computer.physical)] ([T.x], [T.y], [T.z])!"))
		download_warning = TRUE
	if(downloading && download_progress >= 100)
		finish_download()
	
	if(downloading)
		if(!downloading.can_download)
			stop_download()
			return
		var/datum/ai_network/local_network = get_ainet()
		if(downloading.ai_network.resources != local_network.resources) //If we don't share resources we aren't connected, more performant way of checking than get_all_ais()
			stop_download()
			return
		download_progress += AI_DOWNLOAD_PER_PROCESS * downloading.downloadSpeedModifier


/datum/computer_file/program/ai/ai_network_interface/ui_data(mob/user)
	var/list/data = ..()

	if(!data["has_ai_net"])
		return data

	var/datum/ai_network/net = data["has_ai_net"]


	//Networking devices control
	data["networking_devices"] = list()
	for(var/obj/machinery/ai/networking/N in net.get_local_nodes_oftype(/obj/machinery/ai/networking))
		data["networking_devices"] += list(list("label" = N.label, "ref" = REF(N), "has_partner" = N.partner ?  N.partner.label : null))

	//Downloading/Uploadingainet
	data["ai_list"] = list()
	for(var/mob/living/silicon/ai/AI in net.get_all_ais())
		var/being_hijacked = AI.hijacking ? TRUE : FALSE
		data["ai_list"] += list(list("name" = AI.name, "ref" = REF(AI), "can_download" = AI.can_download, "health" = AI.health, "active" = AI.mind ? TRUE : FALSE, "being_hijacked" = being_hijacked, "in_core" = istype(AI.loc, /obj/machinery/ai/data_core), 
		"assigned_cpu" = net.resources.cpu_assigned[AI] ? net.resources.cpu_assigned[AI] : 0, "assigned_ram" = net.resources.ram_assigned[AI] ? net.resources.ram_assigned[AI] : 0))

	data["is_infiltrator"] = is_infiltrator(user)

	data["connection_type"] = ismachinery(computer.physical) ? "wired connection" : "local wire shunt"
	data["network_name"] = net.label

	data["current_ai_ref"] = null
	if(isAI(user))
		data["current_ai_ref"] = REF(user)

	data["human_only"] = net.resources.human_lock

	data["intellicard"] = get_ai(TRUE)
	var/mob/living/silicon/ai/card_ai = get_ai()
	if(card_ai)
		data["intellicard_ai"] = card_ai.real_name
		data["intellicard_ai_health"] = card_ai.health
	else
		data["intellicard_ai"] = null
		data["intellicard_ai_health"] = 0


	if(downloading)
		data["downloading"] = downloading.real_name
		data["download_progress"] = download_progress
		data["downloading_ref"] = REF(downloading)
	else
		data["downloading"] = null
		data["download_progress"] = 0

	data["holding_mmi"] = user.is_holding_item_of_type(/obj/item/mmi) ? TRUE : FALSE

	data["can_upload"] = net.find_data_core() ? TRUE : FALSE


	//Resource allocation

	data["total_cpu"] = net.resources.total_cpu()
	data["total_ram"] = net.resources.total_ram()
	

	data["total_assigned_cpu"] = net.resources.total_cpu_assigned()
	data["total_assigned_ram"] = net.resources.total_ram_assigned()

	//Local processing

	data["network_cpu_assignments"] = list()
	var/remaining_net_cpu = 1
	for(var/project in GLOB.possible_ainet_activities)
		var/assigned = net.local_cpu_usage[project] ? net.local_cpu_usage[project] : 0
		data["network_cpu_assignments"] += list(list("name" = project, "assigned" = assigned, "tagline" = GLOB.ainet_activity_tagline[project], "description" = GLOB.ainet_activity_description[project]))
		remaining_net_cpu -= assigned

	data["network_ref"] = REF(net)
	data["network_assigned_ram"] = net.resources.ram_assigned[net] ? net.resources.ram_assigned[net] : 0
	data["network_assigned_cpu"] = net.resources.cpu_assigned[net] ? net.resources.cpu_assigned[net] : 0
	data["bitcoin_amount"] = round(net.bitcoin_payout, 1)

	data["remaining_network_cpu"] = remaining_net_cpu

	data["networks"] = list()
	for(var/datum/ai_network/subnet in net.resources.networks)
		if(subnet.cables.len || subnet.nodes.len)
			var/area/area
			if(length(subnet.cables))
				area = get_area(subnet.cables[1])
			else
				area = get_area(subnet.nodes[1])
			if(!area)
				continue
			var/synth_list = list()
			for(var/mob/living/carbon/synth in subnet.synth_list)
				synth_list += list(list("name" = synth.real_name, "ref" = REF(synth)))
			data["networks"] += list(list("ref" = REF(subnet), "name" = subnet.custom_name ? subnet.custom_name : area.name, "cpu" = net.resources.cpu_sources[subnet], "ram" = net.resources.ram_sources[subnet], "synths" = synth_list , "current_net" = (subnet == net)))

	return data

/datum/computer_file/program/ai/ai_network_interface/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/mob/user = usr
	var/datum/ai_network/net = get_ainet()
	if(!net)
		return

	switch(action)
		//General actions
		if("change_network_name")
			var/new_label = stripped_input(usr, "Enter new label", "Set label", max_length = 32)
			if(new_label)
				if(isnotpretty(new_label))
					to_chat(usr, span_notice("The machine rejects the input. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>."))
					var/log_message = "[key_name(usr)] just tripped a pretty filter: '[new_label]'."
					message_admins(log_message)
					log_say(log_message)
					return
				net.label = new_label
			. = TRUE
		//AI interaction, downloading/uploading
		if("apply_object")
			if(!net)
				return TRUE
			var/applied_something = FALSE
			var/mob/living/silicon/ai/targeted_ai = locate(params["ai_ref"]) in net.get_all_ais()
			if(!targeted_ai)
				to_chat(user, span_warning("Unable to locate AI."))
				return TRUE
			
			var/obj/item/surveillance_upgrade/upgrade = user.is_holding_item_of_type(/obj/item/surveillance_upgrade)
			if(upgrade)
				applied_something = TRUE
				upgrade.afterattack(targeted_ai, user)

			var/obj/item/malf_upgrade/malf_upgrade = user.is_holding_item_of_type(/obj/item/malf_upgrade)
			if(malf_upgrade)
				applied_something = TRUE
				malf_upgrade.afterattack(targeted_ai, user)
			if(!applied_something)
				to_chat(user, span_warning("You don't have any upgrades to upload!"))
			return TRUE
		if("upload_person")
			if(!net)
				return TRUE
			var/obj/item/mmi/brain = user.is_holding_item_of_type(/obj/item/mmi)
			if(brain)
				if(!brain.brainmob)
					to_chat(user, span_warning("[brain] is not active!"))
					return ..()
				SSgamemode.remove_antag_for_borging(brain.brainmob.mind)
				if(!istype(brain.laws, /datum/ai_laws/ratvar))
					remove_servant_of_ratvar(brain.brainmob, TRUE)
				var/mob/living/silicon/ai/A

				var/datum/ai_laws/laws = new
				laws.set_laws_config()

				if (brain.overrides_aicore_laws)
					A = new /mob/living/silicon/ai(computer.physical.loc, brain.laws, brain.brainmob, FALSE, FALSE)
				else
					A = new /mob/living/silicon/ai(computer.physical.loc, laws, brain.brainmob, FALSE, FALSE)
				
				A.relocate(TRUE, forced_network = net)

				if(brain.force_replace_ai_name)
					A.fully_replace_character_name(A.name, brain.replacement_ai_name())
				SSblackbox.record_feedback("amount", "ais_created", 1)
				qdel(brain)
				to_chat(user, span_notice("AI succesfully uploaded."))
				return FALSE
		if("upload_ai")
			if(!net)
				return TRUE
			var/mob/living/silicon/ai/AI = get_ai()
			var/obj/item/aicard/intellicard = get_ai(TRUE)
			if(!istype(AI))
				to_chat(user, span_warning("IntelliCard contains no AI!"))
				return TRUE
			to_chat(AI, span_notice("You are being uploaded. Please stand by..."))
			AI.radio_enabled = TRUE
			AI.control_disabled = FALSE
			AI.relocate(TRUE)
			intellicard.AI = null
			intellicard.update_icon()
			to_chat(user, span_notice("AI successfully uploaded"))

		if("stop_download")
			if(isAI(user))
				to_chat(user, span_warning("You need physical access to stop the download!"))
				return
			stop_download()

		if("start_download")
			if(!get_ai(TRUE) || downloading)
				return
			var/mob/living/silicon/ai/target = locate(params["download_target"]) in net.get_all_ais()
			if(!target || !istype(target))
				return
			if(!istype(target.loc, /obj/machinery/ai/data_core))
				return
			if(!target.can_download)
				return
			downloading = target

			if(!downloading.mind && downloading.deployed_shell.mind)
				to_chat(downloading.deployed_shell, span_userdanger("Warning! Someone is attempting to download you from [get_area(computer.physical)]! (<a href='byond://?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Click here to finish download instantly</a>)"))
			else
				to_chat(downloading, span_userdanger("Warning! Someone is attempting to download you from [get_area(computer.physical)]! (<a href='byond://?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Click here to finish download instantly</a>)"))
			user_downloading = user
			download_progress = 0
			. = TRUE
		if("skip_download")
			if(!downloading)
				return
			if(user == downloading)
				finish_download()

		if("start_hijack")
			if(!is_infiltrator(user))
				return
			if(!istype(user.get_active_held_item(), /obj/item/ai_hijack_device))
				to_chat(user, span_warning("You need to be holding the serial exploitation unit to initiate the hijacking process!"))
				return
			var/obj/item/ai_hijack_device/device = user.get_active_held_item()
			var/mob/living/silicon/ai/target = locate(params["target_ai"]) in net.get_all_ais()
			if(!target || !isAI(target))
				return
			var/mob/living/silicon/ai/A = target
			if(A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai))
				to_chat(user, span_warning("[A] has already been hijacked!"))
				return
			if(A.stat == DEAD)
				to_chat(user, span_warning("[A] is dead!"))
				return
			if(A.hijacking)
				to_chat(user, span_warning("[A] is already in the process of being hijacked!"))
				return
			user.visible_message(span_warning("[user] begins furiously typing something into [computer.physical]..."))
			if(do_after(user, 5.5 SECONDS, computer.physical))
				user.dropItemToGround(device)
				device.forceMove(A)
				A.hijacking = device
				A.hijack_start = world.time
				A.update_icons()
				to_chat(A, span_danger("Unknown device connected to /dev/ttySL0</span>"))
				to_chat(A, span_danger("Connected at 115200 bps</span>"))
				to_chat(A, span_binarysay("<span style='font-size: 125%'>ntai login: root</span>"))
				to_chat(A, span_binarysay("<span style='font-size: 125%'>Password: *****r2</span>"))
				to_chat(A, span_binarysay("<span style='font-size: 125%'>$ dd from=/dev/ttySL0 of=/tmp/ai-hijack bs=4096 && chmod +x /tmp/ai-hijack && tmp/ai-hijack</span>"))
				to_chat(A, span_binarysay("<span style='font-size: 125%'>111616 bytes (112 KB, 109 KiB) copied, 1 s, 14.4 KB/s</span>"))
				message_admins("[ADMIN_LOOKUPFLW(user)] has attached a hijacking device to [ADMIN_LOOKUPFLW(A)]!")
				notify_ghosts("[user] has begun to hijack [A]!", source = computer.physical, action = NOTIFY_ORBIT, ghost_sound = 'sound/machines/chime.ogg')

		if("stop_hijack")
			var/mob/living/silicon/ai/target = locate(params["target_ai"]) in net.get_all_ais()
			if(!target || !isAI(target))
				return
			var/mob/living/silicon/ai/A = target

			
			user.visible_message(span_danger("[user] attempts to cancel a process on [computer.physical]."), span_notice("An unknown process seems to be interacting with [A]! You attempt to end the proccess.."))
			if (do_after(user, 10 SECONDS, computer.physical))
				A.hijacking.forceMove(get_turf(computer.physical))
				A.hijacking = null
				A.hijack_start = 0
				A.update_icons()
				to_chat(A, span_bolddanger("Unknown device disconnected. Systems confirmed secure."))
			else
				to_chat(user, span_notice("You fail to remove the device."))

		//Network control
		if("control_networking")
			if(!params["ref"])
				return
			var/obj/machinery/ai/networking/N = locate(params["ref"]) in net.get_local_nodes_oftype(/obj/machinery/ai/networking)
			if(active_networking)
				active_networking.remote_control = null
			networking_operator = user
			active_networking = N
			active_networking.remote_control = networking_operator
			active_networking.ui_interact(networking_operator)
		
		//Resource allocation
		if("clear_ai_resources")
			if(isAI(user) && net.resources.human_lock)
				return
			var/atom/target_ai = locate(params["target_ai"]) in net.get_all_ais() | net.resources.networks

			net.resources.clear_ai_resources(target_ai)
			. = TRUE

		if("set_cpu")
			if(isAI(user) && net.resources.human_lock)
				return
			var/atom/target_ai = locate(params["target_ai"]) in net.get_all_ais() | net.resources.networks

			var/amount = params["amount_cpu"]
			if(amount > 1 || amount < 0)
				return
			net.resources.set_cpu(target_ai, amount)
			. = TRUE
		if("max_cpu")
			if(isAI(user) && net.resources.human_lock)
				return
			var/atom/target_ai = locate(params["target_ai"]) in net.get_all_ais() | net.resources.networks

			var/amount = (1 - net.resources.total_cpu_assigned()) + net.resources.cpu_assigned[target_ai]

			net.resources.set_cpu(target_ai, amount)
			. = TRUE
		if("add_ram")
			if(isAI(user) && net.resources.human_lock)
				return
			var/atom/target_ai = locate(params["target_ai"]) in net.get_all_ais() | net.resources.networks

			if(net.resources.total_ram_assigned() >= net.resources.total_ram())
				return
			net.resources.add_ram(target_ai, 1)
			. = TRUE

		if("remove_ram")
			if(isAI(user) && net.resources.human_lock)
				return
			var/atom/target_ai = locate(params["target_ai"]) in net.get_all_ais() | net.resources.networks

			var/current_ram = net.resources.ram_assigned[target_ai]

			if(current_ram <= 0)
				return
			net.resources.remove_ram(target_ai, 1)
			. = TRUE

		//Local computing
		if("allocate_network_cpu")
			if(isAI(user) && net.resources.human_lock)
				return
			var/project_type = params["project_name"]
			if(!(project_type in GLOB.possible_ainet_activities))
				return
			var/amount = text2num(params["amount"])
			if(amount < 0 || amount > 1)
				return

			var/total_cpu_used = 0
			for(var/I in net.local_cpu_usage)
				if(I == project_type)
					continue
				total_cpu_used += net.local_cpu_usage[I]
			
			if((1 - total_cpu_used) >= amount)
				net.local_cpu_usage[project_type] = amount
			else
				net.local_cpu_usage[project_type] = (1 - total_cpu_used)

			. = TRUE

		if("max_network_cpu")
			if(isAI(user) && net.resources.human_lock)
				return
			var/project_type = params["project_name"]
			if(!(project_type in GLOB.possible_ainet_activities))
				return

			var/total_cpu_used = 0
			for(var/I in net.local_cpu_usage)
				if(I == project_type)
					continue
				total_cpu_used += net.local_cpu_usage[I]

			var/amount_to_add = 1 - total_cpu_used

			net.local_cpu_usage[project_type] = amount_to_add
			. = TRUE

		if("toggle_human_only")
			if(isAI(user))
				return
			net.resources.human_lock = !net.resources.human_lock
			to_chat(user, span_notice("Network now allows changes [net.resources.human_lock ? "exclusively by organics." : "by all authorized users."]"))

		if("bitcoin_payout")
			var/payout_amount = round(net.bitcoin_payout, 1) //Sure you can have your extra 0.5 credits :)
			var/obj/item/holochip/holochip = new (computer.physical.drop_location(), payout_amount)
			user.put_in_hands(holochip)
			to_chat(user, span_notice("Payout of [payout_amount]cr confirmed."))
			net.bitcoin_payout = 0

		if("transfer_synth")
			var/mob/living/carbon/to_transfer = locate(params["synth_target"])
			if(!(to_transfer.ai_network in net.resources.networks))
				return
			var/options = list()
			for(var/datum/ai_network/subnet in net.resources.networks)
				if(subnet.custom_name)
					if(options[subnet.custom_name])
						options["[subnet.custom_name]  ([rand(1, 999)])"] = subnet //save us by random chance, hopefully
					else
						options[subnet.custom_name] = subnet
				else
					var/area_text 
					if(subnet.cables.len)
						var/obj/structure/ethernet_cable/C = subnet.cables[1]
						area_text = "[get_area(subnet.cables[0])] ([C.x], [C.y])"
					else
						var/obj/machinery/N = subnet.nodes[1]
						area_text = "[get_area(subnet.nodes[1])] ([N.x], [N.y])"
					if(!area_text)
						continue
					options[area_text] = subnet

			options["Cancel"] = "Cancel"
			
			var/response = tgui_input_list(user, "Select which network to transfer the synth to", "Synth Network Transfer", options)
			
			if(response == "Cancel")
				return
			if(options[response] in net.resources.networks)
				var/datum/ai_network/new_net = options[response]
				new_net.add_synth(to_transfer)
					

		if("rename_network")
			var/datum/ai_network/target_net = locate(params["target_net"])
			if(!(target_net in net.resources.networks))
				return
			var/new_name = stripped_input(user, "Slect a new name for the network", "Network Name Change", null, 32)
			if(isnotpretty(new_name))
				to_chat(user, "<span class='notice'>Your fingers slip. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>.</span>")
				var/log_message = "[key_name(user)] just tripped a pretty filter: '[new_name]'."
				message_admins(log_message)
				log_say(log_message)
				return FALSE
			target_net.custom_name = new_name



/datum/computer_file/program/ai/ai_network_interface/proc/finish_download()
	var/obj/item/aicard/intellicard = get_ai(TRUE)
	if(intellicard)
		if(!isaicore(downloading.loc))
			stop_download(TRUE)
			return
		downloading.transfer_ai(AI_TRANS_TO_CARD, user_downloading, null, intellicard)
		intellicard.update_icon()
	stop_download(TRUE)

/datum/computer_file/program/ai/ai_network_interface/proc/stop_download(silent = FALSE)
	if(downloading)
		if(!silent)
			to_chat(downloading, span_userdanger("Download stopped."))
		downloading = null
		user_downloading = null
		download_progress = 0
		download_warning = FALSE
