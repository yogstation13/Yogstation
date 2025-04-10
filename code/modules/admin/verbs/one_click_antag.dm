/client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin.Round Interaction"

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"
		<a href='byond://?src=[REF(src)];[HrefToken()];makeAntag=centcom_custom'>Make Uplink CentCom Response Team (Requires Ghosts)</a><br>
		<a href='byond://?src=[REF(src)];[HrefToken()];makeAntag=centcom'>Make CentCom Response Team (Requires Ghosts)</a>
		"}

	var/datum/browser/popup = new(usr, "oneclickantag", "Quick-Create Antagonist", 400, 400)
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/isReadytoRumble(mob/living/carbon/human/applicant, targetrole, onstation = TRUE, conscious = TRUE)
	if(applicant.mind.special_role)
		return FALSE
	if(!(targetrole in applicant.client.prefs.be_special))
		return FALSE
	if(onstation)
		var/turf/T = get_turf(applicant)
		if(!is_station_level(T.z))
			return FALSE
	if(conscious && applicant.stat) //incase you don't care about a certain antag being unconscious when made, ie if they have selfhealing abilities.
		return FALSE
	if(!considered_alive(applicant.mind) || considered_afk(applicant.mind)) //makes sure the player isn't a zombie, brain, or just afk all together
		return FALSE
	return !is_banned_from(applicant.ckey, list(targetrole, ROLE_ANTAG))

// DEATH SQUADS
/datum/admins/proc/makeDeathsquad()
	return makeEmergencyresponseteam(/datum/ert/deathsquad)

// CENTCOM RESPONSE TEAM

/datum/admins/proc/makeERTTemplateModified(list/settings)
	. = settings
	var/datum/ert/newtemplate = settings["mainsettings"]["template"]["value"]
	if (isnull(newtemplate))
		return
	if (!ispath(newtemplate))
		newtemplate = text2path(newtemplate)
	newtemplate = new newtemplate
	.["mainsettings"]["teamsize"]["value"] = newtemplate.teamsize
	.["mainsettings"]["mission"]["value"] = newtemplate.mission
	.["mainsettings"]["polldesc"]["value"] = newtemplate.polldesc
	.["mainsettings"]["open_armory"]["value"] = newtemplate.opendoors ? "Yes" : "No"
	.["mainsettings"]["open_mechbay"]["value"] = newtemplate.openmech ? "Yes" : "No"


/datum/admins/proc/equipAntagOnDummy(mob/living/carbon/human/dummy/mannequin, datum/antagonist/antag)
	for(var/I in mannequin.get_equipped_items(TRUE))
		qdel(I)
	if (ispath(antag, /datum/antagonist/ert))
		var/datum/antagonist/ert/ert = antag
		mannequin.equipOutfit(initial(ert.outfit), TRUE)
	else if (ispath(antag, /datum/antagonist/centcom))
		var/datum/antagonist/centcom/centcom = antag
		mannequin.equipOutfit(initial(centcom.outfit), TRUE)

/datum/admins/proc/makeERTPreviewIcon(list/settings)
	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_ADMIN)

	var/prefs = settings["mainsettings"]
	var/datum/ert/template = prefs["template"]["value"]
	if (isnull(template))
		return null
	if (!ispath(template))
		template = text2path(prefs["template"]["value"]) // new text2path ... doesn't compile in 511

	template = new template
	var/datum/antagonist/ert/ert = template.leader_role

	equipAntagOnDummy(mannequin, ert)

	CHECK_TICK
	var/icon/preview_icon = icon('icons/effects/effects.dmi', "nothing")
	preview_icon.Scale(48+32, 16+32)
	CHECK_TICK
	mannequin.setDir(NORTH)
	var/icon/stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 25, 17)
	CHECK_TICK
	mannequin.setDir(WEST)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 1, 9)
	CHECK_TICK
	mannequin.setDir(SOUTH)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 49, 1)
	CHECK_TICK
	preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2) // Scaling here to prevent blurring in the browser.
	CHECK_TICK
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_ADMIN)
	return preview_icon

