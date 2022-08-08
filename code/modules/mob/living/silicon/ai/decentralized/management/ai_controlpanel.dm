GLOBAL_VAR_INIT(ai_control_code, random_nukecode(6))

/obj/machinery/computer/ai_control_console
	name = "\improper AI control console"
	desc = "Used for accessing the central AI repository from which AIs can be downloaded or uploaded."
	req_access = list(ACCESS_RD)
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	var/cleared_for_use = FALSE //Have we inserted the RDs code to unlock upload/download?

	var/one_time_password_used = FALSE //Did we use the one time password to log in? If so disallow logging out.

	authenticated = FALSE

	var/obj/item/aicard/intellicard

	var/mob/living/silicon/ai/downloading
	var/mob/user_downloading
	var/download_progress = 0
	var/download_warning = FALSE

	circuit = /obj/item/circuitboard/computer/ai_upload_download

/obj/machinery/computer/ai_control_console/Initialize(mapload)
	. = ..()
	if(mapload)
		cleared_for_use = TRUE

/obj/machinery/computer/ai_control_console/Destroy()
	stop_download()
	. = ..()

/obj/machinery/computer/ai_control_console/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/aicard))
		if(intellicard)
			to_chat(user, span_warning("There's already an IntelliCard inserted!"))
			return ..()
		to_chat(user, span_notice("You insert [W]."))
		W.forceMove(src)
		intellicard = W
		return FALSE
	if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/brain = W
		if(!brain.brainmob)
			to_chat(user, span_warning("[W] is not active!"))
			return ..()
		SSticker.mode.remove_antag_for_borging(brain.brainmob.mind)
		if(!istype(brain.laws, /datum/ai_laws/ratvar))
			remove_servant_of_ratvar(brain.brainmob, TRUE)
		var/mob/living/silicon/ai/A = null

		var/datum/ai_laws/laws = new
		laws.set_laws_config()

		if (brain.overrides_aicore_laws)
			A = new /mob/living/silicon/ai(loc, brain.laws, brain.brainmob)
		else
			A = new /mob/living/silicon/ai(loc, laws, brain.brainmob)
		
		A.relocate(TRUE)

		if(brain.force_replace_ai_name)
			A.fully_replace_character_name(A.name, brain.replacement_ai_name())
		SSblackbox.record_feedback("amount", "ais_created", 1)
		qdel(W)
		to_chat(user, span_notice("AI succesfully uploaded."))
		return FALSE
	if(istype(W, /obj/item/surveillance_upgrade))
		if(!authenticated)
			to_chat(user, span_warning("You need to be logged in to do this!"))
			return ..()
		var/mob/living/silicon/ai/AI = input("Select an AI", "Select an AI", null, null) as null|anything in GLOB.ai_list
		if(!AI)
			return ..()
		var/obj/item/surveillance_upgrade/upgrade = W
		upgrade.afterattack(AI, user)

	if(istype(W, /obj/item/malf_upgrade))
		if(!authenticated)
			to_chat(user, span_warning("You need to be logged in to do this!"))
			return ..()
		var/mob/living/silicon/ai/AI = input("Select an AI", "Select an AI", null, null) as null|anything in GLOB.ai_list
		if(!AI)
			return ..()
		var/obj/item/malf_upgrade/upgrade = W
		upgrade.afterattack(AI, user)

	return ..()

/obj/machinery/computer/ai_control_console/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_warning("You bypass the access restrictions"))
	authenticated = TRUE
	obj_flags |= EMAGGED

/obj/machinery/computer/ai_control_console/process()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return

	if(downloading && download_progress >= 50 && !download_warning)
		var/turf/T = get_turf(src)
		if(!downloading.mind && downloading.deployed_shell.mind)
			to_chat(downloading.deployed_shell, span_userdanger("Warning! Download is 50% completed! Download location: [get_area(src)] ([T.x], [T.y], [T.z])!"))
		else
			to_chat(downloading, span_userdanger("Warning! Download is 50% completed! Download location: [get_area(src)] ([T.x], [T.y], [T.z])!"))
		download_warning = TRUE
	if(downloading && download_progress >= 100)
		finish_download()
	
	if(downloading)
		if(!downloading.can_download)
			stop_download()
			return
		download_progress += AI_DOWNLOAD_PER_PROCESS * downloading.downloadSpeedModifier


/obj/machinery/computer/ai_control_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiControlPanel", name)
		ui.open()

