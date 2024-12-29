// TODO:
//	- Potentially roll HUDs and Records into one
//	- Shock collar/lock system for prisoner pAIs?
//  - Camera jack


/mob/living/silicon/pai/var/list/available_software = list(
															//Nightvision
															//T-Ray
															//radiation eyes
															//chem goggs
															list("module_name" = "crew manifest", "tab"=FALSE, "cost" = 5),
															list("module_name" = "digital messenger", "tab"=FALSE, "cost" = 5),
															list("module_name" = "atmosphere sensor", "tab"=TRUE, "title"="Atmospheric sensor", "cost" = 5),
															list("module_name" = "photography module", "tab"=FALSE, "cost" = 5),
															list("module_name" = "remote signaller", "tab"=TRUE, "title"="Remote signaller", "cost" = 10),
															list("module_name" = "medical records", "tab"=TRUE, "title"="Medical records", "cost" = 10),
															list("module_name" = "security records", "tab"=TRUE, "title"="Security records", "cost" = 10),
															list("module_name" = "camera zoom", "tab"=FALSE, "cost" = 10),
															list("module_name" = "host scan", "tab"=TRUE, "title"="Host Bioscan settings", "cost" = 10),
															//"camera jack" = 10,
															//"heartbeat sensor" = 10,
															//"projection array" = 15,
															list("module_name" = "medical HUD", "tab"=FALSE, "cost" = 20),
															list("module_name" = "meson HUD", "tab"=FALSE, "cost" = 20),
															list("module_name" = "nightvision HUD", "tab"=FALSE, "cost" = 20),
															list("module_name" = "security HUD", "tab"=FALSE, "cost" = 20),
															list("module_name" = "loudness booster", "tab"=TRUE, "title"="Sound Synthesizer", "cost" = 20),
															list("module_name" = "newscaster", "tab"=FALSE, "cost" = 20),
															list("module_name" = "door jack", "tab"=TRUE, "title"="Airlock Jack", "cost" = 25),
															list("module_name" = "encryption keys", "tab"=FALSE, "cost" = 25),
															list("module_name" = "universal translator", "tab"=FALSE, "cost" = 35)
															)

/mob/living/silicon/pai/var/list/module_tabs = list(list("module_name" = "directives", "title"="Directives"), 
													list("module_name" = "screen display", "title"="Screen Display"),
													list("module_name" = "download additional software", "title"="CentCom pAI Module Subversion Network"))

/mob/living/silicon/pai/var/datum/gas_mixture/environment
/mob/living/silicon/pai/var/pressure
/mob/living/silicon/pai/var/gases

/mob/living/silicon/pai/var/cable_status = "Retracted"

/mob/living/silicon/pai/var/list/med_record = list()
/mob/living/silicon/pai/var/list/sec_record = list()
/mob/living/silicon/pai/var/selected_med_record
/mob/living/silicon/pai/var/selected_sec_record