/datum/admins/proc/makeEmergencyresponseteam(datum/ert/ertemplate = null)
	if (ertemplate)
		ertemplate = new ertemplate
	else
		ertemplate = new /datum/ert/official

	var/list/settings = list(
		"preview_callback" = CALLBACK(src, PROC_REF(makeERTPreviewIcon)),
		"mainsettings" = list(
		"template" = list("desc" = "Template", "callback" = CALLBACK(src, PROC_REF(makeERTTemplateModified)), "type" = "datum", "path" = "/datum/ert", "subtypesonly" = TRUE, "value" = ertemplate.type),
		"teamsize" = list("desc" = "Team Size", "type" = "number", "value" = ertemplate.teamsize),
		"mission" = list("desc" = "Mission", "type" = "string", "value" = ertemplate.mission),
		"polldesc" = list("desc" = "Ghost poll description", "type" = "string", "value" = ertemplate.polldesc),
		"enforce_human" = list("desc" = "Enforce human authority", "type" = "boolean", "value" = "[(CONFIG_GET(flag/enforce_human_authority) ? "Yes" : "No")]"),
		"open_armory" = list("desc" = "Open armory doors", "type" = "boolean", "value" = "[(ertemplate.opendoors ? "Yes" : "No")]"),
		"open_mechbay" = list("desc" = "Open Mech Bay", "type" = "boolean", "value" = "[(ertemplate.openmech ? "Yes" : "No")]"),
		"dust_implant" = list("desc" = "Dusting Implant", "type" = "boolean", "value" = "[(ertemplate.dusting ? "Yes" : "No")]")
		)
	)

	var/list/prefreturn = presentpreflikepicker(usr,"Customize ERT", "Customize ERT", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

	if (isnull(prefreturn))
		return FALSE

	if (prefreturn["button"] == 1)
		var/list/prefs = settings["mainsettings"]

		var/templtype = prefs["template"]["value"]
		if (!ispath(prefs["template"]["value"]))
			templtype = text2path(prefs["template"]["value"]) // new text2path ... doesn't compile in 511

		if (ertemplate.type != templtype)
			ertemplate = new templtype

		ertemplate.teamsize = prefs["teamsize"]["value"]
		ertemplate.mission = prefs["mission"]["value"]
		ertemplate.polldesc = prefs["polldesc"]["value"]
		ertemplate.enforce_human = prefs["enforce_human"]["value"] == "Yes" ? TRUE : FALSE
		ertemplate.opendoors = prefs["open_armory"]["value"] == "Yes" ? TRUE : FALSE
		ertemplate.openmech = prefs["open_mechbay"]["value"] == "Yes" ? TRUE : FALSE
		ertemplate.dusting = prefs["dust_implant"]["value"] == "Yes" ? TRUE : FALSE

		var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for [ertemplate.polldesc] ?", "deathsquad", null)
		var/teamSpawned = FALSE

		if(candidates.len > 0)
			//Pick the (un)lucky players
			var/numagents = min(ertemplate.teamsize,candidates.len)

			//Create team
			var/datum/team/ert/ert_team = new ertemplate.team
			if(ertemplate.rename_team)
				ert_team.name = ertemplate.rename_team

			//Asign team objective
			var/datum/objective/missionobj = new
			missionobj.team = ert_team
			missionobj.explanation_text = ertemplate.mission
			missionobj.completed = TRUE
			ert_team.objectives += missionobj
			ert_team.mission = missionobj

			var/list/spawnpoints = GLOB.emergencyresponseteamspawn
			while(numagents && candidates.len)
				if (numagents > spawnpoints.len)
					numagents--
					continue // This guy's unlucky, not enough spawn points, we skip him.
				var/spawnloc = spawnpoints[numagents]
				var/mob/dead/observer/chosen_candidate = pick(candidates)
				candidates -= chosen_candidate
				if(!chosen_candidate.key)
					continue

				//Spawn the body
				var/mob/living/carbon/human/ERTOperative = new ertemplate.mobtype(spawnloc)
				chosen_candidate.client.prefs.apply_prefs_to(ERTOperative)
				ERTOperative.key = chosen_candidate.key

				if(ertemplate.enforce_human || !(ERTOperative.dna.species.changesource_flags & ERT_SPAWN)) // Don't want any exploding plasmemes
					ERTOperative.set_species(/datum/species/human)

				//Give antag datum
				var/datum/antagonist/ert/ert_antag

				if(numagents == 1)
					ert_antag = new ertemplate.leader_role
				else
					ert_antag = ertemplate.roles[WRAP(numagents,1,length(ertemplate.roles) + 1)]
					ert_antag = new ert_antag

				ERTOperative.mind.add_antag_datum(ert_antag,ert_team)
				ERTOperative.mind.assigned_role = ert_antag.name

				if(ertemplate.dusting)
					var/obj/item/implant/dusting/dustimplant = new(ERTOperative)
					dustimplant.implant(ERTOperative)

				//Logging and cleanup
				//log_game("[key_name(ERTOperative)] has been selected as an [ert_antag.name]") | yogs - redundant
				numagents--
				teamSpawned++

			if (teamSpawned)
				message_admins("[ertemplate.polldesc] has spawned with the mission: [ertemplate.mission]")

			//Open the Armory doors
			if(ertemplate.opendoors)
				for(var/obj/machinery/door/poddoor/ert/door in GLOB.airlocks)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))

			//Open the Mech Bay
			if(ertemplate.openmech)
				for(var/obj/machinery/door/poddoor/deathsquad/door in GLOB.airlocks)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))
			return TRUE
		else
			return FALSE

	return