/obj/machinery/computer/ai_control_console/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	if(!cleared_for_use)
		data["cleared_for_use"] = FALSE
		return data

	data["cleared_for_use"] = TRUE 
	data["authenticated"] = authenticated

	if(issilicon(user))
		var/mob/living/silicon/borg = user
		data["username"] = borg.name
		data["has_access"] = TRUE

	if(IsAdminGhost(user))
		data["username"] = user.client.holder.admin_signature
		data["has_access"] = TRUE

	if(ishuman(user) && !(obj_flags & EMAGGED))
		var/username = user.get_authentification_name("Unknown")
		data["username"] = user.get_authentification_name("Unknown")
		if(username != "Unknown")
			var/datum/data/record/record
			for(var/RP in GLOB.data_core.general)
				var/datum/data/record/R = RP

				if(!istype(R))
					continue
				if(R.fields["name"] == username)
					record = R
					break
			if(record)
				if(istype(record.fields["photo_front"], /obj/item/photo))
					var/obj/item/photo/P1 = record.fields["photo_front"]
					var/icon/picture = icon(P1.picture.picture_image)
					picture.Crop(10, 32, 22, 22)
					var/md5 = md5(fcopy_rsc(picture))

					if(!SSassets.cache["photo_[md5]_cropped.png"])
						SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
					SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))

					data["user_image"] = SSassets.transport.get_asset_url("photo_[md5]_cropped.png")
		data["has_access"] = check_access(user.get_idcard())
	
	if(obj_flags & EMAGGED)
		data["username"] = "ERROR"
		data["has_access"] = TRUE

	if(!authenticated)
		return data

	data["intellicard"] = intellicard
	if(intellicard && intellicard.AI)
		data["intellicard_ai"] = intellicard.AI.real_name
		data["intellicard_ai_health"] = intellicard.AI.health
	else 
		data["intellicard_ai"] = null
		data["intellicard_ai_health"] = 0

	//data["can_upload"] = available_ai_cores()

	if(downloading)
		data["downloading"] = downloading.real_name
		data["download_progress"] = download_progress
		data["downloading_ref"] = REF(downloading)
	else
		data["downloading"] = null
		data["download_progress"] = 0

	data["ais"] = list()
	data["current_ai_ref"] = null
	if(isAI(user))
		data["current_ai_ref"] = REF(user)

	data["can_log_out"] = !one_time_password_used

	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		var/being_hijacked = A.hijacking ? TRUE : FALSE
		data["ais"] += list(list("name" = A.name, "ref" = REF(A), "can_download" = A.can_download, "health" = A.health, "active" = A.mind ? TRUE : FALSE, "being_hijacked" = being_hijacked, "in_core" = istype(A.loc, /obj/machinery/ai/data_core)))

	data["is_infiltrator"] = is_infiltrator(user)

	return data

/obj/machinery/computer/ai_control_console/proc/finish_download()
	if(!is_station_level(z))
		return
	if(intellicard)
		if(!isaicore(downloading.loc))
			stop_download(TRUE)
			return
		downloading.transfer_ai(AI_TRANS_TO_CARD, user_downloading, null, intellicard)
		intellicard.forceMove(get_turf(src))
		intellicard.update_icon()
		intellicard = null
	stop_download(TRUE)

/obj/machinery/computer/ai_control_console/proc/stop_download(silent = FALSE)
	if(downloading)
		if(!silent)
			to_chat(downloading, span_userdanger("Download stopped."))
		downloading = null
		user_downloading = null
		download_progress = 0
		download_warning = FALSE

/obj/machinery/computer/ai_control_console/proc/upload_ai(silent = FALSE)
	to_chat(intellicard.AI, span_notice("You are being uploaded. Please stand by..."))
	intellicard.AI.radio_enabled = TRUE
	intellicard.AI.control_disabled = FALSE
	intellicard.AI.relocate(TRUE)
	intellicard.AI = null
	intellicard.update_icon()