/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", "pAI Software Interface")
		ui.open()
		ui.set_autoupdate(TRUE)

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["modules"] = software
	data["modules_list"] = available_software
	data["modules_tabs"] = module_tabs
	data["laws_zeroth"] = laws.zeroth
	data["laws"] = laws.supplied
	data["master"] = master
	data["masterdna"] = master_dna
	data["ram"] = ram
	data["pressure"] = !isnull(environment) ? round(pressure,0.1) : pressure
	data["gases"] = gases
	data["temperature"] = !isnull(environment) ? round(environment.return_temperature()-T0C) : null
	data["hacking"] = hacking
	data["hackprogress"] = hackprogress
	data["cable"] = cable_status
	data["door"] = isnull(cable) ? null : cable.machine
	data["code"] = signaler.code
	data["frequency"] = signaler.frequency
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	data["color"] = signaler.label_color
	if(GLOB.data_core.general && GLOB.data_core.medical)
		med_record = list() //Important to reset it here so it doesn't readd records endlessly
		for(var/datum/data/record/M in sortRecord(GLOB.data_core.medical))
			for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
				if(R.fields["id"] == M.fields["id"])
					var/list/new_record = list("name" = R.fields["name"], "id" = R.fields["id"], "gender" = R.fields["gender"], "age" = R.fields["age"], "fingerprint" = R.fields["fingerprint"], "p_state" = R.fields["p_stat"], "m_state" = R.fields["m_stat"], "blood_type" = M.fields["blood_type"], "dna" = M.fields["b_dna"], "minor_disabilities" = M.fields["mi_dis"], "minor_disabilities_details" = M.fields["mi_dis_d"], "major_disabilities" = M.fields["ma_dis"], "major_disabilities_details" = M.fields["ma_dis_d"], "allergies" = M.fields["alg"], "allergies_details" = M.fields["alg_d"], "current_diseases" = M.fields["cdi"], "current_diseases_details" = M.fields["cdi_d"], "important_notes" = M.fields["notes"])
					med_record += list(new_record)
					break
	if(GLOB.data_core.general && GLOB.data_core.security)
		sec_record = list()
		for(var/datum/data/record/S in sortRecord(GLOB.data_core.security))
			for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
				if(R.fields["id"] == S.fields["id"])
					var/list/crimes = list()
					for(var/datum/data/crime/crime in S.fields["crimes"])
						crime = list("crime_name" = crime.crimeName, "crime_details" = crime.crimeDetails, "author" = crime.author, "time_added" = crime.time)
						crimes += list(crime)
					var/list/comments = list()
					for(var/datum/data/comment/comment in S.fields["comments"])
						comment = list("comment_text" = comment.commentText, "author" = comment.author, "time" = comment.time)
						comments += list(comment)
					var/list/new_record = list("name" = R.fields["name"], "id" = R.fields["id"], "gender" = R.fields["gender"], "age" = R.fields["age"], "rank" = R.fields["rank"], "fingerprint" = R.fields["fingerprint"], "p_state" = R.fields["p_stat"], "m_state" = R.fields["m_stat"], "criminal_status" = S.fields["criminal"], "crimes" = crimes, "important_notes" = S.fields["notes"], "comments" = comments)
					sec_record += list(new_record)
					break
	data["med_records"] = med_record
	data["sec_records"] = sec_record
	data["selected_med_record"] = selected_med_record
	data["selected_sec_record"] = selected_sec_record
	return data

