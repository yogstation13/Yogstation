/datum/ert
	var/mobtype = /mob/living/carbon/human
	var/team = /datum/team/ert
	var/opendoors = TRUE
	var/openmech = FALSE
	var/leader_role = /datum/antagonist/ert/commander
	var/enforce_human = TRUE
	var/roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer) //List of possible roles to be assigned to ERT members.
	var/rename_team
	var/code
	var/mission = "Assist the station."
	var/teamsize = 5
	var/polldesc

	// this can be safely set as default because it doesnt do anything unless specifically making uplinked ERT
	var/obj/item/uplinktype = /obj/item/ntuplink/official 

/datum/ert/New()
	if (!polldesc)
		polldesc = "a Code [code] Nanotrasen Emergency Response Team"

/datum/ert/proc/MakeTeam()
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for [polldesc] ?", "deathsquad", null)
	var/teamSpawned = FALSE

	if(candidates.len > 0)
		//Pick the (un)lucky players
		var/numagents = min(teamsize,candidates.len)
		//Create team
		var/datum/team/ert/ert_team = new team
		if(rename_team)
			ert_team.name = rename_team

		//Asign team objective
		var/datum/objective/missionobj = new
		missionobj.team = ert_team
		missionobj.explanation_text = mission
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
			var/mob/living/carbon/human/ERTOperative = new mobtype(spawnloc)
			chosen_candidate.client.prefs.copy_to(ERTOperative)
			ERTOperative.key = chosen_candidate.key

			if(enforce_human || !(ERTOperative.dna.species.changesource_flags & ERT_SPAWN)) // Don't want any exploding plasmemes
				ERTOperative.set_species(/datum/species/human)

			//Give antag datum
			var/datum/antagonist/ert/ert_antag

			if(numagents == 1)
				ert_antag = new leader_role
			else
				ert_antag = roles[WRAP(numagents,1,length(roles) + 1)]
				ert_antag = new ert_antag

			ERTOperative.mind.add_antag_datum(ert_antag,ert_team)
			ERTOperative.mind.assigned_role = ert_antag.name

			// Equip uplink
			var/obj/item/ntuplink/upl = new uplinktype(ERTOperative, ERTOperative.key)
			if(istype(upl))
				ERTOperative.equip_to_slot_or_del(upl, SLOT_IN_BACKPACK)
				ert_team.uplink_type = uplinktype // Type path

			//Logging and cleanup
			//log_game("[key_name(ERTOperative)] has been selected as an [ert_antag.name]") | yogs - redundant
			numagents--
			teamSpawned++

		if (teamSpawned)
			message_admins("[polldesc] has spawned with the mission: [mission]")

		//Open the Armory doors
		if(opendoors)
			for(var/obj/machinery/door/poddoor/ert/door in GLOB.airlocks)
				INVOKE_ASYNC(door, /obj/machinery/door/poddoor.proc/open)

		//Open the Mech Bay
		if(openmech)
			for(var/obj/machinery/door/poddoor/deathsquad/door in GLOB.airlocks)
				INVOKE_ASYNC(door, /obj/machinery/door/poddoor.proc/open)
		return TRUE

	return FALSE
/datum/ert/blue
	opendoors = FALSE
	code = "Blue"

/datum/ert/amber
	opendoors = FALSE
	code = "Amber"
	rename_team = "Amber Task Force"
	mission = "Eliminate the threat to the station."
	polldesc = "the Amber Task Force"
	teamsize = 7
	leader_role = /datum/antagonist/ert/amber/commander
	roles = list(/datum/antagonist/ert/amber,/datum/antagonist/ert/amber,/datum/antagonist/ert/amber/medic) // entered duplicate here to increase change of soldiers

/datum/ert/peacekeeper
	opendoors = FALSE
	code = "Blue"
	rename_team = "Peacekeeping Force"
	mission = "Enforce space law. Occupy the station. Minimize crew casualties."
	polldesc = "the Peacekeeping Force"
	teamsize = 5 // redundant but keeping this here for clarity
	leader_role = /datum/antagonist/ert/occupying/commander
	roles = list(/datum/antagonist/ert/occupying,/datum/antagonist/ert/occupying/heavy,/datum/antagonist/ert/occupying,/datum/antagonist/ert/occupying) 

