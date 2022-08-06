/datum/admins/proc/Secrets()
	if(!check_rights(0))
		return
	new /datum/tgui_secrets_panel(usr)
	return

/datum/tgui_secrets_panel
	var/client/holder //client of whoever is using this datum

/datum/tgui_secrets_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/tgui_secrets_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		ui = new(user, src, "SecretsPanel")
		ui.open()

/datum/tgui_secrets_panel/New(user) //user can either be a client or a mob
	if (user) //Prevents runtimes on datums being made without clients
		setup(user)

/datum/tgui_secrets_panel/proc/setup(user) //H can either be a client or a mob
	if (istype(user,/client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder
	ui_interact(holder.mob)

/datum/tgui_secrets_panel/ui_data(mob/user)
	var/list/data = list()
	var/client/rights = holder
	
	if(rights.mob != usr)
		return
	
	data["anyRights"] = check_rights_for(rights)
	data["adminRights"] = check_rights_for(rights, R_ADMIN)
	data["funRights"] = check_rights_for(rights, R_FUN)
	data["debugRights"] = check_rights_for(rights, R_DEBUG)
	data["lastsignalers"] = length(GLOB.lastsignalers)
	data["lawchanges"] = length(GLOB.lawchanges)
	return data

/datum/tgui_secrets_panel/ui_act(action, params)
	if(..())
		return
	var/datum/round_event/E
	var/client/rights = holder
	var/datum/admins/admindatum = rights.holder
	var/mob/mob_user = rights.mob

	if(mob_user != usr)
		return

	var/ok = 0
	switch(action)
		if("admin_log")
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Admin Log<HR></B>"
			for(var/l in GLOB.admin_log)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_log.len)
				dat += "No-one has done anything this round!"
			dat += "</BODY></HTML>"
			mob_user << browse(dat, "window=admin_log")

		if("mentor_log") // YOGS - Get in those mentor logs
			admindatum.YogMentorLogs() // YOGS - Same as above

		if("show_admins")
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Current admins:</B><HR>"
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank.name]<br>"
				dat += "</BODY></HTML>"
				mob_user << browse(dat, "window=showadmins;size=600x500")

		if("tdomereset")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/delete_mobs = alert(mob_user, "Clear all mobs?","Confirm","Yes","No","Cancel")
			if(delete_mobs == "Cancel")
				return

			log_admin("[key_name(mob_user)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
			message_admins(span_adminnotice("[key_name_admin(mob_user)] reset the thunderdome to default with delete_mobs=[delete_mobs]."))

			var/area/thunderdome = GLOB.areas_by_type[/area/tdome/arena]
			if(delete_mobs == "Yes")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera) && !istype(obj, /obj/effect/abstract/proximity_checker))
					qdel(obj) //Clear objects

			var/area/template = GLOB.areas_by_type[/area/tdome/arena_source]
			template.copy_contents_to(thunderdome)

		if("clear_virus")

			var/choice = input(mob_user, "Are you sure you want to cure all disease?") in list("Yes", "Cancel")
			if(choice == "Yes")
				message_admins("[key_name_admin(mob_user)] has cured all diseases.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure(0)
		if("set_name")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/new_name = input(mob_user, "Please input a new name for the station.", "What?", "") as text|null
			if(!new_name)
				return
			set_station_name(new_name)
			log_admin("[key_name(mob_user)] renamed the station to \"[new_name]\".")
			message_admins(span_adminnotice("[key_name_admin(mob_user)] renamed the station to: [new_name]."))
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")
		if("night_shift_set")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/val = alert(mob_user, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", "On", "Off", "Automatic")
			switch(val)
				if("Automatic")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(FALSE, TRUE)
				if("On")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(TRUE, TRUE)
				if("Off")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(FALSE, TRUE)

		if("reset_name")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(mob_user)] reset the station name.")
			message_admins(span_adminnotice("[key_name_admin(mob_user)] reset the station name."))
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")

		if("list_bombers")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Bombing List</B><HR>"
			for(var/l in GLOB.bombers)
				dat += text("[l]<BR>")
			dat += "</BODY></HTML>"
			mob_user << browse(dat, "window=bombers")

		if("list_signalers")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Showing last [length(GLOB.lastsignalers)] signalers.</B><HR>"
			for(var/sig in GLOB.lastsignalers)
				dat += "[sig]<BR>"
			dat += "</BODY></HTML>"
			mob_user << browse(dat, "window=lastsignalers;size=800x500")

		if("list_lawchanges")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Showing last [length(GLOB.lawchanges)] law changes.</B><HR>"
			for(var/sig in GLOB.lawchanges)
				dat += "[sig]<BR>"
			dat += "</BODY></HTML>"
			mob_user << browse(dat, "window=lawchanges;size=800x500")

		if("moveminingshuttle")
			if(!check_rights_for(rights, R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Mining Shuttle"))
			if(!SSshuttle.toggleShuttle("mining","mining_home","mining_away"))
				message_admins("[key_name_admin(mob_user)] moved mining shuttle")
				log_admin("[key_name(mob_user)] moved the mining shuttle")

		if("movelaborshuttle")
			if(!check_rights_for(rights, R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Labor Shuttle"))
			if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
				message_admins("[key_name_admin(mob_user)] moved labor shuttle")
				log_admin("[key_name(mob_user)] moved the labor shuttle")

		if("moveferry")
			if(!check_rights_for(rights, R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send CentCom Ferry"))
			if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
				message_admins("[key_name_admin(mob_user)] moved the CentCom ferry")
				log_admin("[key_name(mob_user)] moved the CentCom ferry")

		if("togglearrivals")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/obj/docking_port/mobile/arrivals/A = SSshuttle.arrivals
			if(A)
				var/new_perma = !A.perma_docked
				A.perma_docked = new_perma
				SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Permadock Arrivals Shuttle", "[new_perma ? "Enabled" : "Disabled"]"))
				message_admins("[key_name_admin(mob_user)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
				log_admin("[key_name(mob_user)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
			else
				to_chat(mob_user, span_admin("There is no arrivals shuttle"), confidential=TRUE)
		if("showailaws")
			if(!check_rights_for(rights, R_ADMIN))
				return
			admindatum.output_ai_laws()
		if("showgm")
			if(!check_rights_for(rights, R_ADMIN))
				return
			if(!SSticker.HasRoundStarted())
				alert(mob_user, "The game hasn't started yet!")
			else if (SSticker.mode)
				alert(mob_user, "The game mode is [SSticker.mode.name]")
			else alert(mob_user, "For some reason there's a SSticker, but not a game mode")
		if("manifest")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Showing Crew Manifest.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
			for(var/datum/data/record/t in GLOB.data_core.general)
				dat += "<tr><td>[t.fields["name"]]</td><td>[t.fields["rank"]]</td></tr>"
			dat += "</table>"
			dat += "</BODY></HTML>"
			mob_user << browse(dat, "window=manifest;size=440x410")
		if("DNA")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Showing DNA from blood.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td></tr>"
			dat += "</table>"
			dat += "</BODY></HTML>"
			mob_user << browse(dat, "window=DNA;size=440x410")
		if("fingerprints")
			if(!check_rights_for(rights, R_ADMIN))
				return
			var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Showing Fingerprints.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
			dat += "</table></BODY></HTML>"
			mob_user << browse(dat, "window=fingerprints;size=440x410")

		if("monkey")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Monkeyize All Humans"))
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				spawn(0)
					H.monkeyize()
			ok = 1

		if("allspecies")
			if(!check_rights_for(rights, R_FUN))
				return
			var/result = input(mob_user, "Please choose a new species","Species") as null|anything in GLOB.species_list
			if(result)
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Species Change", "[result]"))
				log_admin("[key_name(mob_user)] turned all humans into [result]", 1)
				message_admins("\blue [key_name_admin(mob_user)] turned all humans into [result]")
				var/newtype = GLOB.species_list[result]
				for(var/mob/living/carbon/human/H in GLOB.carbon_list)
					H.set_species(newtype)

		if("tripleAI")
			if(!check_rights_for(rights, R_FUN))
				return
			mob_user.client.triple_ai()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Triple AI"))

		if("power")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All APCs"))
			log_admin("[key_name(mob_user)] made all areas powered", 1)
			message_admins(span_adminnotice("[key_name_admin(mob_user)] made all areas powered"))
			power_restore()

		if("unpower")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Depower All APCs"))
			log_admin("[key_name(mob_user)] made all areas unpowered", 1)
			message_admins(span_adminnotice("[key_name_admin(mob_user)] made all areas unpowered"))
			power_failure()

		if("quickpower")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All SMESs"))
			log_admin("[key_name(mob_user)] made all SMESs powered", 1)
			message_admins(span_adminnotice("[key_name_admin(mob_user)] made all SMESs powered"))
			power_restore_quick()

		if("traitor_all")
			if(!check_rights_for(rights, R_FUN))
				return
			if(!SSticker.HasRoundStarted())
				alert(mob_user, "The game hasn't started yet!")
				return
			var/objective = stripped_input(mob_user, "Enter an objective")
			if(!objective)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Traitor All", "[objective]"))
			for(var/mob/living/H in GLOB.player_list)
				if(!(ishuman(H)||istype(H, /mob/living/silicon/)))
					continue
				if(H.stat == DEAD || !H.client || !H.mind || ispAI(H))
					continue
				if(is_special_character(H))
					continue
				var/datum/antagonist/traitor/T = new()
				T.give_objectives = FALSE
				var/datum/objective/new_objective = new
				new_objective.owner = H
				new_objective.explanation_text = objective
				T.add_objective(new_objective)
				H.mind.add_antag_datum(T)
			message_admins(span_adminnotice("[key_name_admin(mob_user)] used everyone is a traitor secret. Objective is [objective]"))
			log_admin("[key_name(mob_user)] used everyone is a traitor secret. Objective is [objective]")

		if("iaa_all")
			if(!check_rights_for(rights, R_FUN))
				return
			if(!SSticker.HasRoundStarted())
				alert(mob_user, "The game hasn't started yet!")
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("IAA All"))
			for(var/mob/living/H in GLOB.player_list)
				if(!(ishuman(H)))
					continue
				if(H.stat == DEAD || !H.client || !H.mind || ispAI(H))
					continue
				if(is_special_character(H))
					continue
				var/list/badjobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg", "Captain", "Head of Personnel", "Head of Security")
				if(H.mind.assigned_role in badjobs)
					continue
				var/datum/antagonist/traitor/internal_affairs/T = new()
				H.mind.add_antag_datum(T)
			message_admins(span_adminnotice("[key_name_admin(mob_user)] used everyone is a iaa secret."))
			log_admin("[key_name(mob_user)] used everyone is a iaa secret.")

		if("changebombcap")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Bomb Cap"))

			var/newBombCap = input(mob_user,"What would you like the new bomb cap to be. (entered as the light damage range (the 3rd number in common (1,2,3) notation)) Must be above 4)", "New Bomb Cap", GLOB.MAX_EX_LIGHT_RANGE) as num|null
			if (!CONFIG_SET(number/bombcap, newBombCap))
				return

			message_admins(span_boldannounce("[key_name_admin(mob_user)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]"))
			log_admin("[key_name(mob_user)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]")

		if("blackout")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Break All Lights"))
			message_admins("[key_name_admin(mob_user)] broke all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.break_light_tube()

		if("anime")
			if(!check_rights_for(rights, R_FUN))
				return
			var/animetype = alert(mob_user, "Would you like to have the clothes be changed?",,"Yes","No","Cancel")

			var/droptype
			if(animetype =="Yes")
				droptype = alert(mob_user, "Make the uniforms Nodrop?",,"Yes","No","Cancel")

			if(animetype == "Cancel" || droptype == "Cancel")
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Chinese Cartoons"))
			message_admins("[key_name_admin(mob_user)] made everything kawaii.")
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.client.prefs && H.client.prefs.disable_alternative_announcers)
					SEND_SOUND(H, sound(SSstation.default_announcer.event_sounds[ANNOUNCER_ANIMES]))
				else
					SEND_SOUND(H, sound(SSstation.announcer.event_sounds[ANNOUNCER_ANIMES]))

				if(H.dna.features["tail_human"] == "None" || H.dna.features["ears"] == "None")
					var/obj/item/organ/ears/cat/ears = new
					var/obj/item/organ/tail/cat/tail = new
					ears.Insert(H, drop_if_replaced=FALSE)
					tail.Insert(H, drop_if_replaced=FALSE)
				var/list/honorifics = list("[MALE]" = list("kun"), "[FEMALE]" = list("chan","tan"), "[NEUTER]" = list("san"), "[PLURAL]" = list("san")) //John Robust -> Robust-kun
				var/list/names = splittext(H.real_name," ")
				var/forename = names.len > 1 ? names[2] : names[1]
				var/newname = "[forename]-[pick(honorifics["[H.gender]"])]"
				H.fully_replace_character_name(H.real_name,newname)
				H.update_mutant_bodyparts()
				if(animetype == "Yes")
					var/seifuku = pick(typesof(/obj/item/clothing/under/schoolgirl))
					var/obj/item/clothing/under/schoolgirl/I = new seifuku
					var/olduniform = H.w_uniform
					H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
					H.equip_to_slot_or_del(I, SLOT_W_UNIFORM)
					qdel(olduniform)
					if(droptype == "Yes")
						ADD_TRAIT(I, TRAIT_NODROP, ADMIN_TRAIT)

		if("whiteout")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Fix All Lights"))
			message_admins("[key_name_admin(mob_user)] fixed all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.fix()

		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)

		if("virus")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Virus Outbreak"))
			switch(alert(mob_user, "Do you want this to be a random disease or do you have something in mind?",,"Make Your Own","Random","Choose"))
				if("Make Your Own")
					AdminCreateVirus(mob_user.client)
				if("Random")
					E = new /datum/round_event/disease_outbreak()
				if("Choose")
					var/virus = input(mob_user, "Choose the virus to spread", "BIOHAZARD") as null|anything in typesof(/datum/disease)
					E = new /datum/round_event/disease_outbreak{}()
					var/datum/round_event/disease_outbreak/DO = E
					DO.virus_type = virus

		if("retardify")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Braindamage"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, span_boldannounce("You suddenly feel stupid."))
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60, 80)
			message_admins("[key_name_admin(mob_user)] made everybody stupid")

		if("eagles")//SCRAW
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Egalitarian Station"))
			for(var/obj/machinery/door/airlock/W in GLOB.machines)
				if(is_station_level(W.z) && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
					W.req_access = list()
			message_admins("[key_name_admin(mob_user)] activated Egalitarian Station mode (All doors are open access)")
			priority_announce("CentCom airlock control override activated. Please take this time to get acquainted with your coworkers.", null, RANDOM_REPORT_SOUND)

		if("ancap")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Anarcho-capitalist Station"))
			SSeconomy.full_ancap = !SSeconomy.full_ancap
			message_admins("[key_name_admin(mob_user)] toggled Anarcho-capitalist mode")
			if(SSeconomy.full_ancap)
				priority_announce("The NAP is now in full effect.", null, RANDOM_REPORT_SOUND)
			else
				priority_announce("The NAP has been revoked.", null, RANDOM_REPORT_SOUND)

		if("dorf")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Dwarf Beards"))
			for(var/mob/living/carbon/human/B in GLOB.carbon_list)
				B.facial_hair_style = "Dward Beard"
				B.update_hair()
			message_admins("[key_name_admin(mob_user)] activated dorf mode")

		if("onlyone")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			mob_user.client.only_one()
			sound_to_playing_players('sound/misc/highlander.ogg')

		if("delayed_onlyone")
			if(!check_rights_for(rights, R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			mob_user.client.only_one_delayed()
			sound_to_playing_players('sound/misc/highlander_delayed.ogg')

		if("maint_access_brig")
			if(!check_rights_for(rights, R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list(ACCESS_BRIG)
			message_admins("[key_name_admin(mob_user)] made all maint doors brig access-only.")
		if("maint_access_engiebrig")
			if(!check_rights_for(rights, R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list()
					M.req_one_access = list(ACCESS_BRIG,ACCESS_ENGINE)
			message_admins("[key_name_admin(mob_user)] made all maint doors engineering and brig access-only.")
		if("infinite_sec")
			if(!check_rights_for(rights, R_DEBUG))
				return
			var/datum/job/J = SSjob.GetJob("Security Officer")
			if(!J)
				return
			J.total_positions = -1
			J.spawn_positions = -1
			message_admins("[key_name_admin(mob_user)] has removed the cap on security officers.")

		if("ctfbutton")
			if(!check_rights_for(rights, R_ADMIN))
				return
			toggle_all_ctf(mob_user)
		if("masspurrbation")
			if(!check_rights_for(rights, R_FUN))
				return
			mass_purrbation()
			message_admins("[key_name_admin(mob_user)] has put everyone on \
				purrbation!")
			log_admin("[key_name(mob_user)] has put everyone on purrbation.")
		if("massremovepurrbation")
			if(!check_rights_for(rights, R_FUN))
				return
			mass_remove_purrbation()
			message_admins("[key_name_admin(mob_user)] has removed everyone from \
				purrbation.")
			log_admin("[key_name(mob_user)] has removed everyone from purrbation.")

	if(E)
		E.processing = FALSE
		if(E.announceWhen>0)
			if(alert(mob_user, "Would you like to alert the crew?", "Alert", "Yes", "No") == "No")
				E.announceWhen = -1
		E.processing = TRUE
	if (mob_user)
		log_admin("[key_name(mob_user)] used secret [action]")
		if (ok)
			to_chat(world, text("<B>A secret has been activated by []!</B>", mob_user.key))
