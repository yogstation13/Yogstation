#define SECURITY "sec"
#define MEDICAL "med"
#define ENGINEERING "eng"
#define SCIENCE "sci"
#define SUPPLY "sup"

GLOBAL_LIST_INIT(granted_synthetic_access, list())

/datum/computer_file/program/synth_requester
	filename = "synth_req"
	filedesc = "Synthetic Manager"
	category = PROGRAM_CATEGORY_CMD
	program_icon_state = "id"
	extended_desc = "Program for requesting synthetic assistance and granting departmental access."
	transfer_access = ACCESS_HEADS
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET | PROGRAM_PHONE | PROGRAM_PDA
	size = 4
	tgui_id = "NtosSynthManager"
	program_icon = "address-book"

/datum/computer_file/program/synth_requester/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = usr
	var/obj/item/card/id/user_id = user.get_idcard()
	computer.play_interact_sound()
	if(user_id)
		if(!(ACCESS_HEADS in user_id.access))
			return


	switch(action)
		if("grant_science")
			if(ACCESS_RD in user_id.access)
				var/relevant_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_ROBO_CONTROL, ACCESS_TELEPORTER, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_ROBOTICS)
				if(GLOB.granted_synthetic_access[SCIENCE])
					GLOB.granted_synthetic_access[SCIENCE] = FALSE
					binary_talk("Synthetic assistance no longer required in the Science department", "Synthetic Access Requester")
					GLOB.synthetic_added_access -= relevant_access
				else
					var/reason = tgui_input_text(user, "Please provide a reason for requesting synthetic assistance.", "Assistance Request")
					if(!reason)
						return FALSE
					binary_talk("Synthetic assistance required in the Science department for the following reason: [reason]", "Synthetic Access Requester")
					GLOB.granted_synthetic_access[SCIENCE] = TRUE
					GLOB.synthetic_added_access |= relevant_access

			return TRUE
		if("grant_supply")
			if(ACCESS_HOP in user_id.access)
				var/relevant_access = list(ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MAILSORTING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
				if(GLOB.granted_synthetic_access[SUPPLY])
					GLOB.granted_synthetic_access[SUPPLY] = FALSE
					binary_talk("Synthetic assistance no longer required in the Supply department", "Synthetic Access Requester")
					GLOB.synthetic_added_access -= relevant_access
				else
					var/reason = tgui_input_text(user, "Please provide a reason for requesting synthetic assistance.", "Assistance Request")
					if(!reason)
						return FALSE
					binary_talk("Synthetic assistance required in the Supply department for the following reason: [reason]", "Synthetic Access Requester")
					GLOB.granted_synthetic_access[SUPPLY] = TRUE
					GLOB.synthetic_added_access |= relevant_access


			return TRUE
		if("grant_engi")
			if(ACCESS_CE in user_id.access)
				var/relevant_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_CONSTRUCTION, ACCESS_SECURE_TECH_STORAGE)
				if(GLOB.granted_synthetic_access[ENGINEERING])
					GLOB.granted_synthetic_access[ENGINEERING] = FALSE
					binary_talk("Synthetic assistance no longer required in the Engineering department", "Synthetic Access Requester")
					GLOB.synthetic_added_access -= relevant_access
				else
					var/reason = tgui_input_text(user, "Please provide a reason for requesting synthetic assistance.", "Assistance Request")
					if(!reason)
						return FALSE
					binary_talk("Synthetic assistance required in the Engineering department for the following reason: [reason]", "Synthetic Access Requester")
					GLOB.granted_synthetic_access[ENGINEERING] = TRUE
					GLOB.synthetic_added_access |= relevant_access
			
			return TRUE
		if("grant_security")
			if(ACCESS_HOS in user_id.access)
				var/relevant_access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_BRIG_PHYS)
				if(GLOB.granted_synthetic_access[SECURITY])
					GLOB.granted_synthetic_access[SECURITY] = FALSE
					binary_talk("Synthetic assistance no longer required in the Security department", "Synthetic Access Requester")
					GLOB.synthetic_added_access -= relevant_access
				else
					var/reason = tgui_input_text(user, "Please provide a reason for requesting synthetic assistance.", "Assistance Request")
					if(!reason)
						return FALSE
					binary_talk("Synthetic assistance required in the Security department for the following reason: [reason]", "Synthetic Access Requester")
					GLOB.granted_synthetic_access[SECURITY] = TRUE
					GLOB.synthetic_added_access |= relevant_access
			
			return TRUE
		if("grant_medical")
			if(ACCESS_CMO in user_id.access)
				var/relevant_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_PARAMEDIC, ACCESS_PSYCH)
				if(GLOB.granted_synthetic_access[MEDICAL])
					GLOB.granted_synthetic_access[MEDICAL] = FALSE
					binary_talk("Synthetic assistance no longer required in the Medical department", "Synthetic Access Requester")
					GLOB.synthetic_added_access -= relevant_access
				else
					var/reason = tgui_input_text(user, "Please provide a reason for requesting synthetic assistance.", "Assistance Request")
					if(!reason)
						return FALSE
					binary_talk("Synthetic assistance required in the Medical department for the following reason: [reason]", "Synthetic Access Requester")
					GLOB.granted_synthetic_access[MEDICAL] = TRUE
					GLOB.synthetic_added_access |= relevant_access
			return TRUE


/datum/computer_file/program/synth_requester/ui_data(mob/user)
	var/list/data = get_header_data()

	data["granted_access"] = list(GLOB.granted_synthetic_access)

	var/obj/item/card/id/user_id = user.get_idcard()

	if(ACCESS_CMO in user_id.access)
		data["cmo"] = TRUE
	if(ACCESS_HOS in user_id.access)
		data["hos"] = TRUE
	if(ACCESS_RD in user_id.access)
		data["rd"] = TRUE
	if(ACCESS_HOP in user_id.access)
		data["hop"] = TRUE
	if(ACCESS_CE in user_id.access)
		data["ce"] = TRUE

	return data

/proc/binary_talk(message,name, loud = TRUE)

	var/spans = "[SPAN_ROBOT]"


	if(loud)
		// AIs are loud and ugly
		spans += " [SPAN_COMMAND]"

	var/quoted_message = "states, <span class='[spans]'>\"[message]\"</span>"

	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			to_chat(
				M,
				span_binarysay("\
					Robotic Talk, \
					[span_name("[name]")] [span_message("[quoted_message]")]\
				")
			)

		if(isobserver(M))
			// If the AI talks on binary chat, we still want to follow
			// its camera eye, like if it talked on the radio

			to_chat(
				M,
				span_binarysay("\
					Robotic Talk, \
					[span_name("[name]")] [span_message("[quoted_message]")]\
				")
			)

#undef SECURITY 
#undef MEDICAL 
#undef ENGINEERING 
#undef SCIENCE 
#undef SUPPLY 