/datum/ert/red
	leader_role = /datum/antagonist/ert/commander/red
	roles = list(/datum/antagonist/ert/security/red, /datum/antagonist/ert/medic/red, /datum/antagonist/ert/engineer/red)
	code = "Red"

/datum/ert/deathsquad
	roles = list(/datum/antagonist/ert/deathsquad)
	leader_role = /datum/antagonist/ert/deathsquad/leader
	rename_team = "Deathsquad"
	openmech = TRUE
	code = "Delta"
	mission = "Leave no witnesses."
	polldesc = "an elite Nanotrasen Strike Team"

/datum/ert/official
	code = "Green"
	teamsize = 1
	opendoors = FALSE
	leader_role = /datum/antagonist/centcom
	roles = list(/datum/antagonist/centcom)
	rename_team = "CentCom Officials"
	polldesc = "a CentCom Official"

/datum/ert/official/New()
	mission = "Conduct a routine performance review of [station_name()] and its Captain."


/datum/ert/official/captain
	leader_role = /datum/antagonist/centcom/captain
	roles = list(/datum/antagonist/centcom/captain)
	rename_team = "CentCom Captains"
	polldesc = "a CentCom Captain"

/datum/ert/official/major
	leader_role = /datum/antagonist/centcom/major
	roles = list(/datum/antagonist/centcom/major)
	rename_team = "CentCom Majors"
	polldesc = "a CentCom Major"

/datum/ert/official/commodore
	leader_role = /datum/antagonist/centcom/commander
	roles = list(/datum/antagonist/centcom/commander)
	rename_team = "CentCom Commodores"
	polldesc = "a CentCom Commodore"

/datum/ert/official/colonel
	leader_role = /datum/antagonist/centcom/colonel
	roles = list(/datum/antagonist/centcom/colonel)
	rename_team = "CentCom Colonels"
	polldesc = "a CentCom Colonel"

/datum/ert/official/rear_admiral
	leader_role = /datum/antagonist/centcom/rear_admiral
	roles = list(/datum/antagonist/centcom/rear_admiral)
	rename_team = "CentCom Rear-Admirals"
	polldesc = "a CentCom Rear-Admiral"

/datum/ert/official/admiral
	leader_role = /datum/antagonist/centcom/admiral
	roles = list(/datum/antagonist/centcom/admiral)
	rename_team = "CentCom Admirals"
	polldesc = "a CentCom Admiral"

/datum/ert/official/grand_admiral
	leader_role = /datum/antagonist/centcom/grand_admiral
	roles = list(/datum/antagonist/centcom/grand_admiral)
	rename_team = "CentCom Grand Admirals"
	polldesc = "a CentCom Grand Admiral"

/datum/ert/uplinked
	leader_role = /datum/antagonist/ert/common/leader
	roles = list(/datum/antagonist/ert/common)
	rename_team = "Uplinked Emergency Response Team"
	polldesc = "an Uplink-Equipped ERT"

/datum/ert/inquisition
	roles = list(/datum/antagonist/ert/chaplain/inquisitor, /datum/antagonist/ert/security/inquisitor, /datum/antagonist/ert/medic/inquisitor)
	leader_role = /datum/antagonist/ert/commander/inquisitor
	rename_team = "Inquisition"
	mission = "Destroy any traces of paranormal activity aboard the station."
	polldesc = "a Nanotrasen paranormal response team"

/datum/ert/janitor
	roles = list(/datum/antagonist/ert/janitor, /datum/antagonist/ert/janitor/heavy)
	leader_role = /datum/antagonist/ert/janitor/heavy
	teamsize = 4
	opendoors = FALSE
	rename_team = "Janitor"
	mission = "Clean up EVERYTHING."
	polldesc = "a Nanotrasen Janitorial Response Team"

/datum/ert/clown
	roles = list(/datum/antagonist/ert/clown)
	leader_role = /datum/antagonist/ert/clown
	teamsize = 7
	opendoors = FALSE
	rename_team = "The Circus"
	mission = "Provide vital moral support to the station in this time of crisis"
	code = "Banana"

/datum/ert/honk
	roles = list(/datum/antagonist/ert/clown/honk)
	leader_role = /datum/antagonist/ert/clown/honk
	teamsize = 5
	opendoors = TRUE
	rename_team = "HONK Squad"
	mission = "HONK them into submission."
	polldesc = "an elite Nanotrasen tactical pranking squad"
	code = "HOOOOOOOOOONK"
