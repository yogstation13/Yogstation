/datum/computer_file/program/ai_network_interface
	filename = "aiinterface"
	filedesc = "AI Network Interface"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to a local AI network to allow for administrative access"
	ui_header = "power_norm.gif"
	transfer_access = ACCESS_NETWORK
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET
	requires_ntnet = FALSE
	size = 8
	tgui_id = "NtosAIMonitor"
	program_icon = "network-wired"

	var/obj/structure/ethernet_cable/attached_cable
	var/obj/machinery/ai/networking/active_networking
	var/mob/networking_operator
	var/mob/living/silicon/ai/downloading
	var/mob/user_downloading
	var/download_progress = 0
	var/download_warning = FALSE




/datum/computer_file/program/ai_network_interface/run_program(mob/living/user)
	. = ..(user)
	if(ismachinery(computer.physical))
		search()


/datum/computer_file/program/ai_network_interface/process_tick()
	if(ismachinery(computer.physical) && !get_ainet())
		search()

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
		download_progress += AI_DOWNLOAD_PER_PROCESS * downloading.downloadSpeedModifier


/datum/computer_file/program/ai_network_interface/proc/search()
	var/turf/T = get_turf(computer)
	attached_cable = locate(/obj/structure/ethernet_cable) in T
	if(attached_cable)
		return

/datum/computer_file/program/ai_network_interface/proc/get_ainet()
	if(ismachinery(computer.physical))
		if(attached_cable)
			return attached_cable.network
	if(computer.all_components[MC_AI_NETWORK])
		var/obj/item/computer_hardware/ai_interface/ai_interface = computer.all_components[MC_AI_NETWORK]
		if(ai_interface)
			return ai_interface.get_network()
	return FALSE

/datum/computer_file/program/ai_network_interface/ui_data(mob/user)
	var/list/data = get_header_data()
	var/datum/ai_network/net = get_ainet()
	data["has_ai_net"] = net

	if(!net)
		return data

	data["networking_devices"] = list()
	for(var/obj/machinery/ai/networking/N in net.get_local_nodes_oftype(/obj/machinery/ai/networking))
		data["networking_devices"] += list(list("label" = N.label, "ref" = REF(N)))

	data["ai_list"] = list()
	for(var/mob/living/silicon/ai/AI in net.get_all_ais())
		var/being_hijacked = AI.hijacking ? TRUE : FALSE
		data["ai_list"] += list(list("name" = AI.name, "ref" = REF(AI), "can_download" = AI.can_download, "health" = AI.health, "active" = AI.mind ? TRUE : FALSE, "being_hijacked" = being_hijacked, "in_core" = istype(AI.loc, /obj/machinery/ai/data_core)))

	data["is_infiltrator"] = is_infiltrator(user)

	data["connection_type"] = ismachinery(computer.physical) ? "wired connection" : "local wire shunt"

	data["current_ai_ref"] = null
	if(isAI(user))
		data["current_ai_ref"] = REF(user)

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

	data["available_cpu_resources"] = (1 - net.resources.total_cpu_assigned())
	data["network_cpu_resources"] = net.resources.cpu_assigned[net]

	data["network_cpu_assignments"] = list(net.local_cpu_usage)



	return data

/datum/computer_file/program/ai_network_interface/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/mob/user = usr
	var/datum/ai_network/net = get_ainet()
	if(!net)
		return

	switch(action)
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
				SSticker.mode.remove_antag_for_borging(brain.brainmob.mind)
				if(!istype(brain.laws, /datum/ai_laws/ratvar))
					remove_servant_of_ratvar(brain.brainmob, TRUE)
				var/mob/living/silicon/ai/A

				var/datum/ai_laws/laws = new
				laws.set_laws_config()

				if (brain.overrides_aicore_laws)
					A = new /mob/living/silicon/ai(computer.physical.loc, brain.laws, brain.brainmob)
				else
					A = new /mob/living/silicon/ai(computer.physical.loc, laws, brain.brainmob)
				
				A.relocate(TRUE)

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
				to_chat(downloading.deployed_shell, span_userdanger("Warning! Someone is attempting to download you from [get_area(computer.physical)]! (<a href='?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Click here to finish download instantly</a>)"))
			else
				to_chat(downloading, span_userdanger("Warning! Someone is attempting to download you from [get_area(computer.physical)]! (<a href='?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Click here to finish download instantly</a>)"))
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
		


/datum/computer_file/program/ai_network_interface/proc/finish_download()
	var/obj/item/aicard/intellicard = get_ai(TRUE)
	if(intellicard)
		if(!isaicore(downloading.loc))
			stop_download(TRUE)
			return
		downloading.transfer_ai(AI_TRANS_TO_CARD, user_downloading, null, intellicard)
		intellicard.update_icon()
	stop_download(TRUE)

/datum/computer_file/program/ai_network_interface/proc/stop_download(silent = FALSE)
	if(downloading)
		if(!silent)
			to_chat(downloading, span_userdanger("Download stopped."))
		downloading = null
		user_downloading = null
		download_progress = 0
		download_warning = FALSE


/datum/computer_file/program/ai_network_interface/proc/get_ai(get_card = FALSE)
	var/obj/item/computer_hardware/ai_slot/ai_slot

	if(computer)
		ai_slot = computer.all_components[MC_AI]

	if(computer && ai_slot && ai_slot.check_functionality())
		if(ai_slot.enabled && ai_slot.stored_card)
			if(get_card)
				return ai_slot.stored_card
			if(ai_slot.stored_card.AI)
				return ai_slot.stored_card.AI