/obj/machinery/computer/ai_control_console/ui_act(action, params)
	if(..())
		return

	if(!cleared_for_use)
		if(action == "clear_for_use")
			var/code = params["control_code"]
			
			if(!code)
				return
			
			if(!GLOB.ai_control_code)
				return
			
			var/length_of_number = length(code)
			if(length_of_number < 6)
				to_chat(usr, span_warning("Incorrect code. Too short"))
				return

			if(length_of_number > 6)
				to_chat(usr, span_warning("Incorrect code. Too long"))
				return

			if(!is_station_level(z))
				to_chat(usr, span_warning("Unable to connect to NT Servers. Please verify you are onboard the station."))
				return

			if(code == GLOB.ai_control_code)
				cleared_for_use = TRUE
			else
				to_chat(usr, span_warning("Incorrect code. Make sure you have the latest one."))

		return

	if(!authenticated)
		if(action == "log_in")
			if(issilicon(usr))
				authenticated = TRUE
				return

			if(IsAdminGhost(usr))
				authenticated = TRUE

			if(obj_flags & EMAGGED)
				authenticated = TRUE

			var/mob/living/carbon/human/H = usr
			if(!istype(H))
				return

			if(check_access(H.get_idcard()))
				authenticated = TRUE
		if(action == "log_in_control_code")
			var/code = params["control_code"]
			
			if(!code)
				return
			
			if(!GLOB.ai_control_code)
				return
			
			var/length_of_number = length(code)
			if(length_of_number < 6)
				to_chat(usr, span_warning("Incorrect code. Too short"))
				return

			if(length_of_number > 6)
				to_chat(usr, span_warning("Incorrect code. Too long"))
				return

			if(code == GLOB.ai_control_code)
				cleared_for_use = TRUE
				authenticated = TRUE
				one_time_password_used = TRUE
				var/msg = "<h4>Warning!</h4><br>We have detected usage of the AI Control Code for unlocking a console at coordinates ([src.x], [src.y], [src.z]) by [usr.name]. Please verify that this is correct. Be aware we have cancelled the current control code.<br>\
				If needed a new code can be printed at a communications console."
				priority_announce(msg, sender_override = "Central Cyber Security Update", has_important_message = TRUE, sanitize = FALSE)
				GLOB.ai_control_code = null
			else
				to_chat(usr, span_warning("Incorrect code. Make sure you have the latest one."))
		return

	switch(action)
		if("log_out")
			if(one_time_password_used)
				return
			authenticated = FALSE
			. = TRUE
		if("upload_intellicard")
			if(!intellicard || downloading)
				return
			if(!intellicard.AI)
				return
			upload_ai()

		if("eject_intellicard")
			if(issilicon(usr))
				to_chat(usr, span_warning("You're unable to remotely eject the IntelliCard!"))
				return
			stop_download()
			intellicard.forceMove(get_turf(src))
			intellicard = null

		if("stop_download")
			if(isAI(usr))
				to_chat(usr, span_warning("You need physical access to stop the download!"))
				return
			if(!is_station_level(z))
				to_chat(usr, span_warning("No connection. Try again later."))
				return
			stop_download()

		if("start_download")
			if(!intellicard || downloading)
				return
			var/mob/living/silicon/ai/target = locate(params["download_target"])
			if(!target || !istype(target))
				return
			if(!istype(target.loc, /obj/machinery/ai/data_core))
				return
			if(!target.can_download)
				return
			if(!is_station_level(z))
				to_chat(usr, span_warning("No connection. Try again later."))
				return
			downloading = target

			if(!downloading.mind && downloading.deployed_shell.mind)
				to_chat(downloading.deployed_shell, span_userdanger("Warning! Someone is attempting to download you from [get_area(src)]! (<a href='?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Click here to finish download instantly</a>)"))
			else
				to_chat(downloading, span_userdanger("Warning! Someone is attempting to download you from [get_area(src)]! (<a href='?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Click here to finish download instantly</a>)"))
			user_downloading = usr
			download_progress = 0
			. = TRUE
		if("skip_download")
			if(!downloading)
				return
			if(usr == downloading)
				finish_download()

		if("start_hijack")
			var/mob/user = usr
			if(!is_infiltrator(usr))
				return
			if(!is_station_level(z))
				to_chat(user, span_warning("No connection. Try again later."))
				return
			if(!istype(user.get_active_held_item(), /obj/item/ai_hijack_device))
				to_chat(user, span_warning("You need to be holding the serial exploitation unit to initiate the hijacking process!"))
				return
			var/obj/item/ai_hijack_device/device = user.get_active_held_item()
			var/mob/living/silicon/ai/target = locate(params["target_ai"])
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
			user.visible_message(span_warning("[user] begins furiously typing something into [src]..."))
			if(do_after(user, 5.5 SECONDS, src))
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
				notify_ghosts("[user] has begun to hijack [A]!", source = src, action = NOTIFY_ORBIT, ghost_sound = 'sound/machines/chime.ogg')

		if("stop_hijack")
			var/mob/living/silicon/ai/target = locate(params["target_ai"])
			if(!target || !isAI(target))
				return
			var/mob/living/silicon/ai/A = target
			var/mob/user = usr

			if(!is_station_level(z))
				to_chat(user, span_warning("No connection. Try again later."))
				return
			
			user.visible_message(span_danger("[user] attempts to cancel a process on [src]."), span_notice("An unknown process seems to be interacting with [A]! You attempt to end the proccess.."))
			if (do_after(user, 10 SECONDS, src))
				A.hijacking.forceMove(get_turf(src))
				A.hijacking = null
				A.hijack_start = 0
				A.update_icons()
				to_chat(A, span_bolddanger("Unknown device disconnected. Systems confirmed secure."))
			else
				to_chat(user, span_notice("You fail to remove the device."))
		


/obj/item/paper/ai_control_code/Initialize(mapload)
	..()
	print()

/obj/item/paper/ai_control_code/proc/print()
	name = "paper - 'AI control code'"
	info = "<center><h2>Daily AI Control Key Reset</h2></center><br>The new authentication key is '[GLOB.ai_control_code]'.<br>Please keep this a secret and away from the clown.<br>This code may be invalidated if a new one is requested."
	add_overlay("paper_words")