// Uplink-equipped Centcom Response Team
/datum/admins/proc/makeUplinkEmergencyResponseTeam(datum/ert/ertemplate = null)
	if (ertemplate)
		ertemplate = new ertemplate
	else
		ertemplate = new /datum/ert/uplinked

	var/list/settings = list(
		"preview_callback" = CALLBACK(src, PROC_REF(makeERTPreviewIcon)),
		"mainsettings" = list(
		"template" = list("desc" = "Template", "type" = "datum", "path" = "/datum/ert/uplinked", "value" = "/datum/ert/uplinked"),
		"uplink" = list("desc" = "Uplink Type", "type" = "datum", "path" = "/obj/item/ntuplink", "subtypesonly" = TRUE, "value" = ertemplate.uplinktype),
		"teamsize" = list("desc" = "Team Size", "type" = "number", "value" = ertemplate.teamsize),
		"mission" = list("desc" = "Mission", "type" = "string", "value" = ertemplate.mission),
		"polldesc" = list("desc" = "Ghost poll description", "type" = "string", "value" = ertemplate.polldesc),
		"enforce_human" = list("desc" = "Enforce human authority", "type" = "boolean", "value" = "[(CONFIG_GET(flag/enforce_human_authority) ? "Yes" : "No")]"),
		"open_armory" = list("desc" = "Open armory doors", "type" = "boolean", "value" = "[(ertemplate.opendoors ? "Yes" : "No")]"),
		"open_mechbay" = list("desc" = "Open Mech Bay", "type" = "boolean", "value" = "[(ertemplate.openmech ? "Yes" : "No")]"),
		"dust_implant" = list("desc" = "Dusting Implant", "type" = "boolean", "value" = "[(ertemplate.dusting ? "Yes" : "No")]"),
		)
	)

	var/list/prefreturn = presentpreflikepicker(usr,"Customize ERT", "Customize ERT", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

	if (isnull(prefreturn))
		return FALSE

	if (prefreturn["button"] == 1)
		var/list/prefs = settings["mainsettings"]

		ertemplate.uplinktype = prefs["uplink"]["value"]
		ertemplate.teamsize = prefs["teamsize"]["value"]
		ertemplate.mission = prefs["mission"]["value"]
		ertemplate.polldesc = prefs["polldesc"]["value"]
		ertemplate.enforce_human = prefs["enforce_human"]["value"] == "Yes" ? TRUE : FALSE
		ertemplate.opendoors = prefs["open_armory"]["value"] == "Yes" ? TRUE : FALSE
		ertemplate.openmech = prefs["open_mechbay"]["value"] == "Yes" ? TRUE : FALSE
		ertemplate.dusting = prefs["dust_implant"]["value"] == "Yes" ? TRUE : FALSE

		var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for [ertemplate.polldesc] ?", "deathsquad", null)
		var/teamSpawned = FALSE

		if(candidates.len > 0)
			//Pick the (un)lucky players
			var/numagents = min(ertemplate.teamsize,candidates.len)

			//Create team
			var/datum/team/ert/ert_team = new ertemplate.team
			if(ertemplate.rename_team)
				ert_team.name = ertemplate.rename_team

			//Asign team objective
			var/datum/objective/missionobj = new
			missionobj.team = ert_team
			missionobj.explanation_text = ertemplate.mission
			missionobj.completed = TRUE
			ert_team.objectives += missionobj
			ert_team.mission = missionobj

			var/list/spawnpoints = GLOB.emergencyresponseteamspawn
			while(numagents && candidates.len)
				if (numagents > spawnpoints.len)
					numagents--
					continue // This guy's unlucky, not enough spawn points, we skip him.
				var/spawnloc = spawnpoints[numagents]
				var/mob/dead/observer/chosen_candidate = pick(candidates)
				candidates -= chosen_candidate
				if(!chosen_candidate.key)
					continue

				//Spawn the body
				var/mob/living/carbon/human/ERTOperative = new ertemplate.mobtype(spawnloc)
				chosen_candidate.client.prefs.apply_prefs_to(ERTOperative)
				ERTOperative.key = chosen_candidate.key

				if(ertemplate.enforce_human || !(ERTOperative.dna.species.changesource_flags & ERT_SPAWN)) // Don't want any exploding plasmemes
					ERTOperative.set_species(/datum/species/human)

				//Give antag datum
				var/datum/antagonist/ert/ert_antag

				if(numagents == 1)
					ert_antag = new ertemplate.leader_role
				else
					ert_antag = ertemplate.roles[WRAP(numagents,1,length(ertemplate.roles) + 1)]
					ert_antag = new ert_antag

				ERTOperative.mind.add_antag_datum(ert_antag,ert_team)
				ERTOperative.mind.assigned_role = ert_antag.name

				// Equip uplink
				var/obj/item/ntuplink/upl = new ertemplate.uplinktype(ERTOperative, ERTOperative.key)
				if(istype(ert_antag, /datum/antagonist/ert/common/trooper))
					upl.nt_datum = /datum/component/uplink/nanotrasen/trooper
				else if(istype(ert_antag, /datum/antagonist/ert/common/medic))
					upl.nt_datum = /datum/component/uplink/nanotrasen/medic
				else if(istype(ert_antag, /datum/antagonist/ert/common/engineer))
					upl.nt_datum = /datum/component/uplink/nanotrasen/engineer
				upl.finalize()
				if(istype(upl))
					ERTOperative.equip_to_slot_or_del(upl, ITEM_SLOT_BACKPACK)
					ert_team.uplink_type = ertemplate.uplinktype // Type path

				if(ertemplate.dusting)
					var/obj/item/implant/dusting/dustimplant = new(ERTOperative)
					dustimplant.implant(ERTOperative)

				//Logging and cleanup
				//log_game("[key_name(ERTOperative)] has been selected as an [ert_antag.name]") | yogs - redundant
				numagents--
				teamSpawned++

			if (teamSpawned)
				message_admins("[ertemplate.polldesc] has spawned with the mission: [ertemplate.mission]")

			//Open the Armory doors
			if(ertemplate.opendoors)
				for(var/obj/machinery/door/poddoor/ert/door in GLOB.airlocks)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))

			//Open the Mech Bay
			if(ertemplate.openmech)
				for(var/obj/machinery/door/poddoor/deathsquad/door in GLOB.airlocks)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))
			return TRUE

	return FALSE