/mob/living/silicon/pai/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("getdna")
			if(iscarbon(get(card, /mob/living/carbon/human))) //No way to test if get() works since UI buttons doesn't work currently if in card form
				CheckDNA(get(card, /mob/living/carbon/human), src) //you should only be able to check when directly in hand, muh immersions?
			else
				to_chat(src, "You are not being carried by anyone!")
		if("update_image")
			card.setEmotion(params["updated_image"])
		if("buy")
			if(!software.Find(params["name"]))
				if((ram-params["cost"])<0)
					to_chat(usr, span_warning("Insufficient RAM available."))
					return
				software.Add(params["name"])
				ram -= params["cost"]
				if(params["name"] == "digital messenger")
					create_modularInterface()
				if(params["name"] == "medical HUD")
					var/datum/atom_hud/med = GLOB.huds[med_hud]
					med.show_to(src)
				if(params["name"] == "meson HUD")
					sight |= SEE_TURFS
				if(params["name"] == "nightvision HUD")
					lighting_cutoff = LIGHTING_CUTOFF_HIGH
				if(params["name"] == "security HUD")
					var/datum/atom_hud/sec = GLOB.huds[sec_hud]
					sec.show_to(src)
				if(params["name"] == "encryption keys")
					encryptmod = TRUE
				if(params["name"] == "universal translator")
					grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
				var/datum/hud/pai/pAIhud = hud_used
				pAIhud?.update_software_buttons()
				var/list = list()
				for(list in available_software)
					if(list["tab"] && list["module_name"] == params["name"]) //Find if this is meant to be a tab or not
						var/new_module = list("module_name" = params["name"], "title"=list["title"])
						module_tabs += list(new_module)
						available_software.Remove(list(list)) //Removes from downloadable software list so they can't be redownloaded
						break
					else if(list["module_name"] == params["name"]) //If it's not a tab but it is our bought module, remove it from the list
						available_software.Remove(list(list))
						break
			else //Should not be possible, but in the edge case that it does...
				to_chat(usr, span_warning("Module already downloaded!"))
		if("atmossensor")
			var/turf/T = get_turf(loc)
			if (isnull(T))
				to_chat(usr, span_warning("Unable to obtain a reading."))
			else
				environment = T.return_air()
				pressure = environment.return_pressure()
				var/total_moles = environment.total_moles()

				if (total_moles)
					for(var/id in environment.get_gases())
						var/gas_level = environment.get_moles(id)/total_moles
						gases = list()
						if(gas_level > 0.01)
							gases += "[GLOB.gas_data.labels[id]]: [round(gas_level*100)]%"
						else
							gases = list()
		if("signallersignal")
			if(TIMER_COOLDOWN_CHECK(signaler, COOLDOWN_SIGNALLER_SEND))
				to_chat(usr, span_warning("[signaler] is still recharging..."))
				return
			TIMER_COOLDOWN_START(signaler, COOLDOWN_SIGNALLER_SEND, 1 SECONDS)
			signaler.signal()
			audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*")
			playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
		if("signallerfreq")
			signaler.frequency = unformat_frequency(params["freq"])
			signaler.frequency = sanitize_frequency(signaler.frequency, TRUE)
			signaler.set_frequency(signaler.frequency)
			. = TRUE
		if("signallercode")
			signaler.code = text2num(params["code"])
			signaler.code = round(signaler.code)
			. = TRUE
		if("signallerreset")
			if(params["reset"] == "freq")
				signaler.frequency = initial(signaler.frequency)
			else
				signaler.code = initial(signaler.code)
			. = TRUE
		if("signallercolor")
			var/idx = signaler.label_colors.Find(signaler.label_color)
			if(idx == signaler.label_colors.len || idx == 0)
				idx = 1
			else
				idx++
			signaler.label_color = signaler.label_colors[idx]
		if("hostscan")
			var/mob/living/silicon/pai/pAI = usr
			pAI.hostscan.attack_self(src)
		if("loudness")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.interact(src)
		if("cable")
			if(cable_status == "Extended")
				return
			var/turf/T = get_turf(loc)
			cable = new /obj/item/pai_cable(T)
			if(get(card, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = get(card, /mob/living/carbon/human)
				H.put_in_hands(cable)
			T.visible_message(span_warning("A port on [src] opens to reveal [cable], which promptly falls to the floor."), span_italics("You hear the soft click of something light and hard falling to the ground."))
			cable_status = "Extended"
		if("jack")
			if(cable && cable.machine)
				hackdoor = cable.machine
				hackloop()
		if("cancel")
			hackdoor = null
		if("retract")
			var/turf/T = get_turf(src.loc)
			T.visible_message(span_warning("[src.cable] rapidly retracts back into its spool."), span_italics("You hear a click and the sound of wire spooling rapidly."))
			qdel(cable)
			hackdoor = null
			cable = null
			cable_status = "Retracted"
		if("med_record")
			if(!GLOB.data_core.general||!GLOB.data_core.medical)
				return
			for(var/datum/data/record/M in sortRecord(GLOB.data_core.medical))
				var/done = FALSE
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
					if(M.fields["id"] == params["record"])
						selected_med_record = list("name" = R.fields["name"], "id" = R.fields["id"], "gender" = R.fields["gender"], "age" = R.fields["age"], "fingerprint" = R.fields["fingerprint"], "p_state" = R.fields["p_stat"], "m_state" = R.fields["m_stat"], "blood_type" = M.fields["blood_type"], "dna" = M.fields["b_dna"], "minor_disabilities" = M.fields["mi_dis"], "minor_disabilities_details" = M.fields["mi_dis_d"], "major_disabilities" = M.fields["ma_dis"], "major_disabilities_details" = M.fields["ma_dis_d"], "allergies" = M.fields["alg"], "allergies_details" = M.fields["alg_d"], "current_diseases" = M.fields["cdi"], "current_diseases_details" = M.fields["cdi_d"], "important_notes" = M.fields["notes"])
						done = TRUE
						break
				if(done)
					break
		if("med_record back")
			selected_med_record = null
		if("sec_record")
			if(!GLOB.data_core.general||!GLOB.data_core.medical)
				return
			for(var/datum/data/record/S in sortRecord(GLOB.data_core.security))
				var/done = FALSE
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
					if(S.fields["id"] == params["record"])
						var/list/crimes = list()
						for(var/datum/data/crime/crime in S.fields["crimes"])
							crime = list("crime_name" = crime.crimeName, "crime_details" = crime.crimeDetails, "author" = crime.author, "time_added" = crime.time)
							crimes += list(crime)
						var/list/comments = list()
						for(var/datum/data/comment/comment in S.fields["comments"])
							comment = list("comment_text" = comment.commentText, "author" = comment.author, "time" = comment.time)
							comments += list(comment)
						selected_sec_record = list("name" = R.fields["name"], "id" = R.fields["id"], "gender" = R.fields["gender"], "age" = R.fields["age"], "rank" = R.fields["rank"], "fingerprint" = R.fields["fingerprint"], "p_state" = R.fields["p_stat"], "m_state" = R.fields["m_stat"], "criminal_status" = S.fields["criminal"], "crimes" = crimes, "important_notes" = S.fields["notes"], "comments" = comments)
						done = TRUE
						break
				if(done)
					break
		if("sec_record back")
			selected_sec_record = null
	update_appearance(UPDATE_ICON)

/mob/living/silicon/pai/ui_state(mob/user)
	if(user == src)
		return GLOB.always_state
	..()

/mob/living/silicon/pai/proc/CheckDNA(mob/living/carbon/M, mob/living/silicon/pai/P)
	if(!istype(M))
		return
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		M.visible_message(span_notice("[M] presses [M.p_their()] thumb against [P]."),\
						span_notice("You press your thumb against [P]."),\
						span_notice("[P] makes a sharp clicking sound as it extracts DNA material from [M]."))
		if(!M.has_dna())
			to_chat(P, "<b>No DNA detected</b>")
			return
		to_chat(P, "<font color = red><h3>[M]'s UE string : [M.dna.unique_enzymes]</h3></font>")
		if(M.dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, "[M] does not seem like [M.p_theyre()] going to provide a DNA sample willingly.")

//// Camera Jack - Clearly not finished
///mob/living/silicon/pai/proc/softwareCamera()
//	var/dat = "<h3>Camera Jack</h3>"
//	dat += "Cable status : "
//
//	if(!cable)
//		dat += "<font color=#FF5555>Retracted</font> <br>"
//		return dat
//	if(!cable.machine)
//		dat += "<font color=#FFFF55>Extended</font> <br>"
//		return dat
//
//	var/obj/machinery/machine = cable.machine
//	dat += "<font color=#55FF55>Connected</font> <br>"
//
//	if(!istype(machine, /obj/machinery/camera))
//		to_chat(src, "DERP")
//	return dat
//


// Door Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/turf/T = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, span_userdanger("Network Alert: Brute-force encryption crack in progress in [T.loc]."))
		else
			to_chat(AI, span_userdanger("Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location."))
	hacking = TRUE
