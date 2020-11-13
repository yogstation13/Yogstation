/datum/antagonist/centcom
	name = "CentCom Official"
	var/role = "Lieutenant"
	var/list/name_source
	var/datum/outfit/outfit = /datum/outfit/centcom/official
	antag_moodlet = /datum/mood_event/focused
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
	var/datum/objective/mission
	var/datum/team/ert/ert_team
	can_hijack = HIJACK_PREVENT
	show_to_ghosts = TRUE


/datum/antagonist/centcom/greet()
	to_chat(owner, "<B><font size=3 color=red>You are a CentCom Official.</font></B>")
	if (ert_team)
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [ert_team.mission.explanation_text]")
	else
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [mission.explanation_text]")

/datum/antagonist/centcom/proc/equipOfficial()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.equipOutfit(outfit)

/datum/antagonist/centcom/create_team(datum/team/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/centcom/proc/forge_objectives()
	if (ert_team)
		objectives |= ert_team.objectives
	else if (!mission)
		var/datum/objective/missionobj = new
		missionobj.owner = owner
		missionobj.explanation_text = "Conduct a routine performance review of [station_name()] and its Captain."
		missionobj.completed = 1
		mission = missionobj
		objectives |= mission

/datum/antagonist/centcom/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/centcom/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

/datum/antagonist/centcom/on_gain()
	forge_objectives()
	update_name()
	equipOfficial()
	. = ..()

/datum/antagonist/centcom/captain
	name = "CentCom Captain"
	role = "Captain"
	outfit = /datum/outfit/centcom/captain

/datum/antagonist/centcom/major
	name = "CentCom Major"
	role = "Major"
	outfit = /datum/outfit/centcom/major

/datum/antagonist/centcom/commander
	name = "CentCom Commodore"
	role = "Commodore"
	outfit = /datum/outfit/centcom/commander

/datum/antagonist/centcom/colonel
	name = "CentCom Colonel"
	role = "Colonel"
	outfit = /datum/outfit/centcom/colonel

/datum/antagonist/centcom/rear_admiral
	name = "CentCom Rear-Admiral"
	role = "Rear-Admiral"
	outfit = /datum/outfit/centcom/rear_admiral

/datum/antagonist/centcom/admiral
	name = "CentCom Admiral"
	role = "Admiral"
	outfit = /datum/outfit/centcom/admiral

/datum/antagonist/centcom/grand_admiral
	name = "CentCom Grand Admiral"
	role = "Grand Admiral"
	outfit = /datum/outfit/centcom/grand_admiral