// TODO:
//	- Potentially roll HUDs and Records into one
//	- Shock collar/lock system for prisoner pAIs?
//  - Camera jack


/mob/living/silicon/pai/var/list/available_software = list(
															//Nightvision
															//T-Ray
															//radiation eyes
															//chem goggs
															//mesons
															list("module_name" = "crew manifest", "tab"=FALSE, "cost" = 5),
															list("module_name" = "digital messenger", "tab"=FALSE, "cost" = 5),
															list("module_name" = "atmosphere sensor", "tab"=TRUE, "title"="Atmospheric sensor", "cost" = 5),
															list("module_name" = "photography module", "tab"=FALSE, "cost" = 5),
															list("module_name" = "remote signaller", "tab"=TRUE, "title"="Remote signaller", "cost" = 10),
															//list("module_name" = "medical records", "tab"=TRUE, "title"="Medical records", "cost" = 10),
															//list("module_name" = "security records", "tab"=TRUE, "title"="Security records", "cost" = 10),
															list("module_name" = "camera zoom", "tab"=FALSE, "cost" = 10),
															list("module_name" = "host scan", "tab"=TRUE, "title"="Host Bioscan settings", "cost" = 10),
															//"camera jack" = 10,
															//"heartbeat sensor" = 10,
															//"projection array" = 15,
															list("module_name" = "medical HUD", "tab"=FALSE, "cost" = 20),
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
	if(!isnull(environment))
		data["pressure"] = round(pressure,0.1)
		data["gases"] = gases
		data["temperature"] = round(environment.return_temperature()-T0C)
	else
		data["pressure"] = pressure
		data["gases"] = gases
		data["temperature"] = null
	data["hacking"] = hacking
	data["hackprogress"] = hackprogress
	data["cable"] = cable_status
	if(isnull(cable))
		data["door"] = null
	else
		data["door"] = cable.machine
	data["code"] = signaler.code
	data["frequency"] = signaler.frequency
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	data["color"] = signaler.label_color
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
				return 0 // FALSE ? If you return here you won't call paiinterface() below
		if("update_image")
			card.setEmotion(params["updated_image"])
		if("buy")
			if(!software.Find(params["name"]))
				if((ram-params["cost"])<0)
					to_chat(usr, span_warning("Insufficient RAM available."))
					return
				software.Add(params["name"])
				ram -= params["cost"]
				if(params["name"] == "medical HUD")
					var/datum/atom_hud/med = GLOB.huds[med_hud]
					med.show_to(src)
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

//Leaving the medical & security records stuff commented out till they can be added back
//
//// Medical Records
///mob/living/silicon/pai/proc/softwareMedicalRecord()
//	switch(subscreen)
//		if(0)
//			. += "<h3>Medical Records</h3><HR>"
//			if(GLOB.data_core.general)
//				for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
//					. += "<A href='?src=[REF(src)];med_rec=[R.fields["id"]];software=medicalrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
//		if(1)
//			. += "<CENTER><B>Medical Record</B></CENTER><BR>"
//			if(medicalActive1 in GLOB.data_core.general)
//				. += "Name: [medicalActive1.fields["name"]] ID: [medicalActive1.fields["id"]]<BR>\nGender: [medicalActive1.fields["gender"]]<BR>\nAge: [medicalActive1.fields["age"]]<BR>\nFingerprint: [medicalActive1.fields["fingerprint"]]<BR>\nPhysical Status: [medicalActive1.fields["p_stat"]]<BR>\nMental Status: [medicalActive1.fields["m_stat"]]<BR>"
//			else
//				. += "<pre>Requested medical record not found.</pre><BR>"
//			if(medicalActive2 in GLOB.data_core.medical)
//				. += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=[REF(src)];field=blood_type'>[medicalActive2.fields["blood_type"]]</A><BR>\nDNA: <A href='?src=[REF(src)];field=b_dna'>[medicalActive2.fields["b_dna"]]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=[REF(src)];field=mi_dis'>[medicalActive2.fields["mi_dis"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=mi_dis_d'>[medicalActive2.fields["mi_dis_d"]]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=[REF(src)];field=ma_dis'>[medicalActive2.fields["ma_dis"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=ma_dis_d'>[medicalActive2.fields["ma_dis_d"]]</A><BR>\n<BR>\nAllergies: <A href='?src=[REF(src)];field=alg'>[medicalActive2.fields["alg"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=alg_d'>[medicalActive2.fields["alg_d"]]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=[REF(src)];field=cdi'>[medicalActive2.fields["cdi"]]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=[REF(src)];field=cdi_d'>[medicalActive2.fields["cdi_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=[REF(src)];field=notes'>[medicalActive2.fields["notes"]]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
//			else
//				. += "<pre>Requested medical record not found.</pre><BR>"
//			. += "<BR>\n<A href='?src=[REF(src)];software=medicalrecord;sub=0'>Back</A><BR>"
//	return .
//
//// Security Records
///mob/living/silicon/pai/proc/softwareSecurityRecord()
//	. = ""
//	switch(subscreen)
//		if(0)
//			. += "<h3>Security Records</h3><HR>"
//			if(GLOB.data_core.general)
//				for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
//					. += "<A href='?src=[REF(src)];sec_rec=[R.fields["id"]];software=securityrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
//		if(1)
//			. += "<h3>Security Record</h3>"
//			if(securityActive1 in GLOB.data_core.general)
//				. += "Name: <A href='?src=[REF(src)];field=name'>[securityActive1.fields["name"]]</A> ID: <A href='?src=[REF(src)];field=id'>[securityActive1.fields["id"]]</A><BR>\nGender: <A href='?src=[REF(src)];field=gender'>[securityActive1.fields["gender"]]</A><BR>\nAge: <A href='?src=[REF(src)];field=age'>[securityActive1.fields["age"]]</A><BR>\nRank: <A href='?src=[REF(src)];field=rank'>[securityActive1.fields["rank"]]</A><BR>\nFingerprint: <A href='?src=[REF(src)];field=fingerprint'>[securityActive1.fields["fingerprint"]]</A><BR>\nPhysical Status: [securityActive1.fields["p_stat"]]<BR>\nMental Status: [securityActive1.fields["m_stat"]]<BR>"
//			else
//				. += "<pre>Requested security record not found,</pre><BR>"
//			if(securityActive2 in GLOB.data_core.security)
//				. += "<BR>"
//				. += "Security Data<BR>"
//				. += "Criminal Status: [securityActive2.fields["criminal"]]<BR><BR>"
//				. += "Crimes:<BR>"
//				for(var/datum/data/crime/crime in securityActive2.fields["crimes"])
//					. += "\t[crime.crimeName]: [crime.crimeDetails]<BR>"
//				. += "<BR>"
//				. += "Important Notes:<BR>"
//				. += "\t[securityActive2.fields["notes"]]<BR><BR>"
//				. += "<CENTER><B>Comments/Log</B></CENTER><BR>"
//				for(var/datum/data/comment/comment in securityActive2.fields["comments"])
//					. += "\t[comment.commentText] - [comment.author] [comment.time]<BR>"
//			else
//				. += "<pre>Requested security record not found,</pre><BR>"
//			. += "<BR>\n<A href='?src=[REF(src)];software=securityrecord;sub=0'>Back</A><BR>"
//	return .
//
//
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
